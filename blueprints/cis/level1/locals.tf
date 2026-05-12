locals {
  blueprint_name = "cis-level1"
  cis_level      = "level1"
  name_prefix    = "${var.org}-${var.environment}-${var.region_key}"
}

