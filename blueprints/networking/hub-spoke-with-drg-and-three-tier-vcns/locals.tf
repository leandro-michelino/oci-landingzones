locals {
  blueprint_name = "networking-hub-spoke-with-drg-and-three-tier-vcns"
  name_prefix    = "${var.org}-${var.environment}-${var.region_key}"
}
