# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
resource "oci_cloud_guard_cloud_guard_configuration" "this" {
  count = var.enable_cloud_guard ? 1 : 0

  compartment_id        = var.tenancy_ocid
  reporting_region      = coalesce(var.reporting_region, var.region)
  self_manage_resources = var.self_manage_resources
  status                = upper(var.cloud_guard_status)
}

resource "oci_cloud_guard_target" "this" {
  for_each = local.targets

  compartment_id       = coalesce(each.value.compartment_ocid, var.compartment_ocid)
  display_name         = coalesce(each.value.display_name, "${local.name_prefix}-cg-target-${each.key}")
  description          = coalesce(each.value.description, "Cloud Guard target ${each.key} managed by Terraform.")
  target_resource_id   = each.value.target_resource_id
  target_resource_type = each.value.target_resource_type
  defined_tags         = var.defined_tags
  freeform_tags        = local.common_freeform_tags

  dynamic "target_detector_recipes" {
    for_each = each.value.detector_recipe_ids

    content {
      detector_recipe_id = target_detector_recipes.value
    }
  }

  dynamic "target_responder_recipes" {
    for_each = each.value.responder_recipe_ids

    content {
      responder_recipe_id = target_responder_recipes.value
    }
  }

  depends_on = [
    oci_cloud_guard_cloud_guard_configuration.this
  ]
}
