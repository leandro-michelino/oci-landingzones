# Last successful validation: 2026-10-28 | Terraform validate and 2 mocked plans | oracle/oci 9.11.0.
# Scope: local schema and configuration contracts only; no cloud provisioning, connectivity, replication or workload test.
# Evidence: tests/safety.tftest.hcl; docs/multicloud/GCP-COUNTERPARTS-20261028.md.
resource "terraform_data" "guard" {
  lifecycle {
    precondition {
      condition     = !var.enable_oci || var.costs_approved
      error_message = "Review explicit cost, service, network and connectivity prerequisites before creation."
    }
  }
}
module "network" {
  count                   = var.enable_oci && var.costs_approved ? 1 : 0
  source                  = "git::https://github.com/leandro-michelino/oci-landingzones.git//modules/networking/spoke-vcn?ref=1d95764bd67c1629452af3b95acd51ae5b60b51d"
  tenancy_ocid            = var.tenancy_ocid
  compartment_ocid        = var.compartment_ocid
  region                  = var.region
  org                     = var.org
  environment             = var.environment
  region_key              = var.region_key
  enable_internet_gateway = false
  enable_nat_gateway      = false
  enable_service_gateway  = false
  vcn_cidr_blocks         = [var.oci_vcn_cidr]
  route_tables            = { private = { route_rules = [] } }
  security_lists = { private = {
    ingress_rules = [for port in var.allowed_tcp_ports : { protocol = "6", source = var.peer_cidr, tcp_options = { min = port, max = port } }]
    egress_rules  = []
  } }
  subnets = { workload = { cidr_block = var.oci_subnet_cidr, security_list_keys = ["private"], route_table_key = "private", prohibit_internet_ingress = true, prohibit_public_ip_on_vnic = true } }
}
data "oci_objectstorage_namespace" "this" {
  count          = var.enable_oci && var.costs_approved ? 1 : 0
  compartment_id = var.compartment_ocid
}
resource "oci_objectstorage_bucket" "backup" {
  count          = var.enable_oci && var.costs_approved ? 1 : 0
  compartment_id = var.compartment_ocid
  namespace      = data.oci_objectstorage_namespace.this[0].namespace
  name           = "${var.org}-${var.environment}-${var.region_key}-dr-source"
  access_type    = "NoPublicAccess"
  versioning     = "Enabled"
  storage_tier   = "Standard"
}
