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

variable "enable_net_appliance" {
  description = "Create NVA compute instances in the hub. Keep false until image and routing details are ready."
  type        = bool
  default     = false
}

variable "enable_reserved_route_ips" {
  description = "Create reserved private IPs for NVA route targets."
  type        = bool
  default     = false
}

variable "appliances" {
  description = "Network virtual appliances keyed by logical name."
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
  description = "Reserved private IP route targets keyed by logical name."
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
