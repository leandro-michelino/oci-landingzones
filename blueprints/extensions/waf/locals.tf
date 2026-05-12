# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  blueprint_name          = "extensions-waf"
  name_prefix             = "${var.org}-${var.environment}-${var.region_key}"
  target_compartment_ocid = coalesce(var.compartment_ocid, var.tenancy_ocid)
  policy_name             = "${local.name_prefix}-wafpol-${var.waf_label}"
  firewall_name           = "${local.name_prefix}-waf-${var.waf_label}"
  waf_policy_id           = var.waf_policy_id != null ? var.waf_policy_id : try(oci_waf_web_app_firewall_policy.this[0].id, null)
  common_freeform_tags = merge(
    var.freeform_tags,
    {
      Blueprint = local.blueprint_name
    }
  )
}
