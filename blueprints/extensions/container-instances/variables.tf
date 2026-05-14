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
  description = "Compartment OCID where resources are created. Defaults to tenancy_ocid for validation-only tests."
  type        = string
  default     = null
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
variable "enable_container_instance" {
  description = "Create the OCI Container Instance."
  type        = bool
  default     = false
}
variable "display_name" {
  description = "Optional Container Instance display name override."
  type        = string
  default     = null
}
variable "availability_domain" {
  description = "Availability domain for the Container Instance."
  type        = string
  default     = null
}
variable "fault_domain" {
  description = "Optional fault domain."
  type        = string
  default     = null
}
variable "shape" {
  description = "Container Instance shape."
  type        = string
  default     = "CI.Standard.E4.Flex"
}
variable "ocpus" {
  description = "OCPUs allocated to the Container Instance shape config."
  type        = number
  default     = 1
}
variable "memory_in_gbs" {
  description = "Memory allocated to the Container Instance shape config."
  type        = number
  default     = 2
}
variable "container_restart_policy" {
  description = "Container restart policy."
  type        = string
  default     = "ALWAYS"
}
variable "graceful_shutdown_timeout_in_seconds" {
  description = "Graceful shutdown timeout in seconds."
  type        = string
  default     = "30"
}
variable "subnet_id" {
  description = "Subnet OCID for the Container Instance VNIC."
  type        = string
  default     = null
}
variable "vnic_display_name" {
  description = "Optional VNIC display name."
  type        = string
  default     = null
}
variable "hostname_label" {
  description = "Optional VNIC hostname label."
  type        = string
  default     = null
}
variable "is_public_ip_assigned" {
  description = "Assign a public IP to the Container Instance VNIC."
  type        = bool
  default     = false
}
variable "nsg_ids" {
  description = "Network security group OCIDs for the Container Instance VNIC."
  type        = set(string)
  default     = []
}
variable "private_ip" {
  description = "Optional private IP address for the Container Instance VNIC."
  type        = string
  default     = null
}
variable "skip_source_dest_check" {
  description = "Skip source/destination check on the VNIC."
  type        = bool
  default     = false
}
variable "containers" {
  description = "Container definitions for the Container Instance."
  type = list(object({
    display_name                        = optional(string)
    image_url                           = string
    command                             = optional(list(string), [])
    arguments                           = optional(list(string), [])
    environment_variables               = optional(map(string), {})
    working_directory                   = optional(string)
    is_resource_principal_disabled      = optional(bool, false)
    resource_config_memory_limit_in_gbs = optional(number)
    resource_config_vcpus_limit         = optional(number)
    volume_mounts = optional(list(object({
      volume_name  = string
      mount_path   = string
      is_read_only = optional(bool)
      partition    = optional(number)
      sub_path     = optional(string)
    })), [])
    health_checks = optional(list(object({
      health_check_type        = string
      name                     = optional(string)
      path                     = optional(string)
      port                     = optional(number)
      failure_action           = optional(string)
      failure_threshold        = optional(number)
      initial_delay_in_seconds = optional(number)
      interval_in_seconds      = optional(number)
      success_threshold        = optional(number)
      timeout_in_seconds       = optional(number)
      headers = optional(list(object({
        name  = string
        value = string
      })), [])
    })), [])
  }))
  default = []
  validation {
    condition     = !var.enable_container_instance || length(var.containers) > 0
    error_message = "containers must include at least one container when enable_container_instance is true."
  }
}
variable "image_pull_secrets" {
  description = "Optional image pull secrets. Prefer Vault secret IDs instead of inline passwords."
  type = list(object({
    registry_endpoint = string
    secret_type       = string
    username          = optional(string)
    password          = optional(string)
    secret_id         = optional(string)
  }))
  default = []
}
variable "dns_nameservers" {
  description = "Optional custom DNS nameservers."
  type        = list(string)
  default     = []
}
variable "dns_searches" {
  description = "Optional custom DNS search domains."
  type        = list(string)
  default     = []
}
variable "dns_options" {
  description = "Optional custom DNS resolver options."
  type        = list(string)
  default     = []
}
variable "volumes" {
  description = "Optional Container Instance volumes."
  type = list(object({
    name          = string
    volume_type   = string
    backing_store = optional(string)
    configs = optional(list(object({
      file_name = optional(string)
      path      = optional(string)
      data      = optional(string)
    })), [])
  }))
  default = []
}
variable "policy_compartment_ocid" {
  description = "Compartment OCID where the optional IAM policy is created. Defaults to tenancy_ocid."
  type        = string
  default     = null
}
variable "policy_statements" {
  description = "Optional IAM policy statements for Container Instance operators or service principals."
  type        = list(string)
  default     = []
}
