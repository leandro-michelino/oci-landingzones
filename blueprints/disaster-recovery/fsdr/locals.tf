locals {
  blueprint_name      = "fsdr"
  name_prefix         = "${var.org}-${var.environment}-${var.region_key}"
  standby_name_prefix = "${var.org}-${var.environment}-${var.standby_region_key}"
}
