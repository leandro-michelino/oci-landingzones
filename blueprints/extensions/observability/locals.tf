# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  blueprint_name          = "observability"
  name_prefix             = lower(join("-", compact([var.org, var.environment, var.region_key, "observability"])))
  target_compartment_ocid = coalesce(var.compartment_ocid, var.tenancy_ocid)
  common_freeform_tags = merge(var.freeform_tags, {
    ManagedBy = "Terraform"
    Blueprint = local.blueprint_name
  })
  log_analytics_namespace    = var.enable_log_analytics_namespace ? oci_log_analytics_namespace.this[0].namespace : var.log_analytics_namespace
  log_group_name             = coalesce(var.log_group_name, "${local.name_prefix}-logs")
  apm_domain_name            = coalesce(var.apm_domain_name, "${local.name_prefix}-apm")
  opsi_private_endpoint_name = coalesce(var.opsi_private_endpoint_name, "${local.name_prefix}-opsi-pe")
}
