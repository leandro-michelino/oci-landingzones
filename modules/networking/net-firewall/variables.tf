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

variable "enable_network_firewall" {
  description = "Create an OCI Network Firewall and policy."
  type        = bool
  default     = false
}

variable "firewall_label" {
  description = "Short semantic label for the firewall."
  type        = string
  default     = "hub"
}

variable "subnet_id" {
  description = "Subnet OCID where OCI Network Firewall will be deployed."
  type        = string
  default     = null
}

variable "network_firewall_policy_id" {
  description = "Optional existing OCI Network Firewall policy OCID."
  type        = string
  default     = null
}

variable "network_security_group_ids" {
  description = "Optional NSG OCIDs attached to the network firewall."
  type        = set(string)
  default     = []
}

variable "availability_domain" {
  description = "Optional availability domain for the firewall."
  type        = string
  default     = null
}

variable "policy_display_name" {
  description = "Optional firewall policy display name override."
  type        = string
  default     = null
}

variable "policy_description" {
  description = "Description for the generated firewall policy."
  type        = string
  default     = "Landing zone network firewall policy starter."
}

variable "firewall_display_name" {
  description = "Optional firewall display name override."
  type        = string
  default     = null
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
