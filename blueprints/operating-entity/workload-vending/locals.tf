# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  blueprint_name          = "workload-vending"
  name_prefix             = "${var.org}-${var.environment}-${var.region_key}"
  parent_compartment_ocid = coalesce(var.parent_compartment_ocid, var.tenancy_ocid)
  workload_key            = replace(lower(var.workload_code), "/[^a-z0-9]/", "-")
  workload_name           = coalesce(var.workload_name, upper(var.workload_code))
  root_compartment_name   = coalesce(var.root_compartment_name, "${local.name_prefix}-wl-${local.workload_key}")

  child_compartments = {
    for key, compartment in var.child_compartments : key => {
      description   = compartment.description
      enable_delete = try(compartment.enable_delete, var.enable_delete)
    }
  }

  group_definitions = {
    workload_admins = {
      name        = coalesce(var.admin_group_name, "${local.name_prefix}-grp-${local.workload_key}-admins")
      description = "Delegated administrators for workload ${local.workload_name}."
    }
    workload_operators = {
      name        = coalesce(var.operator_group_name, "${local.name_prefix}-grp-${local.workload_key}-operators")
      description = "Operators for workload ${local.workload_name}."
    }
    workload_auditors = {
      name        = coalesce(var.auditor_group_name, "${local.name_prefix}-grp-${local.workload_key}-auditors")
      description = "Read-only auditors for workload ${local.workload_name}."
    }
  }

  workload_root_name = module.compartments.root_compartment_name
  workload_child_paths = {
    for key, name in module.compartments.child_compartment_names : key => "${local.workload_root_name}:${name}"
  }
  workload_policy_paths = concat([local.workload_root_name], values(local.workload_child_paths))

  policy_definitions = {
    workload_admins = {
      description = "Workload administrators can manage resources inside workload ${local.workload_name}."
      statements = [
        for path in local.workload_policy_paths :
        "Allow group ${module.groups.group_names["workload_admins"]} to manage all-resources in compartment ${path}"
      ]
    }
    workload_operators = {
      description = "Workload operators can use resources inside workload ${local.workload_name}."
      statements = [
        for path in local.workload_policy_paths :
        "Allow group ${module.groups.group_names["workload_operators"]} to use all-resources in compartment ${path}"
      ]
    }
    workload_auditors = {
      description = "Workload auditors can read resources inside workload ${local.workload_name}."
      statements = [
        for path in local.workload_policy_paths :
        "Allow group ${module.groups.group_names["workload_auditors"]} to read all-resources in compartment ${path}"
      ]
    }
  }
}
