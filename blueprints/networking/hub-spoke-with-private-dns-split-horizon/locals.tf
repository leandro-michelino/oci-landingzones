locals {
  blueprint_name = "networking-hub-spoke-with-private-dns-split-horizon"
  name_prefix    = "${var.org}-${var.environment}-${var.region_key}"
}
