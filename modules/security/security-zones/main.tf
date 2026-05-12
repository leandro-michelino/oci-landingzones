# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
data "oci_cloud_guard_security_recipes" "this" {
  for_each = local.recipe_lookups

  compartment_id = each.value.compartment_ocid
  display_name   = each.value.display_name
  state          = "ACTIVE"
}

resource "oci_cloud_guard_security_zone" "this" {
  for_each = local.security_zones

  compartment_id                      = each.value.compartment_ocid
  display_name                        = coalesce(each.value.display_name, "${local.name_prefix}-sz-${each.key}")
  description                         = coalesce(each.value.description, "Landing zone Security Zone ${each.key} managed by Terraform.")
  security_zone_recipe_id             = each.value.security_zone_recipe_id != null ? each.value.security_zone_recipe_id : try(data.oci_cloud_guard_security_recipes.this[each.key].security_recipe_collection[0].items[0].id, null)
  is_inheritance_after_delete_enabled = each.value.is_inheritance_after_delete_enabled
  defined_tags                        = var.defined_tags
  freeform_tags                       = local.common_freeform_tags
}
