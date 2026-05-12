locals {
  blueprint_name = "networking-hub-spoke-with-dual-region-dr"
  name_prefix    = "${var.org}-${var.environment}-${var.region_key}"
}
