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
      condition     = !var.enable_oci || var.oci_subnet_id != null
      error_message = "Review explicit cost, service, network and connectivity prerequisites before creation."
    }
    precondition {
      condition     = !var.enable_deployment || (var.enable_oci && var.adapter_auth_verified && try(startswith(var.oci_adapter_url, "https://"), false) && try(startswith(var.gcp_adapter_url, "https://"), false))
      error_message = "Review explicit cost, service, network and connectivity prerequisites before creation."
    }
  }
}
module "gateway" {
  source             = "git::https://github.com/leandro-michelino/oci-landingzones.git//blueprints/extensions/apigw?ref=1d95764bd67c1629452af3b95acd51ae5b60b51d"
  tenancy_ocid       = var.tenancy_ocid
  current_user_ocid  = var.current_user_ocid
  compartment_ocid   = var.compartment_ocid
  region             = var.region
  home_region        = var.home_region
  oci_config_profile = var.oci_config_profile
  org                = var.org
  environment        = var.environment
  region_key         = var.region_key
  enable_gateway     = var.enable_oci && var.costs_approved
  endpoint_type      = "PRIVATE"
  subnet_id          = var.oci_subnet_id
  enable_deployment  = var.enable_oci && var.costs_approved && var.enable_deployment && var.adapter_auth_verified
  path_prefix        = "/ai"
  routes = [
    { path = "/oci/inference", methods = ["POST"], backend_type = "HTTP_BACKEND", backend_url = var.oci_adapter_url, is_ssl_verify_disabled = false },
    { path = "/gcp/inference", methods = ["POST"], backend_type = "HTTP_BACKEND", backend_url = var.gcp_adapter_url, is_ssl_verify_disabled = false }
  ]
}
