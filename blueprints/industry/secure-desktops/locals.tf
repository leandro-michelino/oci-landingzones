# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  blueprint_name          = "secure-desktops"
  name_prefix             = lower(join("-", compact([var.org, var.environment, var.region_key, "desktops"])))
  target_compartment_ocid = coalesce(var.compartment_ocid, var.tenancy_ocid)
  policy_compartment_ocid = coalesce(var.policy_compartment_ocid, var.tenancy_ocid)
  desktop_pool_name       = coalesce(var.desktop_pool_display_name, "${local.name_prefix}-pool")
  desktop_pool_id         = var.create_desktop_pool ? try(oci_desktops_desktop_pool.this[0].id, null) : var.desktop_pool_id
  desktop_pool_byol_tags = var.windows_10_11_byol_acknowledged ? {
    "oci:desktops:enable_byol" = "true"
  } : {}

  common_freeform_tags = merge(var.freeform_tags, {
    ManagedBy = "Terraform"
    Blueprint = local.blueprint_name
  })
  desktop_pool_freeform_tags = merge(local.common_freeform_tags, local.desktop_pool_byol_tags)
}
