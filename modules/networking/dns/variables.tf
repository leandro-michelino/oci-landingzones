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

variable "enable_private_dns" {
  description = "Create private DNS view and zones."
  type        = bool
  default     = true
}

variable "dns_label" {
  description = "Short semantic label for the private DNS view."
  type        = string
  default     = "shared"
}

variable "private_zones" {
  description = "Private DNS zones keyed by logical name."
  type = map(object({
    name        = string
    zone_type   = optional(string, "PRIMARY")
    scope       = optional(string, "PRIVATE")
    description = optional(string)
  }))
  default = {
    internal = {
      name = "internal.example"
    }
  }
}

variable "vcn_ids" {
  description = "VCN OCIDs whose default resolvers should attach the private DNS view."
  type        = map(string)
  default     = {}
}

variable "attach_private_view_to_vcn_resolvers" {
  description = "Attach the created private DNS view to the default resolver of each VCN in vcn_ids."
  type        = bool
  default     = true
}

variable "resolver_rules" {
  description = "Forwarding rules added to attached VCN resolvers."
  type = list(object({
    action                    = string
    source_endpoint_name      = string
    destination_addresses     = list(string)
    client_address_conditions = optional(list(string), [])
    qname_cover_conditions    = optional(list(string), [])
  }))
  default = []
}

variable "enable_resolver_endpoints" {
  description = "Create DNS resolver endpoints. Requires resolver_id or vcn_key for each endpoint."
  type        = bool
  default     = false
}

variable "resolver_endpoints" {
  description = "DNS resolver endpoints keyed by logical name."
  type = map(object({
    subnet_id          = string
    resolver_id        = optional(string)
    vcn_key            = optional(string)
    endpoint_type      = optional(string, "VNIC")
    is_forwarding      = bool
    is_listening       = bool
    forwarding_address = optional(string)
    listening_address  = optional(string)
    nsg_ids            = optional(list(string), [])
  }))
  default = {}
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
