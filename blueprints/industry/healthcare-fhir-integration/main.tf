# Last successful validation: 2026-10-28 | Terraform validate and 11 mocked plans | oracle/oci 9.11.0.
# Scope: local schema/simulated configuration only; no provisioning, tokens, FHIR transactions or clinical validation.
# Evidence: docs/HEALTHCARE-FHIR-20261028.md; tests/configuration-regressions.tftest.hcl.
resource "terraform_data" "guard" {
  input = { foundation = var.enable_foundation, api = var.enable_api, queue = var.enable_queue }
  lifecycle {
    precondition {
      condition     = !var.enable_foundation || var.costs_approved
      error_message = "Foundation creation requires explicit cost approval."
    }
    precondition {
      condition     = !(var.enable_api || var.enable_queue) || var.enable_foundation
      error_message = "API and queue require the private foundation."
    }
    precondition {
      condition     = !var.enable_api || (local.api && can(regex("^https://[^/?#]+(/[^?#]*)?$", var.fhir_backend_url)) && can(regex("^https://", var.jwks_uri)))
      error_message = "API requires an HTTPS backend/JWKS, reviewed backend authorization, trusted issuer/audience values, existing DRG and explicit client/backend/JWKS CIDRs."
    }
    precondition {
      condition     = !var.enable_queue || (var.kms_key_id != null && var.kms_policies_ready)
      error_message = "Queue requires an existing KMS key and reviewed service permissions."
    }
    precondition {
      condition     = toset(keys(var.subnet_cidrs)) == toset(["api", "integration"]) && alltrue([for r in values(local.ranges) : r.first >= 0 && r.last >= 0]) && alltrue([for k, r in local.ranges : k == "vcn" || (r.first >= local.ranges.vcn.first && r.last <= local.ranges.vcn.last)]) && alltrue(flatten([for a, x in var.subnet_cidrs : [for b, y in var.subnet_cidrs : a == b || (local.ranges[a].last < local.ranges[b].first || local.ranges[b].last < local.ranges[a].first)]]))
      error_message = "Use two valid, distinct private api/integration IPv4 subnets inside the VCN."
    }
    precondition {
      condition     = alltrue([for cidr in local.remote_cidrs : can(cidrnetmask(cidr)) && try(tonumber(split("/", cidr)[1]) > 0, false) && try(local.ranges.vcn.last < sum([for i, octet in split(".", cidrhost(cidr, 0)) : tonumber(octet) * pow(256, 3 - i)]) || local.ranges.vcn.first > sum([for i, octet in split(".", cidrhost(cidr, -1)) : tonumber(octet) * pow(256, 3 - i)]), false)])
      error_message = "Remote IPv4 ranges must be explicit, non-Internet-wide and outside the integration VCN."
    }
    precondition {
      condition     = contains(var.allowed_methods, "GET") && length(setsubtract(var.allowed_methods, toset(["GET", "POST", "PUT", "PATCH"]))) == 0 && length(var.fhir_resources) > 0 && alltrue([for r in var.fhir_resources : can(regex("^[A-Z][A-Za-z0-9]+$", r))])
      error_message = "FHIR routes require GET, an explicit resource allowlist and optional POST/PUT/PATCH only; DELETE is not exposed."
    }
    precondition {
      condition     = var.queue_retention_seconds >= 60 && var.queue_retention_seconds <= 604800 && floor(var.queue_retention_seconds) == var.queue_retention_seconds
      error_message = "Queue retention must be an integer between 60 seconds and seven days."
    }
  }
}
resource "terraform_data" "fhir_contract" {
  input = {
    protocol           = "FHIR R4"
    public_path_prefix = "/fhir"
    resource_allowlist = var.fhir_resources
    methods            = var.allowed_methods
    backend            = var.fhir_backend_url
    external_work      = ["FHIR server persistence", "HL7 v2 mapping/ACK/reconciliation", "resource and patient authorization", "message producer/consumer", "clinical audit and consent", "private DNS and DRG transport"]
  }
}
resource "oci_core_vcn" "this" {
  count          = local.foundation ? 1 : 0
  compartment_id = var.compartment_ocid
  cidr_block     = var.vcn_cidr
  display_name   = "${local.name_prefix}-vcn-fhir"
  dns_label      = "fhir"
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
  display_name   = "${local.name_prefix}-sgw-fhir"
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
  display_name   = "${local.name_prefix}-rt-fhir"
  route_rules {
    destination       = data.oci_core_services.regional[0].services[0].cidr_block
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.this[0].id

  }
  dynamic "route_rules" {
    for_each = var.drg_id != null ? local.remote_cidrs : toset([])
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

resource "oci_core_network_security_group" "tier" {
  for_each       = local.foundation ? toset(["api", "integration"]) : toset([])
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this[0].id
  display_name   = "${local.name_prefix}-nsg-${each.key}"
  defined_tags   = var.defined_tags
  freeform_tags  = local.tags
}
resource "oci_core_network_security_group_security_rule" "clients" {
  for_each                  = local.foundation ? var.hospital_client_cidrs : toset([])
  network_security_group_id = oci_core_network_security_group.tier["api"].id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = each.value
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      min = 443
      max = 443
    }
  }
}
resource "oci_core_network_security_group_security_rule" "backends" {
  for_each                  = local.foundation ? setunion(var.fhir_backend_cidrs, var.jwks_cidrs) : toset([])
  network_security_group_id = oci_core_network_security_group.tier["api"].id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = each.value
  destination_type          = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      min = 443
      max = 443
    }
  }
}
resource "oci_core_network_security_group_security_rule" "integration_services" {
  count                     = local.foundation ? 1 : 0
  network_security_group_id = oci_core_network_security_group.tier["integration"].id
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
resource "oci_apigateway_gateway" "fhir" {
  count                      = local.api ? 1 : 0
  compartment_id             = var.compartment_ocid
  display_name               = "${local.name_prefix}-apigw-fhir"
  endpoint_type              = "PRIVATE"
  subnet_id                  = oci_core_subnet.private["api"].id
  network_security_group_ids = [oci_core_network_security_group.tier["api"].id]
  certificate_id             = var.gateway_certificate_id
  dynamic "ca_bundles" {
    for_each = var.ca_bundle_ids
    content {
      type         = "CA_BUNDLE"
      ca_bundle_id = ca_bundles.value
    }
  }
  defined_tags  = var.defined_tags
  freeform_tags = local.tags
}
resource "oci_apigateway_deployment" "fhir" {
  count          = local.api ? 1 : 0
  compartment_id = var.compartment_ocid
  display_name   = "${local.name_prefix}-apidep-fhir"
  gateway_id     = oci_apigateway_gateway.fhir[0].id
  path_prefix    = "/fhir"
  specification {
    request_policies {
      authentication {
        type                        = "TOKEN_AUTHENTICATION"
        token_header                = "Authorization"
        token_auth_scheme           = "Bearer"
        is_anonymous_access_allowed = false
        validation_policy {
          type                        = "REMOTE_JWKS"
          uri                         = var.jwks_uri
          is_ssl_verify_disabled      = false
          max_cache_duration_in_hours = 1
          additional_validation_policy {
            issuers   = var.jwt_issuers
            audiences = var.jwt_audiences
          }
        }
      }
    }
    dynamic "routes" {
      for_each = local.routes
      content {
        path    = routes.value.path
        methods = routes.value.methods
        backend {
          type                       = "HTTP_BACKEND"
          url                        = "${trimsuffix(var.fhir_backend_url, "/")}/${routes.value.backend_path}"
          is_ssl_verify_disabled     = false
          connect_timeout_in_seconds = 10
          read_timeout_in_seconds    = 30
          send_timeout_in_seconds    = 30
        }
      }
    }
  }
  defined_tags  = var.defined_tags
  freeform_tags = local.tags
}
resource "oci_queue_queue" "integration" {
  count                            = local.queue ? 1 : 0
  compartment_id                   = var.compartment_ocid
  display_name                     = "${local.name_prefix}-queue-fhir"
  custom_encryption_key_id         = var.kms_key_id
  retention_in_seconds             = var.queue_retention_seconds
  visibility_in_seconds            = 60
  timeout_in_seconds               = 30
  dead_letter_queue_delivery_count = 5
  defined_tags                     = var.defined_tags
  freeform_tags                    = local.tags
}
