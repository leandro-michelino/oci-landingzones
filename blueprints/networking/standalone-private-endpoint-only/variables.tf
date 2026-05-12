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
  description = "Compartment OCID where the private VCN is deployed. Defaults to tenancy_ocid for simple tests."
  type        = string
  default     = null
}

variable "vcn_label" {
  description = "Short label for the private VCN."
  type        = string
  default     = "private"
}

variable "vcn_dns_label" {
  description = "DNS label for the private VCN."
  type        = string
  default     = "private"
}

variable "vcn_cidr_block" {
  description = "CIDR block for the private VCN."
  type        = string
  default     = "10.20.0.0/16"
}

variable "enable_nat_gateway" {
  description = "Allow controlled outbound internet access through NAT. Disabled by default for private-only deployments."
  type        = bool
  default     = false
}

variable "subnets" {
  description = "Private subnet map."
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
    app = {
      cidr_block = "10.20.1.0/24"
      dns_label  = "app"
    }
    data = {
      cidr_block = "10.20.2.0/24"
      dns_label  = "data"
    }
    endpoints = {
      cidr_block = "10.20.3.0/24"
      dns_label  = "endpoints"
    }
  }
}

variable "route_tables" {
  description = "Route tables keyed by logical name."
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
          description        = "Private OCI service access."
          destination_key    = "all-services"
          destination_type   = "SERVICE_CIDR_BLOCK"
          network_entity_key = "sgw"
        }
      ]
    }
  }
}

variable "security_lists" {
  description = "Security lists keyed by logical name."
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
          description = "Allow private outbound traffic; tighten per customer service endpoints."
          protocol    = "all"
          destination = "10.20.0.0/16"
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
