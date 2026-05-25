# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
variable "tenancy_ocid" {
  description = "OCI tenancy OCID."
  type        = string
}

variable "current_user_ocid" {
  description = "OCI user OCID used for local execution or bootstrap."
  type        = string
}

variable "region" {
  description = "OCI region name."
  type        = string
}

variable "home_region" {
  description = "OCI tenancy home region."
  type        = string
  default     = null
}

variable "oci_config_profile" {
  description = "Optional OCI CLI config profile for local execution."
  type        = string
  default     = null
}

variable "org" {
  description = "Short organization prefix used in names."
  type        = string
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
}

variable "region_key" {
  description = "Short OCI region key used in resource names."
  type        = string
}

variable "compartment_ocid" {
  description = "Compartment OCID where networking resources are provisioned. Defaults to tenancy_ocid for simple tests."
  type        = string
  default     = null
}

variable "hub_vcn_dns_label" {
  description = "DNS label for the OCI hub VCN."
  type        = string
  default     = "hub"
}

variable "hub_vcn_cidr_block" {
  description = "CIDR block for the OCI hub VCN advertised toward Azure vWAN."
  type        = string
  default     = "10.0.0.0/16"
}

variable "hub_subnets" {
  description = "OCI hub subnet map passed to the base hub-spoke network."
  type = map(object({
    cidr_block                 = string
    display_name               = optional(string)
    dns_label                  = optional(string)
    route_table_key            = optional(string, "private")
    security_list_keys         = optional(set(string), ["baseline"])
    prohibit_internet_ingress  = optional(bool, true)
    prohibit_public_ip_on_vnic = optional(bool, true)
  }))
  default = {
    dmz = {
      cidr_block                 = "10.0.0.0/24"
      dns_label                  = "dmz"
      route_table_key            = "public"
      prohibit_internet_ingress  = false
      prohibit_public_ip_on_vnic = false
    }
    firewall = {
      cidr_block = "10.0.1.0/24"
      dns_label  = "fw"
    }
    shared = {
      cidr_block = "10.0.2.0/24"
      dns_label  = "shared"
    }
  }
}

variable "spoke_vcns" {
  description = "OCI spoke VCNs keyed by workload or team name."
  type = map(object({
    cidr_block = string
    dns_label  = string
    subnets = map(object({
      cidr_block                 = string
      display_name               = optional(string)
      dns_label                  = optional(string)
      route_table_key            = optional(string, "private")
      security_list_keys         = optional(set(string), ["baseline"])
      prohibit_internet_ingress  = optional(bool, true)
      prohibit_public_ip_on_vnic = optional(bool, true)
    }))
  }))
  default = {
    app1 = {
      cidr_block = "10.1.0.0/16"
      dns_label  = "appone"
      subnets = {
        web = {
          cidr_block = "10.1.0.0/24"
          dns_label  = "web"
        }
        app = {
          cidr_block = "10.1.1.0/24"
          dns_label  = "app"
        }
        db = {
          cidr_block = "10.1.2.0/24"
          dns_label  = "db"
        }
      }
    }
  }
}

variable "spoke_route_tables" {
  description = "Route tables applied to all OCI spokes."
  type = map(object({
    display_name = optional(string)
    route_rules = optional(list(object({
      description        = optional(string)
      destination        = optional(string)
      destination_key    = optional(string)
      destination_type   = optional(string, "CIDR_BLOCK")
      network_entity_id  = optional(string)
      network_entity_key = optional(string)
    })), [])
  }))
  default = {
    private = {
      route_rules = [
        {
          description        = "Send non-local traffic to the hub DRG."
          destination        = "0.0.0.0/0"
          network_entity_key = "drg"
        },
        {
          description        = "Private OCI service access."
          destination_key    = "all-services"
          destination_type   = "SERVICE_CIDR_BLOCK"
          network_entity_key = "sgw"
        }
      ]
    }
  }
}

variable "spoke_security_lists" {
  description = "Security lists applied to all OCI spokes."
  type = map(object({
    display_name = optional(string)
    ingress_rules = optional(list(object({
      description  = optional(string)
      protocol     = string
      source       = string
      source_type  = optional(string, "CIDR_BLOCK")
      stateless    = optional(bool, false)
      tcp_options  = optional(object({ min = number, max = number }))
      udp_options  = optional(object({ min = number, max = number }))
      icmp_options = optional(object({ type = number, code = optional(number) }))
    })), [])
    egress_rules = optional(list(object({
      description      = optional(string)
      protocol         = string
      destination      = string
      destination_type = optional(string, "CIDR_BLOCK")
      stateless        = optional(bool, false)
      tcp_options      = optional(object({ min = number, max = number }))
      udp_options      = optional(object({ min = number, max = number }))
      icmp_options     = optional(object({ type = number, code = optional(number) }))
    })), [])
  }))
  default = {
    baseline = {
      ingress_rules = []
      egress_rules = [
        {
          description = "Allow outbound traffic to hub, Azure vWAN, and OCI services."
          protocol    = "all"
          destination = "0.0.0.0/0"
        }
      ]
    }
  }
}

variable "enable_fastconnect" {
  description = "Create OCI FastConnect for the Azure ExpressRoute private path."
  type        = bool
  default     = false
}

variable "enable_ipsec" {
  description = "Create IPSec as a backup or primary multicloud tunnel."
  type        = bool
  default     = false
}

variable "customer_bgp_asn" {
  description = "Customer BGP ASN for FastConnect."
  type        = number
  default     = null
}

variable "provider_service_id" {
  description = "Provider service OCID for partner FastConnect circuits."
  type        = string
  default     = null
}

variable "provider_service_key_name" {
  description = "Provider service key/name supplied by the FastConnect partner."
  type        = string
  default     = null
}

variable "cpe_ip_address" {
  description = "Remote cloud VPN gateway public or private IP address."
  type        = string
  default     = null
}

variable "remote_cloud_cidr_blocks" {
  description = "Remote Azure CIDR blocks routed over IPSec when the optional VPN path is enabled."
  type        = list(string)
  default     = []
}

variable "expressroute_circuit_id" {
  description = "Azure ExpressRoute circuit resource ID used for the OCI-Azure interconnect hand-off."
  type        = string
  default     = null
}

variable "expressroute_circuit_peering_id" {
  description = "Azure ExpressRoute private peering resource ID used by the Azure vWAN ExpressRoute Gateway connection."
  type        = string
  default     = null
}

variable "azure_virtual_wan_id" {
  description = "Azure Virtual WAN resource ID. Populate after the Azure session when Azure creates it, or set an existing vWAN ID."
  type        = string
  default     = null
}

variable "azure_virtual_hub_id" {
  description = "Azure Virtual Hub resource ID. Populate after the Azure session when Azure creates it, or set an existing vHub ID."
  type        = string
  default     = null
}

variable "azure_expressroute_gateway_id" {
  description = "Azure Virtual WAN ExpressRoute Gateway resource ID. Populate after the Azure session when Azure creates it."
  type        = string
  default     = null
}

variable "azure_virtual_hub_region" {
  description = "Azure region for the Virtual WAN and Virtual Hub resources."
  type        = string
  default     = "westeurope"
}

variable "azure_virtual_hub_address_prefix" {
  description = "Azure Virtual Hub address prefix documented in the routing contract."
  type        = string
  default     = "10.88.255.0/24"
}

variable "azure_route_table_name" {
  description = "Azure Virtual Hub route table name expected for OCI transit path advertisement."
  type        = string
  default     = "rt-vhub-oci-transit"
}

variable "azure_vnet_peerings" {
  description = "Azure VNets connected to the Virtual Hub and mapped to OCI spokes for routing governance."
  type = map(object({
    cidr_blocks          = list(string)
    vnet_id              = optional(string)
    subnet_ids           = optional(map(string), {})
    vhub_connection_id   = optional(string)
    route_table_id       = optional(string)
    connected_spoke_keys = optional(set(string), [])
    propagate_to_labels  = optional(set(string), ["oci-transit"])
  }))
  default = {
    app1 = {
      cidr_blocks          = ["10.88.10.0/24"]
      connected_spoke_keys = ["app1"]
    }
  }
}

variable "enable_route_contract_validation" {
  description = "Validate that Azure vNET peerings and ExpressRoute metadata are present in the Terraform contract."
  type        = bool
  default     = false
}

variable "defined_tags" {
  description = "Defined tags applied to resources."
  type        = map(string)
  default     = {}
}

variable "freeform_tags" {
  description = "Freeform tags applied to resources."
  type        = map(string)
  default     = {}
}
