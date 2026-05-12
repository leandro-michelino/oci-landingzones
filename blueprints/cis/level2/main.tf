module "core" {
  source = "../../core"

  tenancy_ocid       = var.tenancy_ocid
  current_user_ocid  = var.current_user_ocid
  region             = var.region
  home_region        = var.home_region
  oci_config_profile = var.oci_config_profile
  org                = var.org
  environment        = var.environment
  region_key         = var.region_key
  cis_level          = local.cis_level

  parent_compartment_ocid = var.parent_compartment_ocid
  enable_delete           = var.enable_delete
  enable_tagging          = var.enable_tagging
  enable_tag_defaults     = var.enable_tag_defaults

  defined_tags = var.defined_tags
  freeform_tags = merge(
    var.freeform_tags,
    {
      Compliance = "cis-level2"
    }
  )
}
