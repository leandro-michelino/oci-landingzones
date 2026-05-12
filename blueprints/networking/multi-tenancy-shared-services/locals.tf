locals {
  blueprint_name = "networking-multi-tenancy-shared-services"
  name_prefix    = "${var.org}-${var.environment}-${var.region_key}"
}
