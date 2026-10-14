provider "oci" {
  # Preserve OCI provenance tags while managing other configured tags.
  ignore_defined_tags = ["Oracle-Tags.CreatedBy", "Oracle-Tags.CreatedOn"]
  tenancy_ocid        = var.tenancy_ocid
  region              = var.region
  config_file_profile = var.oci_config_profile
}
