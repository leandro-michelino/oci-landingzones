# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  blueprint_name          = "healthcare-pci"
  name_prefix             = lower(join("-", compact([var.org, var.environment, var.region_key, "healthcare-pci"])))
  target_compartment_ocid = coalesce(var.compartment_ocid, var.tenancy_ocid)
  common_freeform_tags = merge(var.freeform_tags, {
    ManagedBy = "Terraform"
    Blueprint = local.blueprint_name
  })
  policy_compartment_ocid = coalesce(var.policy_compartment_ocid, var.tenancy_ocid)
}
