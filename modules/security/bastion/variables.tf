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

variable "cis_level" {
  description = "CIS OCI Benchmark profile for the landing zone. Use level1 for baseline controls or level2 for stricter controls."
  type        = string
  default     = null

  validation {
    condition     = var.cis_level == null ? true : contains(["level1", "level2"], lower(var.cis_level))
    error_message = "cis_level must be either level1 or level2."
  }
}

variable "enable_bastion" {
  description = "Create an OCI Bastion service endpoint."
  type        = bool
  default     = false
}

variable "bastion_label" {
  description = "Short semantic label for the bastion."
  type        = string
  default     = "hub"
}

variable "target_subnet_id" {
  description = "Private subnet OCID where the bastion endpoint is placed."
  type        = string
  default     = null
}

variable "bastion_type" {
  description = "OCI Bastion type."
  type        = string
  default     = "STANDARD"
}

variable "client_cidr_block_allow_list" {
  description = "Client CIDR blocks allowed to create bastion sessions."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "max_session_ttl_in_seconds" {
  description = "Maximum session TTL for bastion sessions."
  type        = number
  default     = 3600
}

variable "dns_proxy_status" {
  description = "DNS proxy status for the bastion."
  type        = string
  default     = "DISABLED"
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
