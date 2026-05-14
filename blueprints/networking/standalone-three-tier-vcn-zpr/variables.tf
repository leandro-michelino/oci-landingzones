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
  description = "Compartment OCID where the standalone VCN is deployed. Defaults to tenancy_ocid for simple tests."
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
