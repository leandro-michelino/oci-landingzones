locals {
  blueprint_name          = "core"
  name_prefix             = "${var.org}-${var.environment}-${var.region_key}"
  parent_compartment_ocid = coalesce(var.parent_compartment_ocid, var.tenancy_ocid)

  core_tag_default_values = merge(
    {
      Environment = var.environment
      ManagedBy   = "terraform"
      Owner       = "platform-team"
      Project     = "landingzone"
      Blueprint   = local.blueprint_name
      CostCenter  = "unset"
      CreatedDate = "unset"
    },
    var.tag_default_values
  )

  default_dynamic_groups = {
    platform_automation_instances = {
      description   = "Resource principals for platform automation instances in the governance compartment."
      matching_rule = "ALL {resource.type = 'instance', resource.compartment.id = '${module.compartments.compartment_ids["governance"]}'}"
    }
    workload_instances = {
      description   = "Resource principals for compute instances in the workloads compartment."
      matching_rule = "ALL {resource.type = 'instance', resource.compartment.id = '${module.compartments.compartment_ids["workloads"]}'}"
    }
  }

  core_dynamic_groups = merge(
    var.enable_default_dynamic_groups ? local.default_dynamic_groups : {},
    var.iam_dynamic_groups
  )
}
