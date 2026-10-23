# Last successful validation: 2026-10-23 | blueprint Terraform validate | oracle/oci 9.10.0.
# Scope: schema, 4 mocked plans, and DEFAULT Sao Paulo no-change plan; no apply.
# Correction: private outbound attachments now reject missing instance and subnet IDs before apply.
# Evidence: docs/EXTENSIONS-IDENTITY-REVIEW-20261023.md; no OIC instance or connection was deployed.
resource "oci_integration_integration_instance" "this" {
  count = var.enable_integration_instance ? 1 : 0

  compartment_id               = local.target_compartment_ocid
  display_name                 = local.integration_display_name
  integration_instance_type    = var.integration_instance_type
  is_byol                      = var.is_byol
  message_packs                = var.message_packs
  consumption_model            = var.consumption_model
  shape                        = var.shape
  is_file_server_enabled       = var.is_file_server_enabled
  is_visual_builder_enabled    = var.is_visual_builder_enabled
  is_disaster_recovery_enabled = var.is_disaster_recovery_enabled
  data_retention_period        = var.data_retention_period
  domain_id                    = var.domain_id
  idcs_at                      = var.idcs_access_token
  defined_tags                 = var.defined_tags
  freeform_tags                = local.common_freeform_tags

  lifecycle {
    precondition {
      condition = (
        !contains(["STANDARDX", "ENTERPRISEX", "HEALTHCARE"], var.integration_instance_type) ||
        var.domain_id != null ||
        var.idcs_access_token != null
      )
      error_message = "OIC instance types STANDARDX, ENTERPRISEX, and HEALTHCARE require domain_id or idcs_access_token."
    }
  }
}

resource "oci_integration_private_endpoint_outbound_connection" "this" {
  count = var.enable_private_outbound_connection ? 1 : 0

  integration_instance_id = local.integration_instance_id
  subnet_id               = var.outbound_subnet_id
  nsg_ids                 = var.outbound_nsg_ids

  lifecycle {
    # Require a new or existing instance and an explicit outbound subnet.
    precondition {
      condition     = local.integration_instance_id != null
      error_message = "A private outbound connection requires a new OIC instance or existing_integration_instance_id."
    }
    precondition {
      condition     = var.outbound_subnet_id != null
      error_message = "A private outbound connection requires outbound_subnet_id."
    }
  }
}
