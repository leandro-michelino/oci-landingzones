data "oci_objectstorage_namespace" "this" {
  count          = var.enable_data_bucket || var.enable_object_storage_private_endpoint ? 1 : 0
  compartment_id = var.tenancy_ocid
}

# Last successful validation: 2026-10-15 | Terraform init/validate and 4 plan-only regression cases | oracle/oci 9.9.0.
# Scope: pinned networking revision c07231c; v0.2.0 Vault/Streaming; live test covered only OCI networking, not paid services or endpoint traffic.
# Evidence: tests/configuration-regressions.tftest.hcl; local Terraform test results.
# Last successful reduced lifecycle: 2026-10-15 | DEFAULT, sa-saopaulo-1 | OCI network-only apply, no-drift plan, destroy, API/state cleanup | oracle/oci 9.9.0.
# Live evidence: docs/DATA-DEVOPS-DR-REVIEW-20261015.md; private logs in .leo-local/data-devops-dr-20261015/.
module "network" {
  source = "git::https://github.com/leandro-michelino/oci-landingzones.git//blueprints/networking/standalone-private-endpoint-only?ref=c07231c91d146265a46836757f3c399861a59fff"

  tenancy_ocid       = var.tenancy_ocid
  current_user_ocid  = var.current_user_ocid
  region             = var.region
  home_region        = var.home_region
  oci_config_profile = var.oci_config_profile
  compartment_ocid   = local.target_compartment_ocid
  org                = var.org
  environment        = var.environment
  region_key         = var.region_key
  defined_tags       = var.defined_tags
  freeform_tags      = local.common_freeform_tags
}

# Last successful validation: 2026-10-15 | Terraform init/validate and 4 plan-only regression cases | oracle/oci 9.9.0.
# Scope: v0.2.0 nested sources; no live provisioning or endpoint traffic verification.
# Evidence: tests/configuration-regressions.tftest.hcl; local Terraform test results.
module "vault" {
  source = "git::https://github.com/leandro-michelino/oci-landingzones.git//modules/security/vault?ref=v0.2.0"

  tenancy_ocid         = var.tenancy_ocid
  compartment_ocid     = local.target_compartment_ocid
  region               = var.region
  org                  = var.org
  environment          = var.environment
  region_key           = var.region_key
  enable_vault         = var.enable_vault
  enable_default_vault = var.enable_default_vault
  enable_default_key   = var.enable_default_key
  vaults               = var.vaults
  keys                 = var.vault_keys
  defined_tags         = var.defined_tags
  freeform_tags        = local.common_freeform_tags
}

resource "oci_objectstorage_bucket" "data" {
  count = var.enable_data_bucket ? 1 : 0

  compartment_id        = local.target_compartment_ocid
  name                  = local.data_bucket_name
  namespace             = data.oci_objectstorage_namespace.this[0].namespace
  access_type           = "NoPublicAccess"
  auto_tiering          = var.bucket_auto_tiering
  kms_key_id            = var.bucket_kms_key_id != null ? var.bucket_kms_key_id : try(module.vault.key_ids["default"], null)
  object_events_enabled = var.enable_bucket_events
  storage_tier          = var.bucket_storage_tier
  versioning            = var.enable_bucket_versioning ? "Enabled" : "Disabled"
  defined_tags          = var.defined_tags
  freeform_tags         = local.common_freeform_tags
}

resource "oci_core_network_security_group" "object_storage_endpoint" {
  count = var.enable_object_storage_private_endpoint && var.private_endpoint_subnet_id == null && length(var.private_endpoint_nsg_ids) == 0 ? 1 : 0

  compartment_id = local.target_compartment_ocid
  vcn_id         = module.network.vcn_id
  display_name   = "${local.name_prefix}-nsg-os-pe"
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}

resource "oci_core_network_security_group_security_rule" "object_storage_https_ingress" {
  #checkov:skip=CKV_OCI_21:Stateful HTTPS ingress permits only explicitly approved client CIDRs.
  for_each = var.enable_object_storage_private_endpoint && var.private_endpoint_subnet_id == null && length(var.private_endpoint_nsg_ids) == 0 ? var.private_endpoint_allowed_client_cidrs : toset([])

  network_security_group_id = oci_core_network_security_group.object_storage_endpoint[0].id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = each.value
  source_type               = "CIDR_BLOCK"
  stateless                 = false

  tcp_options {
    destination_port_range {
      min = 443
      max = 443
    }
  }
}

resource "oci_objectstorage_private_endpoint" "data" {
  count = var.enable_object_storage_private_endpoint ? 1 : 0

  compartment_id = local.target_compartment_ocid
  name           = local.private_endpoint_name
  namespace      = data.oci_objectstorage_namespace.this[0].namespace
  prefix         = var.private_endpoint_prefix
  subnet_id      = var.private_endpoint_subnet_id != null ? var.private_endpoint_subnet_id : try(module.network.subnet_ids[var.private_endpoint_subnet_key], null)
  nsg_ids        = length(var.private_endpoint_nsg_ids) > 0 ? tolist(var.private_endpoint_nsg_ids) : try([oci_core_network_security_group.object_storage_endpoint[0].id], [])
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags

  access_targets {
    bucket         = oci_objectstorage_bucket.data[0].name
    compartment_id = local.target_compartment_ocid
    namespace      = data.oci_objectstorage_namespace.this[0].namespace
  }
}

resource "oci_core_network_security_group" "streaming_endpoint" {
  count = var.enable_streaming && var.create_stream_pool && var.streaming_private_endpoint_subnet_id == null && length(var.streaming_private_endpoint_nsg_ids) == 0 ? 1 : 0

  compartment_id = local.target_compartment_ocid
  vcn_id         = module.network.vcn_id
  display_name   = "${local.name_prefix}-nsg-stream-pe"
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}

resource "oci_core_network_security_group_security_rule" "streaming_client_ingress" {
  #checkov:skip=CKV_OCI_21:Stateful ingress permits only approved REST and Kafka clients.
  for_each = var.enable_streaming && var.create_stream_pool && var.streaming_private_endpoint_subnet_id == null && length(var.streaming_private_endpoint_nsg_ids) == 0 ? {
    for pair in setproduct(var.streaming_allowed_client_cidrs, toset([443, 9092])) : "${pair[0]}:${pair[1]}" => {
      cidr = pair[0]
      port = pair[1]
    }
  } : {}

  network_security_group_id = oci_core_network_security_group.streaming_endpoint[0].id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = each.value.cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = false

  tcp_options {
    destination_port_range {
      min = each.value.port
      max = each.value.port
    }
  }
}

# Last successful validation: 2026-10-15 | Terraform init/validate and 4 plan-only regression cases | oracle/oci 9.9.0.
# Scope: v0.2.0 nested sources; no live provisioning or endpoint traffic verification.
# Evidence: tests/configuration-regressions.tftest.hcl; local Terraform test results.
module "streaming" {
  source = "git::https://github.com/leandro-michelino/oci-landingzones.git//blueprints/extensions/streaming?ref=v0.2.0"

  tenancy_ocid               = var.tenancy_ocid
  current_user_ocid          = var.current_user_ocid
  region                     = var.region
  home_region                = var.home_region
  oci_config_profile         = var.oci_config_profile
  compartment_ocid           = local.target_compartment_ocid
  org                        = var.org
  environment                = var.environment
  region_key                 = var.region_key
  enable_streaming           = var.enable_streaming
  create_stream_pool         = var.create_stream_pool
  stream_pool_name           = var.stream_pool_name
  stream_pool_id             = var.stream_pool_id
  kms_key_id                 = var.streaming_kms_key_id != null ? var.streaming_kms_key_id : try(module.vault.key_ids["default"], null)
  private_endpoint_subnet_id = var.streaming_private_endpoint_subnet_id != null ? var.streaming_private_endpoint_subnet_id : try(module.network.subnet_ids["endpoints"], null)
  private_endpoint_nsg_ids   = length(var.streaming_private_endpoint_nsg_ids) > 0 ? var.streaming_private_endpoint_nsg_ids : try(toset([oci_core_network_security_group.streaming_endpoint[0].id]), toset([]))
  streams                    = var.streams
  defined_tags               = var.defined_tags
  freeform_tags              = local.common_freeform_tags
}
