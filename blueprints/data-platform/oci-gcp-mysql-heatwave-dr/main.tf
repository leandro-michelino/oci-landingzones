# Last successful validation: 2026-10-28 | Terraform validate and 2 mocked plans | oracle/oci 9.11.0.
# Scope: local schema and configuration contracts only; no cloud provisioning, connectivity, replication or workload test.
# Evidence: tests/safety.tftest.hcl; docs/multicloud/GCP-COUNTERPARTS-20261028.md.
resource "terraform_data" "guard" {
  lifecycle {
    precondition {
      condition     = !var.enable_oci || var.costs_approved
      error_message = "Review explicit cost, service, network and connectivity prerequisites before creation."
    }
    precondition {
      condition     = !var.enable_database || (var.enable_oci && var.availability_domain != null && var.db_shape_name != null && var.admin_password != null)
      error_message = "Review explicit cost, service, network and connectivity prerequisites before creation."
    }
    precondition {
      condition     = !var.enable_heatwave || var.enable_database
      error_message = "Review explicit cost, service, network and connectivity prerequisites before creation."
    }
  }
}
module "mysql" {
  source                  = "git::https://github.com/leandro-michelino/oci-landingzones.git//blueprints/data-platform/mysql-heatwave?ref=1d95764bd67c1629452af3b95acd51ae5b60b51d"
  tenancy_ocid            = var.tenancy_ocid
  current_user_ocid       = var.current_user_ocid
  compartment_ocid        = var.compartment_ocid
  region                  = var.region
  home_region             = var.home_region
  oci_config_profile      = var.oci_config_profile
  org                     = var.org
  environment             = var.environment
  region_key              = var.region_key
  create_private_network  = var.enable_oci && var.costs_approved
  vcn_cidr_block          = var.oci_vcn_cidr
  subnet_cidr_block       = var.oci_subnet_cidr
  allowed_client_cidrs    = [var.peer_cidr]
  create_db_system        = var.enable_oci && var.costs_approved && var.enable_database
  create_heatwave_cluster = var.enable_oci && var.costs_approved && var.enable_database && var.enable_heatwave
  availability_domain     = var.availability_domain
  db_shape_name           = var.db_shape_name
  admin_username          = var.admin_username
  admin_password          = var.admin_password
}
