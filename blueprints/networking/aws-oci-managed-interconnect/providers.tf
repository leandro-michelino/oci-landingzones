provider "oci" {
  tenancy_ocid        = var.tenancy_ocid
  region              = var.region
  config_file_profile = var.oci_config_profile
  ignore_defined_tags = ["Oracle-Tags.CreatedBy", "Oracle-Tags.CreatedOn"]
}
provider "aws" {
  region              = var.aws_region
  profile             = var.aws_profile
  allowed_account_ids = [var.aws_account_id]
}
