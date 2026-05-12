# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
resource "oci_vulnerability_scanning_host_scan_recipe" "this" {
  for_each = local.host_scan_recipes

  compartment_id = coalesce(each.value.compartment_ocid, var.compartment_ocid)
  display_name   = coalesce(each.value.display_name, "${local.name_prefix}-vss-host-recipe-${each.key}")
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags

  agent_settings {
    scan_level = upper(each.value.agent_scan_level)

    dynamic "agent_configuration" {
      for_each = each.value.agent_configuration == null ? [] : [each.value.agent_configuration]

      content {
        vendor            = agent_configuration.value.vendor
        vendor_type       = agent_configuration.value.vendor_type
        vault_secret_id   = agent_configuration.value.vault_secret_id
        should_un_install = agent_configuration.value.should_un_install

        dynamic "cis_benchmark_settings" {
          for_each = agent_configuration.value.cis_scan_level == null ? [] : [agent_configuration.value.cis_scan_level]

          content {
            scan_level = upper(cis_benchmark_settings.value)
          }
        }

        dynamic "endpoint_protection_settings" {
          for_each = agent_configuration.value.endpoint_scan_level == null ? [] : [agent_configuration.value.endpoint_scan_level]

          content {
            scan_level = upper(endpoint_protection_settings.value)
          }
        }
      }
    }
  }

  port_settings {
    scan_level = upper(each.value.port_scan_level)
  }

  schedule {
    type        = upper(each.value.schedule_type)
    day_of_week = each.value.day_of_week == null ? null : upper(each.value.day_of_week)
  }

  dynamic "application_settings" {
    for_each = each.value.application_settings == null ? [] : [each.value.application_settings]

    content {
      application_scan_recurrence = application_settings.value.application_scan_recurrence
      is_enabled                  = application_settings.value.is_enabled

      dynamic "folders_to_scan" {
        for_each = application_settings.value.folders_to_scan

        content {
          folder          = folders_to_scan.value.folder
          operatingsystem = folders_to_scan.value.operatingsystem
        }
      }
    }
  }
}

resource "oci_vulnerability_scanning_host_scan_target" "this" {
  for_each = local.host_scan_targets

  compartment_id        = coalesce(each.value.compartment_ocid, var.compartment_ocid)
  target_compartment_id = each.value.target_compartment_ocid
  host_scan_recipe_id   = each.value.host_scan_recipe_id != null ? each.value.host_scan_recipe_id : oci_vulnerability_scanning_host_scan_recipe.this[each.value.host_scan_recipe_key].id
  display_name          = coalesce(each.value.display_name, "${local.name_prefix}-vss-host-target-${each.key}")
  description           = coalesce(each.value.description, "Landing zone host scan target ${each.key} managed by Terraform.")
  instance_ids          = length(each.value.instance_ids) > 0 ? tolist(each.value.instance_ids) : null
  defined_tags          = var.defined_tags
  freeform_tags         = local.common_freeform_tags
}

resource "oci_vulnerability_scanning_container_scan_recipe" "this" {
  for_each = local.container_scan_recipes

  compartment_id = coalesce(each.value.compartment_ocid, var.compartment_ocid)
  display_name   = coalesce(each.value.display_name, "${local.name_prefix}-vss-container-recipe-${each.key}")
  image_count    = each.value.image_count
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags

  scan_settings {
    scan_level = upper(each.value.scan_level)
  }
}

resource "oci_vulnerability_scanning_container_scan_target" "this" {
  for_each = local.container_scan_targets

  compartment_id           = coalesce(each.value.compartment_ocid, var.compartment_ocid)
  container_scan_recipe_id = each.value.container_scan_recipe_id != null ? each.value.container_scan_recipe_id : oci_vulnerability_scanning_container_scan_recipe.this[each.value.container_scan_recipe_key].id
  display_name             = coalesce(each.value.display_name, "${local.name_prefix}-vss-container-target-${each.key}")
  description              = coalesce(each.value.description, "Landing zone container scan target ${each.key} managed by Terraform.")
  defined_tags             = var.defined_tags
  freeform_tags            = local.common_freeform_tags

  target_registry {
    compartment_id = each.value.registry_compartment_ocid
    repositories   = length(each.value.repositories) > 0 ? tolist(each.value.repositories) : null
    type           = upper(each.value.registry_type)
    url            = each.value.url
  }
}
