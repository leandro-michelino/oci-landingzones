# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
resource "oci_core_vcn" "gateway" {
  count = var.enable_oci_gateway_network ? 1 : 0

  compartment_id = local.target_compartment_ocid
  cidr_block     = var.oci_gateway_vcn_cidr
  display_name   = local.gateway_vcn_name
  defined_tags   = local.defined_tags
  freeform_tags  = local.common_freeform_tags
}

resource "oci_core_internet_gateway" "gateway" {
  count = var.enable_oci_gateway_network ? 1 : 0

  compartment_id = local.target_compartment_ocid
  vcn_id         = oci_core_vcn.gateway[0].id
  display_name   = local.gateway_igw_name
  enabled        = true
  defined_tags   = local.defined_tags
  freeform_tags  = local.common_freeform_tags
}

resource "oci_core_route_table" "gateway" {
  count = var.enable_oci_gateway_network ? 1 : 0

  compartment_id = local.target_compartment_ocid
  vcn_id         = oci_core_vcn.gateway[0].id
  display_name   = local.gateway_rt_name
  defined_tags   = local.defined_tags
  freeform_tags  = local.common_freeform_tags

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.gateway[0].id
  }
}

resource "oci_core_security_list" "gateway" {
  count = var.enable_oci_gateway_network ? 1 : 0

  compartment_id = local.target_compartment_ocid
  vcn_id         = oci_core_vcn.gateway[0].id
  display_name   = local.gateway_sl_name
  defined_tags   = local.defined_tags
  freeform_tags  = local.common_freeform_tags

  egress_security_rules {
    protocol         = "all"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
  }

  ingress_security_rules {
    protocol = "6"
    source   = var.oci_gateway_ingress_allowed_cidr
    tcp_options {
      min = 80
      max = 80
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = var.oci_gateway_ingress_allowed_cidr
    tcp_options {
      min = 443
      max = 443
    }
  }
}

resource "oci_core_subnet" "gateway" {
  count = var.enable_oci_gateway_network ? 1 : 0

  cidr_block        = var.oci_gateway_subnet_cidr
  compartment_id    = local.target_compartment_ocid
  vcn_id            = oci_core_vcn.gateway[0].id
  display_name      = local.gateway_subnet_name
  route_table_id    = oci_core_route_table.gateway[0].id
  security_list_ids = [oci_core_security_list.gateway[0].id]

  prohibit_public_ip_on_vnic = false
  defined_tags               = local.defined_tags
  freeform_tags              = local.common_freeform_tags
}

resource "terraform_data" "oci_network_contract" {
  input = {
    enabled        = var.enable_oci_gateway_network
    vcn_id         = try(oci_core_vcn.gateway[0].id, null)
    subnet_id      = try(oci_core_subnet.gateway[0].id, null)
    route_table_id = try(oci_core_route_table.gateway[0].id, null)
    security_list  = try(oci_core_security_list.gateway[0].id, null)
  }
}

resource "oci_apigateway_gateway" "this" {
  count = var.create_oci_api_gateway ? 1 : 0

  compartment_id             = local.target_compartment_ocid
  endpoint_type              = var.oci_gateway_endpoint_type
  subnet_id                  = local.oci_gateway_subnet_id_effective
  certificate_id             = var.oci_gateway_certificate_id
  display_name               = local.oci_gateway_name
  network_security_group_ids = var.oci_gateway_network_security_group_ids
  defined_tags               = local.defined_tags
  freeform_tags              = local.common_freeform_tags

  lifecycle {
    precondition {
      condition     = local.oci_gateway_subnet_id_effective != null
      error_message = "When create_oci_api_gateway=true, set a subnet either by enable_oci_gateway_network=true or by oci_gateway_subnet_id."
    }
  }
}

resource "oci_apigateway_deployment" "this" {
  count = var.create_oci_gateway_deployment ? 1 : 0

  compartment_id = local.target_compartment_ocid
  gateway_id     = local.oci_gateway_id_effective
  path_prefix    = var.gateway_path_prefix
  display_name   = local.oci_deployment_name
  defined_tags   = local.defined_tags
  freeform_tags  = local.common_freeform_tags

  specification {
    dynamic "routes" {
      for_each = local.gateway_routes

      content {
        path    = routes.value.path
        methods = routes.value.methods

        backend {
          type                       = "HTTP_BACKEND"
          url                        = routes.value.url
          connect_timeout_in_seconds = 10
          read_timeout_in_seconds    = 60
          send_timeout_in_seconds    = 60
          is_ssl_verify_disabled     = false
        }
      }
    }
  }

  lifecycle {
    precondition {
      condition     = local.oci_gateway_id_effective != null
      error_message = "When create_oci_gateway_deployment=true, set a gateway via create_oci_api_gateway=true or oci_gateway_id."
    }
    precondition {
      condition = var.require_provider_endpoints ? (
        var.oci_generative_ai_inference_url != null &&
        var.azure_openai_inference_url != null
      ) : true
      error_message = "When require_provider_endpoints=true, set both oci_generative_ai_inference_url and azure_openai_inference_url."
    }
  }
}

resource "oci_apigateway_usage_plan" "this" {
  for_each = var.create_oci_usage_plans ? var.usage_plans : {}

  compartment_id = local.target_compartment_ocid
  display_name   = coalesce(each.value.display_name, "${local.name_prefix}-up-${each.key}")
  defined_tags   = local.defined_tags
  freeform_tags  = local.common_freeform_tags

  entitlements {
    name        = each.value.entitlement_name
    description = each.value.description

    targets {
      deployment_id = coalesce(each.value.target_deployment_id, local.oci_deployment_id_effective)
    }

    dynamic "quota" {
      for_each = each.value.quota_value == null ? [] : [each.value]

      content {
        value               = quota.value.quota_value
        unit                = coalesce(quota.value.quota_unit, "DAY")
        reset_policy        = coalesce(quota.value.quota_reset_policy, "CALENDAR")
        operation_on_breach = coalesce(quota.value.quota_breach_action, "REJECT")
      }
    }

    dynamic "rate_limit" {
      for_each = each.value.rate_limit_value == null ? [] : [each.value]

      content {
        value = rate_limit.value.rate_limit_value
        unit  = coalesce(rate_limit.value.rate_limit_unit, "SECOND")
      }
    }
  }

  lifecycle {
    precondition {
      condition     = local.oci_deployment_id_effective != null
      error_message = "Usage plans require an OCI gateway deployment via create_oci_gateway_deployment=true or oci_gateway_deployment_id."
    }
  }
}

data "oci_objectstorage_namespace" "this" {
  count = var.create_oci_audit_bucket ? 1 : 0

  compartment_id = local.target_compartment_ocid
}

resource "oci_objectstorage_bucket" "audit" {
  count = var.create_oci_audit_bucket ? 1 : 0

  compartment_id        = local.target_compartment_ocid
  namespace             = data.oci_objectstorage_namespace.this[0].namespace
  name                  = local.audit_bucket_name
  access_type           = "NoPublicAccess"
  storage_tier          = var.oci_audit_bucket_storage_tier
  versioning            = var.oci_audit_bucket_versioning
  object_events_enabled = true
  kms_key_id            = var.oci_kms_key_id
  defined_tags          = local.defined_tags
  freeform_tags         = local.common_freeform_tags
}

resource "oci_logging_log_group" "routing" {
  count = var.create_oci_routing_log_group ? 1 : 0

  compartment_id = local.target_compartment_ocid
  display_name   = local.routing_log_group_name
  description    = "Cross-cloud AI gateway routing logs for ${local.name_prefix}."
  defined_tags   = local.defined_tags
  freeform_tags  = local.common_freeform_tags
}

resource "oci_identity_policy" "access" {
  count = length(var.policy_statements) > 0 ? 1 : 0

  provider       = oci.home
  compartment_id = local.policy_compartment_ocid
  name           = "${local.name_prefix}-pol-ai-gw"
  description    = "AI gateway access policy for ${local.name_prefix}."
  statements     = var.policy_statements
  defined_tags   = local.defined_tags
  freeform_tags  = local.common_freeform_tags
}

resource "terraform_data" "connectivity_contract" {
  input = local.connectivity_contract

  lifecycle {
    precondition {
      condition = (
        var.connectivity_mode == "interconnect" &&
        var.fastconnect_virtual_circuit_id != null &&
        var.expressroute_circuit_id != null
        ) || (
        var.connectivity_mode == "without-interconnect" &&
        var.fastconnect_virtual_circuit_id == null &&
        var.expressroute_circuit_id == null
      )
      error_message = "For connectivity_mode=interconnect, set both fastconnect_virtual_circuit_id and expressroute_circuit_id. For connectivity_mode=without-interconnect, keep both values null."
    }
  }
}

resource "terraform_data" "routing_contract" {
  input = local.routing_contract

  lifecycle {
    precondition {
      condition = var.require_provider_endpoints ? (
        var.oci_generative_ai_inference_url != null &&
        var.azure_openai_inference_url != null
      ) : true
      error_message = "Routing contract requires oci_generative_ai_inference_url and azure_openai_inference_url when require_provider_endpoints=true."
    }
  }
}

resource "terraform_data" "azure_contract" {
  input = local.azure_contract
}
