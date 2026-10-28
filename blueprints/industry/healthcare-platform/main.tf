# Last successful validation: 2026-10-28 | Terraform validate and 10 mocked plans | oracle/oci 9.11.0.
# Evidence: docs/HEALTHCARE-PLATFORM-20261028.md; tests/configuration-regressions.tftest.hcl.
# Scope: project infrastructure only; no clinical application, identity federation or live validation.
resource "terraform_data" "guard" {
  input = { foundation = var.enable_foundation, application = var.enable_application, database = var.enable_database, documents = var.enable_documents
  }
  lifecycle {
    precondition {
      condition     = !var.enable_foundation || var.costs_approved
      error_message = "Foundation creation requires explicit costs_approved=true."

    }
    precondition {
      condition     = !(var.enable_application || var.enable_database || var.enable_documents) || var.enable_foundation
      error_message = "Application, database and document creation require the private foundation."

    }
    precondition {
      condition     = !(var.enable_application || var.enable_database || var.enable_documents) || local.key_ready
      error_message = "Workloads require an existing KMS key and acknowledged KMS permissions."

    }
    precondition {
      condition     = !var.enable_application || (length(var.application_instances) > 0 && var.tls_public_certificate != null && var.tls_private_key != null && length(var.backend_trusted_ca_ids) > 0 && var.boot_volume_backup_policy_id != null && var.drg_id != null && length(var.hospital_client_cidrs) > 0)
      error_message = "Application creation requires approved images/ADs, frontend TLS, backend CA IDs, backup policy, existing DRG and hospital client CIDRs."

    }
    precondition {
      condition     = !var.enable_database || var.database_admin_password != null
      error_message = "Database creation requires an ADMIN password supplied through a protected channel."

    }
    precondition {
      condition     = toset(keys(var.subnet_cidrs)) == local.namespaces && alltrue([for r in values(local.ranges) : r.first >= 0 && r.last >= 0]) && alltrue([for k, r in local.ranges : k == "vcn" || (r.first >= local.ranges.vcn.first && r.last <= local.ranges.vcn.last)]) && alltrue(flatten([for a, x in var.subnet_cidrs : [for b, y in var.subnet_cidrs : a == b || (local.ranges[a].last < local.ranges[b].first || local.ranges[b].last < local.ranges[a].first)]]))
      error_message = "Use exactly three valid, non-overlapping IPv4 subnets (ingress/application/database) inside the VCN."

    }
    precondition {
      condition     = alltrue([for cidr in var.hospital_client_cidrs : can(cidrnetmask(cidr)) && try(tonumber(split("/", cidr)[1]) > 0, false) && try(local.ranges.vcn.last < sum([for i, octet in split(".", cidrhost(cidr, 0)) : tonumber(octet) * pow(256, 3 - i)]) || local.ranges.vcn.first > sum([for i, octet in split(".", cidrhost(cidr, -1)) : tonumber(octet) * pow(256, 3 - i)]), false)])
      error_message = "Hospital prefixes must be explicit IPv4 ranges outside the project VCN; Internet-wide and overlapping prefixes are rejected."

    }
    precondition {
      condition     = var.database_backup_days >= 1 && var.database_backup_days <= 60 && floor(var.database_backup_days) == var.database_backup_days
      error_message = "Database backup retention must be an integer from 1 through 60 days."

    }

  }
}
resource "oci_core_vcn" "this" {
  count          = local.foundation ? 1 : 0
  compartment_id = var.compartment_ocid
  cidr_block     = var.vcn_cidr
  display_name   = "${local.name_prefix}-vcn-healthcare"
  dns_label      = "healthcare"
  defined_tags   = var.defined_tags
  freeform_tags  = local.tags
  depends_on     = [terraform_data.guard]
}
data "oci_core_services" "regional" {
  count = local.foundation ? 1 : 0
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true

  }
}
resource "oci_core_service_gateway" "this" {
  count          = local.foundation ? 1 : 0
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this[0].id
  display_name   = "${local.name_prefix}-sgw-healthcare"
  services {
    service_id = data.oci_core_services.regional[0].services[0].id
  }
  defined_tags  = var.defined_tags
  freeform_tags = local.tags
}
resource "oci_core_drg_attachment" "hospital" {
  count        = local.foundation && var.drg_id != null ? 1 : 0
  drg_id       = var.drg_id
  display_name = "${local.name_prefix}-drga-hospital"
  network_details {
    id   = oci_core_vcn.this[0].id
    type = "VCN"

  }
  defined_tags  = var.defined_tags
  freeform_tags = local.tags
}
resource "oci_core_route_table" "private" {
  count          = local.foundation ? 1 : 0
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this[0].id
  display_name   = "${local.name_prefix}-rt-healthcare"
  route_rules {
    destination       = data.oci_core_services.regional[0].services[0].cidr_block
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.this[0].id

  }
  dynamic "route_rules" {
    for_each = var.drg_id != null ? var.hospital_client_cidrs : toset([])
    content {
      destination       = route_rules.value
      destination_type  = "CIDR_BLOCK"
      network_entity_id = var.drg_id

    }

  }
  defined_tags  = var.defined_tags
  freeform_tags = local.tags
}
resource "oci_core_security_list" "empty" {
  #checkov:skip=CKV_OCI_16:Attached empty list; stateful NSG rules provide explicit application access, without SSH ingress.
  count          = local.foundation ? 1 : 0
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this[0].id
  display_name   = "${local.name_prefix}-sl-empty"
  defined_tags   = var.defined_tags
  freeform_tags  = local.tags
}
resource "oci_core_subnet" "private" {
  for_each                   = local.foundation ? var.subnet_cidrs : {}
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.this[0].id
  cidr_block                 = each.value
  display_name               = "${local.name_prefix}-sn-${each.key}"
  dns_label                  = each.key
  prohibit_public_ip_on_vnic = true
  route_table_id             = oci_core_route_table.private[0].id
  security_list_ids          = [oci_core_security_list.empty[0].id]
  defined_tags               = var.defined_tags
  freeform_tags              = local.tags
}
resource "oci_core_network_security_group" "tier" {
  for_each       = local.foundation ? local.namespaces : toset([])
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this[0].id
  display_name   = "${local.name_prefix}-nsg-${each.key}"
  defined_tags   = var.defined_tags
  freeform_tags  = local.tags
}
resource "oci_core_network_security_group_security_rule" "hospital_https" {
  for_each                  = local.foundation ? var.hospital_client_cidrs : toset([])
  network_security_group_id = oci_core_network_security_group.tier["ingress"].id
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
resource "oci_core_network_security_group_security_rule" "tier" {
  for_each = local.foundation ? {
    lb_app = { owner = "ingress", peer = "application", direction = "EGRESS", port = 443
    }
    app_lb = { owner = "application", peer = "ingress", direction = "INGRESS", port = 443
    }
    app_db = { owner = "application", peer = "database", direction = "EGRESS", port = 1522
    }
    db_app = { owner = "database", peer = "application", direction = "INGRESS", port = 1522
    }

  } : {}
  network_security_group_id = oci_core_network_security_group.tier[each.value.owner].id
  direction                 = each.value.direction
  protocol                  = "6"
  source                    = each.value.direction == "INGRESS" ? oci_core_network_security_group.tier[each.value.peer].id : null
  source_type               = each.value.direction == "INGRESS" ? "NETWORK_SECURITY_GROUP" : null
  destination               = each.value.direction == "EGRESS" ? oci_core_network_security_group.tier[each.value.peer].id : null
  destination_type          = each.value.direction == "EGRESS" ? "NETWORK_SECURITY_GROUP" : null
  stateless                 = false
  tcp_options {
    destination_port_range {
      min = each.value.port
      max = each.value.port

    }
  }
}
resource "oci_core_network_security_group_security_rule" "service_https" {
  count                     = local.foundation ? 1 : 0
  network_security_group_id = oci_core_network_security_group.tier["application"].id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = data.oci_core_services.regional[0].services[0].cidr_block
  destination_type          = "SERVICE_CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      min = 443
      max = 443

    }
  }
}
resource "oci_core_instance" "application" {
  for_each            = local.app ? var.application_instances : {}
  compartment_id      = var.compartment_ocid
  availability_domain = each.value.availability_domain
  display_name        = "${local.name_prefix}-inst-${each.key}"
  shape               = var.application_shape
  shape_config {
    ocpus         = var.application_ocpus
    memory_in_gbs = var.application_memory_gbs

  }
  create_vnic_details {
    subnet_id        = oci_core_subnet.private["application"].id
    assign_public_ip = false
    nsg_ids          = [oci_core_network_security_group.tier["application"].id]

  }
  source_details {
    source_type             = "image"
    source_id               = each.value.image_id
    boot_volume_size_in_gbs = 50
    kms_key_id              = var.kms_key_id

  }
  instance_options {
    are_legacy_imds_endpoints_disabled = true
  }
  defined_tags  = var.defined_tags
  freeform_tags = local.tags
}
resource "oci_core_volume_backup_policy_assignment" "application" {
  for_each  = oci_core_instance.application
  asset_id  = each.value.boot_volume_id
  policy_id = var.boot_volume_backup_policy_id
}
resource "oci_load_balancer_load_balancer" "private" {
  count          = local.app ? 1 : 0
  compartment_id = var.compartment_ocid
  display_name   = "${local.name_prefix}-lb-healthcare"
  shape          = "flexible"
  shape_details {
    minimum_bandwidth_in_mbps = 10
    maximum_bandwidth_in_mbps = 100

  }
  is_private                 = true
  subnet_ids                 = [oci_core_subnet.private["ingress"].id]
  network_security_group_ids = [oci_core_network_security_group.tier["ingress"].id]
  defined_tags               = var.defined_tags
  freeform_tags              = local.tags
}
resource "oci_load_balancer_certificate" "frontend" {
  count              = local.app ? 1 : 0
  load_balancer_id   = oci_load_balancer_load_balancer.private[0].id
  certificate_name   = "healthcare-frontend"
  public_certificate = var.tls_public_certificate
  private_key        = var.tls_private_key
  ca_certificate     = var.tls_ca_certificate
}
resource "oci_load_balancer_backend_set" "application" {
  count            = local.app ? 1 : 0
  load_balancer_id = oci_load_balancer_load_balancer.private[0].id
  name             = "healthcare-https"
  policy           = "ROUND_ROBIN"
  health_checker {
    protocol = "TCP"
    port     = 443

  }
  ssl_configuration {
    verify_peer_certificate           = true
    trusted_certificate_authority_ids = var.backend_trusted_ca_ids
    protocols                         = ["TLSv1.2"]

  }
}
resource "oci_load_balancer_backend" "application" {
  for_each         = oci_core_instance.application
  load_balancer_id = oci_load_balancer_load_balancer.private[0].id
  backendset_name  = oci_load_balancer_backend_set.application[0].name
  ip_address       = each.value.private_ip
  port             = 443
}
resource "oci_load_balancer_listener" "https" {
  count                    = local.app ? 1 : 0
  load_balancer_id         = oci_load_balancer_load_balancer.private[0].id
  name                     = "healthcare-https"
  default_backend_set_name = oci_load_balancer_backend_set.application[0].name
  port                     = 443
  protocol                 = "HTTP"
  ssl_configuration {
    certificate_name = oci_load_balancer_certificate.frontend[0].certificate_name
    protocols        = ["TLSv1.2"]

  }
}
resource "oci_database_autonomous_database" "clinical" {
  count                           = local.database ? 1 : 0
  compartment_id                  = var.compartment_ocid
  display_name                    = "${local.name_prefix}-adb-healthcare"
  db_name                         = var.database_name
  db_workload                     = "OLTP"
  admin_password                  = var.database_admin_password
  compute_model                   = "ECPU"
  compute_count                   = var.database_ecpus
  data_storage_size_in_tbs        = var.database_storage_tbs
  is_auto_scaling_enabled         = false
  is_mtls_connection_required     = true
  is_free_tier                    = false
  license_model                   = "LICENSE_INCLUDED"
  subnet_id                       = oci_core_subnet.private["database"].id
  nsg_ids                         = [oci_core_network_security_group.tier["database"].id]
  private_endpoint_label          = "clinicaldb"
  kms_key_id                      = var.kms_key_id
  backup_retention_period_in_days = var.database_backup_days
  defined_tags                    = var.defined_tags
  freeform_tags                   = local.tags
}
data "oci_objectstorage_namespace" "this" {
  count          = local.documents ? 1 : 0
  compartment_id = var.compartment_ocid
}
resource "oci_objectstorage_bucket" "documents" {
  count          = local.documents ? 1 : 0
  compartment_id = var.compartment_ocid
  namespace      = data.oci_objectstorage_namespace.this[0].namespace
  name           = "${local.name_prefix}-bkt-healthcare-documents"
  access_type    = "NoPublicAccess"
  storage_tier   = "Standard"
  versioning     = "Enabled"
  kms_key_id     = var.kms_key_id
  defined_tags   = var.defined_tags
  freeform_tags  = local.tags
}
resource "oci_logging_log_group" "network" {
  count          = local.foundation ? 1 : 0
  compartment_id = var.compartment_ocid
  display_name   = "${local.name_prefix}-lg-healthcare-network"
  defined_tags   = var.defined_tags
  freeform_tags  = local.tags
}
resource "oci_logging_log" "flow" {
  for_each           = oci_core_subnet.private
  display_name       = "${local.name_prefix}-log-${each.key}"
  log_group_id       = oci_logging_log_group.network[0].id
  log_type           = "SERVICE"
  is_enabled         = true
  retention_duration = 30
  configuration {
    compartment_id = var.compartment_ocid
    source {
      category    = "all"
      resource    = each.value.id
      service     = "flowlogs"
      source_type = "OCISERVICE"

    }

  }
  defined_tags  = var.defined_tags
  freeform_tags = local.tags
}
