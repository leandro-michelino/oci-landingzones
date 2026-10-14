provider "oci" {
  ignore_defined_tags = ["Oracle-Tags.CreatedBy", "Oracle-Tags.CreatedOn"]
  region              = var.region
  config_file_profile = var.oci_config_profile
}

provider "oci" {
  ignore_defined_tags = ["Oracle-Tags.CreatedBy", "Oracle-Tags.CreatedOn"]
  alias               = "home"
  region              = coalesce(var.home_region, var.region)
  config_file_profile = var.oci_config_profile
}
