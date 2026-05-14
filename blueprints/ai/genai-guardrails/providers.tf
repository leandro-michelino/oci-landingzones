# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
provider "oci" {
  region              = var.region
  config_file_profile = var.oci_config_profile
}

provider "oci" {
  alias               = "home"
  region              = coalesce(var.home_region, var.region)
  config_file_profile = var.oci_config_profile
}
