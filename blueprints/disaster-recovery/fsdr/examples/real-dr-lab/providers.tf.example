provider "oci" {
  tenancy_ocid        = var.tenancy_ocid
  region              = var.region
  config_file_profile = var.oci_config_profile
}

provider "oci" {
  alias               = "standby"
  tenancy_ocid        = var.tenancy_ocid
  region              = var.standby_region
  config_file_profile = var.oci_config_profile
}
