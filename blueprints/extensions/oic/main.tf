# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
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
}

resource "oci_integration_private_endpoint_outbound_connection" "this" {
  count = var.enable_private_outbound_connection ? 1 : 0

  integration_instance_id = local.integration_instance_id
  subnet_id               = var.outbound_subnet_id
  nsg_ids                 = var.outbound_nsg_ids
}
