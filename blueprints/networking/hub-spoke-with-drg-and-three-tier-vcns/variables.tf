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
  description = "Compartment OCID where networking resources are deployed. Defaults to tenancy_ocid for simple tests."
  type        = string
  default     = null
}

variable "hub_vcn_dns_label" {
  description = "DNS label for the hub VCN."
  type        = string
  default     = "hub"
}

variable "hub_vcn_cidr_block" {
  description = "CIDR block for the hub VCN."
  type        = string
  default     = "10.0.0.0/16"
}

variable "hub_subnets" {
  description = "Hub subnet map."
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
  description = "Spoke VCNs keyed by workload or team name."
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
  description = "Route tables applied to all spokes."
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
  description = "Security lists applied to all spokes."
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
          description = "Allow outbound traffic to hub and OCI services."
          protocol    = "all"
          destination = "0.0.0.0/0"
        }
      ]
    }
  }
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
