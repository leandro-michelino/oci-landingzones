# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
provider "oci" {
  tenancy_ocid        = var.tenancy_ocid
  region              = var.region
  config_file_profile = var.oci_config_profile
}
