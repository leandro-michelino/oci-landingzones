# Last successful validation: 2026-10-23 | blueprint Terraform validate and DEFAULT Sao Paulo plan | oracle/oci 9.10.0.
# Last successful lifecycle: 2026-10-14 | DEFAULT | sa-saopaulo-1 | apply, drift=0, destroy/API cleanup.
# Historical lifecycle scope: OCI network foundation only; optional services disabled; no workload packet-flow verification.
# Current scope: schema and DEFAULT Sao Paulo plan; no new apply, cleanup, or workload test.
# Evidence: docs/NETWORKING-GOVERNANCE-REVIEW-20261023-71-80.md; prior lifecycle: docs/EPHEMERAL-DEPLOYMENT-EVIDENCE.md.
# Review: Production hub and spoke planned in the selected compartment; one NAT gateway; no packet-flow test.
module "prod_network" {
  source = "git::https://github.com/leandro-michelino/oci-landingzones.git//blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns?ref=d7938f4baef1aa512fc8dcee99a545ec17e0dab2"

  tenancy_ocid       = var.tenancy_ocid
  current_user_ocid  = var.current_user_ocid
  region             = var.region
  home_region        = var.home_region
  oci_config_profile = var.oci_config_profile
  compartment_ocid   = local.target_compartment_ocid
  org                = var.org
  environment        = var.prod_environment
  region_key         = var.region_key
  hub_vcn_cidr_block = "10.40.0.0/16"
  hub_subnets = {
    dmz = {
      cidr_block                 = "10.40.0.0/24"
      dns_label                  = "dmz"
      route_table_key            = "public"
      prohibit_internet_ingress  = false
      prohibit_public_ip_on_vnic = false
    }
    firewall = {
      cidr_block = "10.40.1.0/24"
      dns_label  = "fw"
    }
    shared = {
      cidr_block = "10.40.2.0/24"
      dns_label  = "shared"
    }
  }
  spoke_vcns = {
    prodapp = {
      cidr_block = "10.41.0.0/16"
      dns_label  = "prodapp"
      subnets = {
        web = {
          cidr_block = "10.41.0.0/24"
          dns_label  = "web"
        }
        app = {
          cidr_block = "10.41.1.0/24"
          dns_label  = "app"
        }
        db = {
          cidr_block = "10.41.2.0/24"
          dns_label  = "db"
        }
      }
    }
  }
  defined_tags  = var.defined_tags
  freeform_tags = merge(var.freeform_tags, { EnvironmentClass = "prod" })
}

# Last successful validation: 2026-10-23 | blueprint Terraform validate and DEFAULT Sao Paulo plan | oracle/oci 9.10.0.
# Last successful lifecycle: 2026-10-14 | DEFAULT | sa-saopaulo-1 | apply, drift=0, destroy/API cleanup.
# Historical lifecycle scope: OCI network foundation only; optional services disabled; no workload packet-flow verification.
# Current scope: schema and DEFAULT Sao Paulo plan; no new apply, cleanup, or workload test.
# Evidence: docs/NETWORKING-GOVERNANCE-REVIEW-20261023-71-80.md; prior lifecycle: docs/EPHEMERAL-DEPLOYMENT-EVIDENCE.md.
# Review: Nonproduction hub and spoke planned separately in the same compartment; one NAT gateway; no isolation traffic test.
module "nonprod_network" {
  source = "git::https://github.com/leandro-michelino/oci-landingzones.git//blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns?ref=d7938f4baef1aa512fc8dcee99a545ec17e0dab2"

  tenancy_ocid       = var.tenancy_ocid
  current_user_ocid  = var.current_user_ocid
  region             = var.region
  home_region        = var.home_region
  oci_config_profile = var.oci_config_profile
  compartment_ocid   = local.target_compartment_ocid
  org                = var.org
  environment        = var.nonprod_environment
  region_key         = var.region_key
  hub_vcn_cidr_block = "10.50.0.0/16"
  hub_subnets = {
    dmz = {
      cidr_block                 = "10.50.0.0/24"
      dns_label                  = "dmz"
      route_table_key            = "public"
      prohibit_internet_ingress  = false
      prohibit_public_ip_on_vnic = false
    }
    firewall = {
      cidr_block = "10.50.1.0/24"
      dns_label  = "fw"
    }
    shared = {
      cidr_block = "10.50.2.0/24"
      dns_label  = "shared"
    }
  }
  spoke_vcns = {
    nonprodapp = {
      cidr_block = "10.51.0.0/16"
      dns_label  = "npapp"
      subnets = {
        web = {
          cidr_block = "10.51.0.0/24"
          dns_label  = "web"
        }
        app = {
          cidr_block = "10.51.1.0/24"
          dns_label  = "app"
        }
        db = {
          cidr_block = "10.51.2.0/24"
          dns_label  = "db"
        }
      }
    }
  }
  defined_tags  = var.defined_tags
  freeform_tags = merge(var.freeform_tags, { EnvironmentClass = "nonprod" })
}
