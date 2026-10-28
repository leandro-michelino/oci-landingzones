provider "oci" {
  tenancy_ocid        = var.tenancy_ocid
  region              = var.region
  config_file_profile = var.oci_config_profile
  ignore_defined_tags = ["Oracle-Tags.CreatedBy", "Oracle-Tags.CreatedOn"]
}
provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}
