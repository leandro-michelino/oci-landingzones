# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  blueprint_name          = "multi-operating-entities"
  name_prefix             = "${var.org}-${var.environment}-${var.region_key}"
  parent_compartment_ocid = coalesce(var.parent_compartment_ocid, var.tenancy_ocid)

  entities = {
    for key, entity in var.operating_entities : key => {
      code                  = replace(lower(coalesce(try(entity.code, null), key)), "/[^a-z0-9]/", "-")
      name                  = coalesce(try(entity.name, null), upper(coalesce(try(entity.code, null), key)))
      parent_compartment_id = coalesce(try(entity.parent_compartment_ocid, null), local.parent_compartment_ocid)
      policy_compartment_id = coalesce(try(entity.policy_compartment_ocid, null), try(entity.parent_compartment_ocid, null), local.parent_compartment_ocid)
      root_name             = coalesce(try(entity.root_compartment_name, null), "${local.name_prefix}-oe-${replace(lower(coalesce(try(entity.code, null), key)), "/[^a-z0-9]/", "-")}")
      child_compartments    = coalesce(try(entity.workload_compartments, null), var.default_workload_compartments)
    }
  }

  group_definition_maps = [
    for key, entity in local.entities : {
      "${key}_admins" = {
        name        = coalesce(try(var.operating_entities[key].admin_group_name, null), "${local.name_prefix}-grp-${entity.code}-admins")
        description = "Delegated administrators for operating entity ${entity.name}."
      }
      "${key}_auditors" = {
        name        = coalesce(try(var.operating_entities[key].auditor_group_name, null), "${local.name_prefix}-grp-${entity.code}-auditors")
        description = "Read-only auditors for operating entity ${entity.name}."
      }
    }
  ]
  group_definitions = length(local.group_definition_maps) == 0 ? {} : merge(local.group_definition_maps...)

  entity_policy_paths = {
    for key, entity in local.entities : key => concat(
      [module.entity_compartments[key].root_compartment_name],
      [for child_name in values(module.entity_compartments[key].child_compartment_names) : "${module.entity_compartments[key].root_compartment_name}:${child_name}"]
    )
  }

  policy_definition_maps = [
    for key, entity in local.entities : {
      "${key}_admins" = {
        compartment_id = entity.policy_compartment_id
        description    = "Delegated administrators can manage resources inside operating entity ${entity.name}."
        statements = [
          for path in local.entity_policy_paths[key] :
          "Allow group ${module.groups.group_names["${key}_admins"]} to manage all-resources in compartment ${path}"
        ]
      }
      "${key}_auditors" = {
        compartment_id = entity.policy_compartment_id
        description    = "Delegated auditors can read resources inside operating entity ${entity.name}."
        statements = [
          for path in local.entity_policy_paths[key] :
          "Allow group ${module.groups.group_names["${key}_auditors"]} to read all-resources in compartment ${path}"
        ]
      }
    }
  ]
  policy_definitions = length(local.policy_definition_maps) == 0 ? {} : merge(local.policy_definition_maps...)
}
