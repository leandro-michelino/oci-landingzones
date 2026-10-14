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
  description = "Compartment OCID where the standalone VCN is provisioned. Defaults to tenancy_ocid for simple tests."
  type        = string
  default     = null
}

variable "vcn_label" {
  description = "Short label for the workload VCN."
  type        = string
  default     = "zpr"
}

variable "vcn_dns_label" {
  description = "DNS label for the workload VCN."
  type        = string
  default     = "zpr"
}

variable "vcn_cidr_block" {
  description = "CIDR block for the workload VCN."
  type        = string
  default     = "10.30.0.0/16"
}

variable "subnets" {
  description = "Three-tier subnet map."
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
    web = {
      cidr_block                 = "10.30.0.0/24"
      dns_label                  = "web"
      route_table_key            = "public"
      security_list_keys         = ["web"]
      prohibit_internet_ingress  = false
      prohibit_public_ip_on_vnic = false
    }
    app = {
      cidr_block = "10.30.1.0/24"
      dns_label  = "app"
    }
    db = {
      cidr_block = "10.30.2.0/24"
      dns_label  = "db"
    }
  }
}

variable "enable_zpr_configuration" {
  description = "Enable ZPR configuration. Optional because ZPR is a stronger guardrail and should be an intentional choice."
  type        = bool
  default     = false

  validation {
    condition     = !var.enable_zpr_configuration || (var.home_region != null && var.region == var.home_region)
    error_message = "ZPR onboarding is tenancy-wide and requires region to equal the explicitly supplied home_region. Keep onboarding disabled in a workload-region deployment."
  }
}

variable "enable_zpr_policies" {
  description = "Create ZPR policy statements for this VCN."
  type        = bool
  default     = false
}

variable "zpr_policies" {
  description = "ZPR policies keyed by logical name."
  type = map(object({
    name        = string
    description = string
    statements  = list(string)
  }))
  default = {
    tier_guardrails = {
      name        = "three-tier-zpr-guardrails"
      description = "Starter ZPR policy definition for customer-specific micro-segmentation."
      statements  = []
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
    public = {
      route_rules = [
        {
          description        = "Internet ingress and egress for the web tier."
          destination        = "0.0.0.0/0"
          network_entity_key = "igw"
        }
      ]
    }
    private = {
      route_rules = [
        {
          description        = "Controlled outbound internet access."
          destination        = "0.0.0.0/0"
          network_entity_key = "nat"
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
    web = {
      ingress_rules = [
        {
          description = "Allow HTTP to the public web tier."
          protocol    = "6"
          source      = "0.0.0.0/0"
          tcp_options = { min = 80, max = 80 }
        },
        {
          description = "Allow HTTPS to the public web tier."
          protocol    = "6"
          source      = "0.0.0.0/0"
          tcp_options = { min = 443, max = 443 }
        }
      ]
      egress_rules = [
        {
          description = "Allow outbound traffic by default."
          protocol    = "all"
          destination = "0.0.0.0/0"
        }
      ]
    }
    baseline = {
      ingress_rules = []
      egress_rules = [
        {
          description = "Allow outbound traffic by default."
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
