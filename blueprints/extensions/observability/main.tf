# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
resource "oci_log_analytics_namespace" "this" {
  count = var.enable_log_analytics_namespace ? 1 : 0

  compartment_id = local.target_compartment_ocid
  namespace      = var.log_analytics_namespace
  is_onboarded   = var.log_analytics_is_onboarded
}

resource "oci_log_analytics_log_analytics_log_group" "this" {
  count = var.enable_log_group ? 1 : 0

  compartment_id = local.target_compartment_ocid
  namespace      = local.log_analytics_namespace
  display_name   = local.log_group_name
  description    = var.log_group_description
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}

resource "oci_apm_apm_domain" "this" {
  count = var.enable_apm_domain ? 1 : 0

  compartment_id = local.target_compartment_ocid
  display_name   = local.apm_domain_name
  description    = var.apm_domain_description
  is_free_tier   = var.apm_is_free_tier
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}

resource "oci_opsi_operations_insights_private_endpoint" "this" {
  count = var.enable_opsi_private_endpoint ? 1 : 0

  compartment_id      = local.target_compartment_ocid
  display_name        = local.opsi_private_endpoint_name
  description         = var.opsi_private_endpoint_description
  vcn_id              = var.vcn_id
  subnet_id           = var.subnet_id
  nsg_ids             = var.nsg_ids
  is_used_for_rac_dbs = var.opsi_is_used_for_rac_dbs
  defined_tags        = var.defined_tags
  freeform_tags       = local.common_freeform_tags
}
