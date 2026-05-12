locals {
  blueprint_name = "networking-hub-spoke-with-transit-routing-nva-ha"
  name_prefix    = "${var.org}-${var.environment}-${var.region_key}"
}
