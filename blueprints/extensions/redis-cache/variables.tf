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

variable "create_cluster" {
  description = "Create the OCI Cache with Redis cluster."
  type        = bool
  default     = false
}
variable "redis_cluster_id" {
  description = "Existing Redis cluster OCID when create_cluster is false."
  type        = string
  default     = null
}
variable "cluster_display_name" {
  description = "Optional Redis cluster display name override."
  type        = string
  default     = null
}
variable "software_version" {
  description = "Redis software version."
  type        = string
  default     = "7.0.5"
}
variable "subnet_id" {
  description = "Private subnet OCID for Redis nodes."
  type        = string
  default     = null
}
variable "nsg_ids" {
  description = "Network security group OCIDs allowed to reach Redis."
  type        = set(string)
  default     = []
}
variable "node_count" {
  description = "Redis node count."
  type        = number
  default     = 2
}
variable "node_memory_in_gbs" {
  description = "Memory per Redis node in GB."
  type        = number
  default     = 2
}
variable "shard_count" {
  description = "Optional Redis shard count."
  type        = number
  default     = null
}
variable "cluster_mode" {
  description = "Optional Redis cluster mode."
  type        = string
  default     = null
}
variable "oci_cache_config_set_id" {
  description = "Optional OCI Cache config set OCID."
  type        = string
  default     = null
}
variable "backup_id" {
  description = "Optional backup OCID to restore from."
  type        = string
  default     = null
}
variable "vault_secret_id" {
  description = "Optional Vault secret OCID that stores application Redis auth material."
  type        = string
  default     = null
}
variable "alarms" {
  description = "Monitoring alarms keyed by logical name."
  type = map(object({
    display_name          = optional(string)
    namespace             = optional(string, "oci_redis")
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
  description = "Optional IAM policy statements for cache admins, application writers, and auditors."
  type        = list(string)
  default     = []
}
