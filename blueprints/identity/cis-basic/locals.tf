locals {
  blueprint_name = "identity-cis-basic"
  name_prefix    = "${var.org}-${var.environment}-${var.region_key}"
}
