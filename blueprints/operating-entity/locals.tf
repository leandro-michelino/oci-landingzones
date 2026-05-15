# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  blueprint_name          = "operating-entity"
  name_prefix             = "${var.org}-${var.environment}-${var.region_key}"
  parent_compartment_ocid = coalesce(var.parent_compartment_ocid, var.tenancy_ocid)
  entity_key              = replace(lower(var.entity_code), "/[^a-z0-9]/", "-")
  entity_name             = coalesce(var.entity_name, upper(var.entity_code))
  root_compartment_name   = coalesce(var.root_compartment_name, "${local.name_prefix}-cmp-oe-${local.entity_key}")

  workload_compartments = {
    for key, compartment in var.workload_compartments : key => {
      description   = compartment.description
      enable_delete = try(compartment.enable_delete, var.enable_delete)
    }
  }

  group_definitions = {
    entity_admins = {
      name        = coalesce(var.admin_group_name, "${local.name_prefix}-grp-${local.entity_key}-admins")
      description = "Delegated administrators for operating entity ${local.entity_name}."
    }
    entity_auditors = {
      name        = coalesce(var.auditor_group_name, "${local.name_prefix}-grp-${local.entity_key}-auditors")
      description = "Read-only auditors for operating entity ${local.entity_name}."
    }
  }

  entity_compartment_names = module.compartments.compartment_names
  entity_root_name         = module.compartments.root_compartment_name
  entity_child_paths = {
    for key, name in module.compartments.child_compartment_names : key => "${local.entity_root_name}:${name}"
  }
  entity_policy_paths = concat([local.entity_root_name], values(local.entity_child_paths))

  policy_definitions = {
    entity_admins = {
      description = "Delegated administrators can manage resources inside operating entity ${local.entity_name}."
      statements = [
        for path in local.entity_policy_paths :
        "Allow group ${module.groups.group_names["entity_admins"]} to manage all-resources in compartment ${path}"
      ]
    }
    entity_auditors = {
      description = "Delegated auditors can read resources inside operating entity ${local.entity_name}."
      statements = [
        for path in local.entity_policy_paths :
        "Allow group ${module.groups.group_names["entity_auditors"]} to read all-resources in compartment ${path}"
      ]
    }
  }
}
