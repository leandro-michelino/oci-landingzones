# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  blueprint_name          = "identity-cis-basic"
  name_prefix             = "${var.org}-${var.environment}-${var.region_key}"
  target_compartment_ocid = coalesce(var.compartment_ocid, var.tenancy_ocid)
  cis_level               = "level1"

  common_freeform_tags = merge(
    var.freeform_tags,
    {
      Blueprint  = local.blueprint_name
      Compliance = "cis-basic"
    }
  )

  default_cis_policies = var.enable_default_policies ? {
    auditors_tenancy_read = {
      description = "CIS baseline auditors can inspect tenancy resources."
      statements = contains(keys(module.groups.group_names), "auditors") ? [
        "Allow group ${module.groups.group_names["auditors"]} to inspect tenancies in tenancy",
        "Allow group ${module.groups.group_names["auditors"]} to read audit-events in tenancy"
      ] : []
    }
    security_admins_tenancy_baseline = {
      description = "CIS baseline security administrators can manage security posture services."
      statements = contains(keys(module.groups.group_names), "security_admins") ? [
        "Allow group ${module.groups.group_names["security_admins"]} to manage cloud-guard-family in tenancy",
        "Allow group ${module.groups.group_names["security_admins"]} to manage vaults in tenancy",
        "Allow group ${module.groups.group_names["security_admins"]} to manage keys in tenancy"
      ] : []
    }
    governance_admins_events = {
      description = "CIS baseline governance administrators can manage audit, logging, events, and budgets."
      statements = contains(keys(module.groups.group_names), "governance_admins") ? [
        "Allow group ${module.groups.group_names["governance_admins"]} to manage logging-family in tenancy",
        "Allow group ${module.groups.group_names["governance_admins"]} to manage ons-family in tenancy",
        "Allow group ${module.groups.group_names["governance_admins"]} to manage budgets in tenancy"
      ] : []
    }
  } : {}
}
