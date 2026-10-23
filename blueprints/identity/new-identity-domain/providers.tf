# Identity domain operations use the tenancy home region and the selected CLI profile.
provider "oci" {
  tenancy_ocid        = var.tenancy_ocid
  region              = coalesce(var.home_region, var.region)
  config_file_profile = var.oci_config_profile
}
