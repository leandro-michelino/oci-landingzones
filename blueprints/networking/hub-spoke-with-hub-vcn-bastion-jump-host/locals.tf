locals {
  blueprint_name = "networking-hub-spoke-with-hub-vcn-bastion-jump-host"
  name_prefix    = "${var.org}-${var.environment}-${var.region_key}"
}
