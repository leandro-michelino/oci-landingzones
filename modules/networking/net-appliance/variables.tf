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

variable "enable_net_appliance" {
  description = "Create OCI compute instances to act as network virtual appliances."
  type        = bool
  default     = false
}

variable "enable_reserved_route_ips" {
  description = "Create reserved private IPs that can be used as route targets for appliances."
  type        = bool
  default     = false
}

variable "appliances" {
  description = "Network virtual appliances keyed by logical name. Image and AD must be real values before enabling."
  type = map(object({
    availability_domain = string
    subnet_id           = string
    image_id            = string
    shape               = optional(string, "VM.Standard.E4.Flex")
    ocpus               = optional(number, 1)
    memory_in_gbs       = optional(number, 8)
    private_ip          = optional(string)
    hostname_label      = optional(string)
    assign_public_ip    = optional(bool, false)
    nsg_ids             = optional(list(string), [])
    user_data           = optional(string)
  }))
  default = {}
}

variable "reserved_route_ips" {
  description = "Reserved private IPs keyed by logical name, normally one per NVA route target."
  type = map(object({
    subnet_id      = string
    ip_address     = optional(string)
    hostname_label = optional(string)
    route_table_id = optional(string)
    display_name   = optional(string)
  }))
  default = {}
}

variable "existing_route_target_private_ip_ids" {
  description = "Existing private IP OCIDs for customer-managed appliances."
  type        = map(string)
  default     = {}
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
