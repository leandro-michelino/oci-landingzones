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

variable "create_desktop_pool" {
  description = "Create the Secure Desktops pool."
  type        = bool
  default     = false
}
variable "desktop_pool_id" {
  description = "Existing Secure Desktops pool OCID when create_desktop_pool is false."
  type        = string
  default     = null
}
variable "desktop_pool_display_name" {
  description = "Optional desktop pool display name override."
  type        = string
  default     = null
}
variable "desktop_pool_description" {
  description = "Desktop pool description."
  type        = string
  default     = "OCI Secure Desktops pool managed by Terraform."
}
variable "availability_domain" {
  description = "Availability domain for desktop pool capacity."
  type        = string
  default     = null
}
variable "contact_details" {
  description = "Support contact details shown for desktop users."
  type        = string
  default     = "platform-team@example.com"
}
variable "maximum_size" {
  description = "Maximum desktop pool size."
  type        = number
  default     = 2
}
variable "standby_size" {
  description = "Standby desktop count."
  type        = number
  default     = 0
}
variable "shape_name" {
  description = "Desktop compute shape name."
  type        = string
  default     = "VM.Standard.E4.Flex"
}
variable "shape_config" {
  description = "Optional flex shape configuration."
  type = object({
    baseline_ocpu_utilization = optional(string)
    ocpus                     = optional(string)
    memory_in_gbs             = optional(string)
  })
  default = null
}
variable "boot_volume_size_in_gbs" {
  description = "Desktop boot volume size in GB."
  type        = number
  default     = 100
}
variable "nsg_ids" {
  description = "NSG OCIDs attached to the desktop pool."
  type        = set(string)
  default     = []
}
variable "are_privileged_users" {
  description = "Allow privileged users on desktops."
  type        = bool
  default     = false
}
variable "are_volumes_preserved" {
  description = "Preserve desktop volumes when desktops are deleted."
  type        = bool
  default     = true
}
variable "is_storage_enabled" {
  description = "Enable desktop storage."
  type        = bool
  default     = true
}
variable "storage_backup_policy_id" {
  description = "Backup policy OCID for desktop storage."
  type        = string
  default     = null
}
variable "storage_size_in_gbs" {
  description = "Desktop storage size in GB."
  type        = number
  default     = 50
}
variable "time_start_scheduled" {
  description = "Optional scheduled start time."
  type        = string
  default     = null
}
variable "time_stop_scheduled" {
  description = "Optional scheduled stop time."
  type        = string
  default     = null
}
variable "use_dedicated_vm_host" {
  description = "Optional dedicated VM host setting."
  type        = string
  default     = null
}

variable "image_id" {
  description = "Desktop image OCID."
  type        = string
  default     = null
}
variable "image_name" {
  description = "Desktop image name."
  type        = string
  default     = null
}
variable "image_operating_system" {
  description = "Desktop image operating system label."
  type        = string
  default     = null
}
variable "windows_10_11_byol_acknowledged" {
  description = "Acknowledges that Windows 10/11 Secure Desktops require customer BYOL licensing and adds the OCI Secure Desktops BYOL pool tag during creation."
  type        = bool
  default     = false

  validation {
    condition     = !var.create_desktop_pool || length(regexall("(?i)windows[ _-]*(10|11)", coalesce(var.image_operating_system, ""))) == 0 || var.windows_10_11_byol_acknowledged
    error_message = "Set windows_10_11_byol_acknowledged=true when creating a Secure Desktops pool from a Windows 10 or Windows 11 image."
  }
}
variable "subnet_id" {
  description = "Desktop pool subnet OCID."
  type        = string
  default     = null
}
variable "vcn_id" {
  description = "Desktop pool VCN OCID."
  type        = string
  default     = null
}
variable "private_access_subnet_id" {
  description = "Optional private access subnet OCID."
  type        = string
  default     = null
}
variable "private_access_vcn_id" {
  description = "Optional private access VCN OCID."
  type        = string
  default     = null
}
variable "private_access_nsg_ids" {
  description = "Optional private access NSG OCIDs."
  type        = set(string)
  default     = []
}
variable "private_access_private_ip" {
  description = "Optional private access IP address."
  type        = string
  default     = null
}
variable "private_access_endpoint_fqdn" {
  description = "Optional private access endpoint FQDN."
  type        = string
  default     = null
}

variable "device_policy" {
  description = "Device redirection and input policy."
  type = object({
    audio_mode             = string
    cdm_mode               = string
    clipboard_mode         = string
    is_display_enabled     = bool
    is_keyboard_enabled    = bool
    is_pointer_enabled     = bool
    is_printing_enabled    = bool
    is_video_input_enabled = optional(bool)
  })
  default = {
    audio_mode             = "DISABLED"
    cdm_mode               = "DISABLED"
    clipboard_mode         = "DISABLED"
    is_display_enabled     = true
    is_keyboard_enabled    = true
    is_pointer_enabled     = true
    is_printing_enabled    = false
    is_video_input_enabled = false
  }
}
variable "start_schedule" {
  description = "Optional desktop start schedule."
  type = object({
    cron_expression = string
    timezone        = string
  })
  default = null
}
variable "stop_schedule" {
  description = "Optional desktop stop schedule."
  type = object({
    cron_expression = string
    timezone        = string
  })
  default = null
}
variable "enable_session_lifecycle_actions" {
  description = "Enable session lifecycle disconnect and inactivity actions."
  type        = bool
  default     = false
}
variable "disconnect_action" {
  description = "Optional disconnect lifecycle action."
  type = object({
    action                  = string
    grace_period_in_minutes = optional(number)
  })
  default = null
}
variable "inactivity_action" {
  description = "Optional inactivity lifecycle action."
  type = object({
    action                  = string
    grace_period_in_minutes = optional(number)
  })
  default = null
}
variable "alarms" {
  description = "Monitoring alarms keyed by logical name."
  type = map(object({
    display_name          = optional(string)
    namespace             = string
    query                 = string
    severity              = optional(string, "WARNING")
    destinations          = list(string)
    metric_compartment_id = optional(string)
    body                  = optional(string)
    is_enabled            = optional(bool, true)
  }))
  default = {}
}
variable "policy_compartment_ocid" {
  description = "Compartment OCID where the optional IAM policy is created. Defaults to tenancy_ocid."
  type        = string
  default     = null
}
variable "policy_statements" {
  description = "Optional IAM policy statements for desktop administrators, users, and auditors."
  type        = list(string)
  default     = []
}
