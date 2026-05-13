# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  blueprint_name          = "oke-service-mesh"
  name_prefix             = lower(join("-", compact([var.org, var.environment, var.region_key, "oke-service-mesh"])))
  target_compartment_ocid = coalesce(var.compartment_ocid, var.tenancy_ocid)
  common_freeform_tags = merge(var.freeform_tags, {
    ManagedBy = "Terraform"
    Blueprint = local.blueprint_name
  })
  apm_domain_name = coalesce(var.apm_domain_name, "${local.name_prefix}-mesh-apm")
}
