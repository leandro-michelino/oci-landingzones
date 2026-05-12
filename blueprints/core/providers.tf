provider "oci" {
  tenancy_ocid        = var.tenancy_ocid
  region              = var.region
  config_file_profile = var.oci_config_profile
}

provider "oci" {
  alias               = "home"
  tenancy_ocid        = var.tenancy_ocid
  region              = coalesce(var.home_region, var.region)
  config_file_profile = var.oci_config_profile
}
