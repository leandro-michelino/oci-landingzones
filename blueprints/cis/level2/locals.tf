locals {
  blueprint_name = "cis-level2"
  cis_level      = "level2"
  name_prefix    = "${var.org}-${var.environment}-${var.region_key}"
}

