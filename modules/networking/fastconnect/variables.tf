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

variable "enable_fastconnect" {
  description = "Create the FastConnect virtual circuit. Keep false until provider, BGP, and carrier details are ready."
  type        = bool
  default     = false
}

variable "virtual_circuit_label" {
  description = "Short semantic label for the virtual circuit."
  type        = string
  default     = "primary"
}

variable "virtual_circuit_type" {
  description = "FastConnect virtual circuit type."
  type        = string
  default     = "PRIVATE"

  validation {
    condition     = contains(["PRIVATE", "PUBLIC"], upper(var.virtual_circuit_type))
    error_message = "virtual_circuit_type must be PRIVATE or PUBLIC."
  }
}

variable "bandwidth_shape_name" {
  description = "FastConnect bandwidth shape name, for example 1 Gbps."
  type        = string
  default     = "1 Gbps"
}

variable "drg_id" {
  description = "DRG OCID used as the gateway for private virtual circuits."
  type        = string
  default     = null
}

variable "customer_bgp_asn" {
  description = "Customer BGP ASN for the virtual circuit."
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

variable "routing_policy" {
  description = "Routing policy for private virtual circuits."
  type        = list(string)
  default     = ["REGIONAL"]
}

variable "ip_mtu" {
  description = "IP MTU for the virtual circuit."
  type        = string
  default     = "MTU_1500"
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
