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
  description = "Compartment OCID where telco cloud-native resources are created. Defaults to tenancy_ocid."
  type        = string
  default     = null
}

variable "enable_vault" {
  description = "Create Vault resources for telco platform encryption."
  type        = bool
  default     = true
}

variable "enable_default_vault" {
  description = "Create the default telco platform vault."
  type        = bool
  default     = true
}

variable "enable_default_key" {
  description = "Create the default telco platform KMS key."
  type        = bool
  default     = true
}

variable "enable_oke_cluster" {
  description = "Create an OKE cluster for telco cloud-native workloads."
  type        = bool
  default     = false
}

variable "enable_oke_node_pool" {
  description = "Create an OKE node pool for telco workloads."
  type        = bool
  default     = false
}

variable "cluster_label" {
  description = "Short OKE cluster label used in names."
  type        = string
  default     = "telco"
}

variable "kubernetes_version" {
  description = "Kubernetes version for the OKE cluster and node pool."
  type        = string
  default     = null
}

variable "oke_endpoint_subnet_key" {
  description = "Hub subnet key used for the OKE API endpoint."
  type        = string
  default     = "services"
}

variable "oke_service_lb_subnet_key" {
  description = "Hub subnet key used for OKE service load balancers."
  type        = string
  default     = "dmz"
}

variable "oke_node_subnet_key" {
  description = "Hub subnet key used for OKE worker nodes."
  type        = string
  default     = "services"
}

variable "node_shape" {
  description = "OKE worker node shape."
  type        = string
  default     = null
}

variable "node_shape_ocpus" {
  description = "Optional OCPU count for flexible node shapes."
  type        = number
  default     = null
}

variable "node_shape_memory_in_gbs" {
  description = "Optional memory in GB for flexible node shapes."
  type        = number
  default     = null
}

variable "ssh_public_key" {
  description = "Optional SSH public key for OKE worker nodes."
  type        = string
  default     = null
}

variable "enable_monitoring" {
  description = "Create Monitoring resources for telco workloads."
  type        = bool
  default     = false
}

variable "enable_default_monitoring_topic" {
  description = "Create the default monitoring notification topic."
  type        = bool
  default     = true
}

variable "monitoring_notification_topics" {
  description = "ONS notification topics keyed by logical name."
  type = map(object({
    name             = optional(string)
    description      = optional(string)
    compartment_ocid = optional(string)
  }))
  default = {}
}

variable "monitoring_subscriptions" {
  description = "ONS subscriptions keyed by logical name."
  type = map(object({
    topic_key        = optional(string, "default")
    topic_id         = optional(string)
    compartment_ocid = optional(string)
    protocol         = string
    endpoint         = string
    delivery_policy  = optional(string)
  }))
  default = {}
}

variable "monitoring_alarms" {
  description = "Monitoring alarms keyed by logical name."
  type = map(object({
    display_name                                  = optional(string)
    body                                          = optional(string)
    compartment_ocid                              = optional(string)
    metric_compartment_ocid                       = optional(string)
    metric_compartment_id_in_subtree              = optional(bool, false)
    namespace                                     = string
    query                                         = string
    severity                                      = optional(string, "WARNING")
    is_enabled                                    = optional(bool, true)
    destinations                                  = optional(set(string), [])
    destination_topic_keys                        = optional(set(string), [])
    pending_duration                              = optional(string)
    resolution                                    = optional(string)
    resource_group                                = optional(string)
    message_format                                = optional(string)
    repeat_notification_duration                  = optional(string)
    evaluation_slack_duration                     = optional(string)
    is_notifications_per_metric_dimension_enabled = optional(bool)
    notification_title                            = optional(string)
  }))
  default = {}
}

variable "enable_os_management" {
  description = "Create OS Management Hub resources for telco compute fleets."
  type        = bool
  default     = false
}

variable "os_managed_instance_groups" {
  description = "OS Management Hub managed instance groups keyed by logical name."
  type = map(object({
    compartment_ocid      = optional(string)
    display_name          = optional(string)
    description           = optional(string)
    arch_type             = optional(string)
    os_family             = optional(string)
    vendor_name           = optional(string)
    location              = optional(string)
    managed_instance_ids  = optional(set(string), [])
    notification_topic_id = optional(string)
    software_source_ids   = optional(set(string), [])
  }))
  default = {}
}

variable "os_scheduled_jobs" {
  description = "OS Management Hub scheduled jobs keyed by logical name."
  type = map(object({
    compartment_ocid           = optional(string)
    display_name               = optional(string)
    description                = optional(string)
    schedule_type              = optional(string, "RECURRING")
    time_next_execution        = string
    recurring_rule             = optional(string)
    managed_compartment_ids    = optional(set(string), [])
    managed_instance_group_ids = optional(set(string), [])
    managed_instance_ids       = optional(set(string), [])
    is_subcompartment_included = optional(bool, false)
    retry_intervals            = optional(set(number), [])
    operations = list(object({
      operation_type         = string
      package_names          = optional(set(string), [])
      reboot_timeout_in_mins = optional(number)
      software_source_ids    = optional(set(string), [])
      windows_update_names   = optional(set(string), [])
    }))
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
