# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
module "prod_network" {
  source = "git::https://github.com/leandro-michelino/oci-landingzones.git//blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns?ref=v0.1.0"

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

module "nonprod_network" {
  source = "git::https://github.com/leandro-michelino/oci-landingzones.git//blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns?ref=v0.1.0"

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
