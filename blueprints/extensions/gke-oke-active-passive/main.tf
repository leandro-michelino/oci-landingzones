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
      condition     = !var.enable_oci || (var.oci_vcn_id != null && var.oci_subnet_id != null && var.kubernetes_version != null)
      error_message = "Review explicit cost, service, network and connectivity prerequisites before creation."
    }
    precondition {
      condition     = !var.enable_nodes || (var.enable_oci && var.node_shape != null && var.node_image_id != null && length(var.node_subnet_ids) > 0)
      error_message = "Review explicit cost, service, network and connectivity prerequisites before creation."
    }
  }
}
module "oke" {
  source                     = "git::https://github.com/leandro-michelino/oci-landingzones.git//blueprints/extensions/oke?ref=1d95764bd67c1629452af3b95acd51ae5b60b51d"
  tenancy_ocid               = var.tenancy_ocid
  current_user_ocid          = var.current_user_ocid
  compartment_ocid           = var.compartment_ocid
  region                     = var.region
  home_region                = var.home_region
  oci_config_profile         = var.oci_config_profile
  org                        = var.org
  environment                = var.environment
  region_key                 = var.region_key
  enable_cluster             = var.enable_oci && var.costs_approved
  enable_node_pool           = var.enable_oci && var.costs_approved && var.enable_nodes
  kubernetes_version         = var.kubernetes_version
  vcn_id                     = var.oci_vcn_id
  endpoint_subnet_id         = var.oci_subnet_id
  endpoint_public_ip_enabled = false
  node_shape                 = var.node_shape
  node_image_id              = var.node_image_id
  node_subnet_ids            = var.node_subnet_ids
}
