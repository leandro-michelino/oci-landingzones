locals {
  module_name = "iam-policies"
  cis_level   = var.cis_level == null ? null : lower(var.cis_level)
  name_prefix = "${var.org}-${var.environment}-${var.region_key}"
  root_name   = lookup(var.compartment_names, "root", null)

  compartment_paths = local.root_name == null ? {} : {
    for key, name in var.compartment_names : key => key == "root" ? name : "${local.root_name}:${name}"
  }

  default_policy_maps = [
    var.enable_default_policies && contains(keys(var.group_names), "landing_zone_admins") ? {
      landing_zone_admins = {
        description = "Landing zone administrators can manage resources inside the landing zone compartments."
        statements = [
          for path in values(local.compartment_paths) :
          "Allow group ${var.group_names["landing_zone_admins"]} to manage all-resources in compartment ${path}"
        ]
      }
    } : {},
    var.enable_default_policies && contains(keys(var.group_names), "network_admins") && contains(keys(local.compartment_paths), "network") ? {
      network_admins = {
        description = "Network administrators can manage resources inside the landing zone network compartment."
        statements = [
          "Allow group ${var.group_names["network_admins"]} to manage all-resources in compartment ${local.compartment_paths["network"]}"
        ]
      }
    } : {},
    var.enable_default_policies && contains(keys(var.group_names), "security_admins") && contains(keys(local.compartment_paths), "security") ? {
      security_admins = {
        description = "Security administrators can manage resources inside the landing zone security compartment."
        statements = [
          "Allow group ${var.group_names["security_admins"]} to manage all-resources in compartment ${local.compartment_paths["security"]}"
        ]
      }
    } : {},
    var.enable_default_policies && contains(keys(var.group_names), "governance_admins") && contains(keys(local.compartment_paths), "governance") ? {
      governance_admins = {
        description = "Governance administrators can manage resources inside the landing zone governance compartment."
        statements = [
          "Allow group ${var.group_names["governance_admins"]} to manage all-resources in compartment ${local.compartment_paths["governance"]}"
        ]
      }
    } : {},
    var.enable_default_policies && contains(keys(var.group_names), "workload_admins") && contains(keys(local.compartment_paths), "workloads") ? {
      workload_admins = {
        description = "Workload administrators can manage resources inside the landing zone workloads compartment."
        statements = [
          "Allow group ${var.group_names["workload_admins"]} to manage all-resources in compartment ${local.compartment_paths["workloads"]}"
        ]
      }
    } : {},
    var.enable_default_policies && contains(keys(var.group_names), "auditors") ? {
      auditors = {
        description = "Auditors can read resources inside the landing zone compartments."
        statements = [
          for path in values(local.compartment_paths) :
          "Allow group ${var.group_names["auditors"]} to read all-resources in compartment ${path}"
        ]
      }
    } : {},
    var.enable_default_policies && contains(keys(var.dynamic_group_names), "platform_automation_instances") && contains(keys(local.compartment_paths), "governance") ? {
      platform_automation_instances = {
        description = "Platform automation instances can read resources inside the governance compartment."
        statements = [
          "Allow dynamic-group ${var.dynamic_group_names["platform_automation_instances"]} to read all-resources in compartment ${local.compartment_paths["governance"]}"
        ]
      }
    } : {},
    var.enable_default_policies && contains(keys(var.dynamic_group_names), "workload_instances") && contains(keys(local.compartment_paths), "workloads") ? {
      workload_instances = {
        description = "Workload instances can read resources inside the workloads compartment."
        statements = [
          "Allow dynamic-group ${var.dynamic_group_names["workload_instances"]} to read all-resources in compartment ${local.compartment_paths["workloads"]}"
        ]
      }
    } : {}
  ]

  default_policies = merge(local.default_policy_maps...)

  policies = {
    for key, policy in merge(local.default_policies, var.policies) : key => {
      name           = coalesce(try(policy.name, null), "${local.name_prefix}-pol-${replace(key, "_", "-")}")
      compartment_id = coalesce(try(policy.compartment_id, null), var.compartment_ocid)
      description    = policy.description
      statements     = policy.statements
    }
    if length(policy.statements) > 0
  }

  region_key_map = {
    eu-frankfurt-1    = "fra"
    uk-london-1       = "lhr"
    af-johannesburg-1 = "jnb"
    sa-saopaulo-1     = "gru"
    eu-amsterdam-1    = "ams"
    us-ashburn-1      = "iad"
    us-phoenix-1      = "phx"
    me-dubai-1        = "dxb"
    ap-sydney-1       = "syd"
    ap-tokyo-1        = "nrt"
  }
}
