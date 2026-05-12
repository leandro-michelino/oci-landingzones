locals {
  blueprint_name = "networking-externally-managed-vcns"
  name_prefix    = "${var.org}-${var.environment}-${var.region_key}"
}
