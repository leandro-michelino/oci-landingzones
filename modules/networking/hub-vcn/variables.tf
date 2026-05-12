# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
variable "tenancy_ocid" {
  description = "OCI tenancy OCID."
  type        = string
}

variable "compartment_ocid" {
  description = "Parent compartment OCID for resources managed by this module."
  type        = string
}

variable "region" {
  description = "OCI region name."
  type        = string
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

variable "vcn_label" {
  description = "Short semantic label for the VCN."
  type        = string
  default     = "hub"
}

variable "vcn_display_name" {
  description = "Optional VCN display name override."
  type        = string
  default     = null
}

variable "vcn_dns_label" {
  description = "DNS label for the VCN."
  type        = string
  default     = "hub"
}

variable "vcn_cidr_blocks" {
  description = "CIDR blocks assigned to the VCN."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "drg_id" {
  description = "Optional DRG OCID used by route rules with network_entity_key = drg."
  type        = string
  default     = null
}

variable "enable_internet_gateway" {
  description = "Create an internet gateway for public or DMZ subnets."
  type        = bool
  default     = true
}

variable "enable_nat_gateway" {
  description = "Create a NAT gateway for controlled private outbound access."
  type        = bool
  default     = true
}

variable "enable_service_gateway" {
  description = "Create a service gateway for private OCI service access."
  type        = bool
  default     = true
}

variable "route_entity_ids" {
  description = "Additional route target IDs keyed by logical name."
  type        = map(string)
  default     = {}
}

variable "security_list_ids" {
  description = "Existing security list IDs that subnets can reference by logical key."
  type        = map(string)
  default     = {}
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
    public = {
      route_rules = [
        {
          description        = "Default internet route."
          destination        = "0.0.0.0/0"
          network_entity_key = "igw"
        }
      ]
    }
    private = {
      route_rules = [
        {
          description        = "Controlled internet egress through NAT."
          destination        = "0.0.0.0/0"
          network_entity_key = "nat"
        },
        {
          description        = "Private access to OCI services."
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
          description = "Allow outbound traffic by default; tighten per customer pattern."
          protocol    = "all"
          destination = "0.0.0.0/0"
        }
      ]
    }
  }
}

variable "subnets" {
  description = "Subnets keyed by logical name."
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
    mgmt = {
      cidr_block = "10.0.1.0/24"
      dns_label  = "mgmt"
    }
    services = {
      cidr_block = "10.0.2.0/24"
      dns_label  = "svc"
    }
  }
}

variable "cis_level" {
  description = "CIS OCI Benchmark profile for the landing zone. Use level1 for baseline controls or level2 for stricter controls."
  type        = string
  default     = null

  validation {
    condition     = var.cis_level == null ? true : contains(["level1", "level2"], lower(var.cis_level))
    error_message = "cis_level must be either level1 or level2."
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
