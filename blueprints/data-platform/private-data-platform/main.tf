# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
data "oci_objectstorage_namespace" "this" {
  compartment_id = var.tenancy_ocid
}

module "network" {
  source = "../../../blueprints/networking/standalone-private-endpoint-only"

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

module "vault" {
  source = "../../../modules/security/vault"

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
  namespace             = data.oci_objectstorage_namespace.this.namespace
  access_type           = "NoPublicAccess"
  auto_tiering          = var.bucket_auto_tiering
  kms_key_id            = var.bucket_kms_key_id != null ? var.bucket_kms_key_id : try(module.vault.key_ids["default"], null)
  object_events_enabled = var.enable_bucket_events
  storage_tier          = var.bucket_storage_tier
  versioning            = var.enable_bucket_versioning ? "Enabled" : "Disabled"
  defined_tags          = var.defined_tags
  freeform_tags         = local.common_freeform_tags
}

resource "oci_objectstorage_private_endpoint" "data" {
  count = var.enable_object_storage_private_endpoint ? 1 : 0

  compartment_id = local.target_compartment_ocid
  name           = local.private_endpoint_name
  namespace      = data.oci_objectstorage_namespace.this.namespace
  prefix         = var.private_endpoint_prefix
  subnet_id      = coalesce(var.private_endpoint_subnet_id, try(module.network.subnet_ids[var.private_endpoint_subnet_key], null))
  nsg_ids        = tolist(var.private_endpoint_nsg_ids)
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags

  access_targets {
    bucket         = local.data_bucket_name
    compartment_id = local.target_compartment_ocid
    namespace      = data.oci_objectstorage_namespace.this.namespace
  }

  depends_on = [oci_objectstorage_bucket.data]
}

module "streaming" {
  source = "../../../blueprints/extensions/streaming"

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
  private_endpoint_subnet_id = var.streaming_private_endpoint_subnet_id
  private_endpoint_nsg_ids   = var.streaming_private_endpoint_nsg_ids
  streams                    = var.streams
  defined_tags               = var.defined_tags
  freeform_tags              = local.common_freeform_tags
}
