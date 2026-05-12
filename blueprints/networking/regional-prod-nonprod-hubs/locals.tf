locals {
  blueprint_name = "regional-prod-nonprod-hubs"
  name_prefix    = "${var.org}-${var.environment}-${var.region_key}"
}
