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
variable "policy_compartment_ocid" {
  description = "Compartment OCID where guardrail policy is created. Defaults to tenancy_ocid."
  type        = string
  default     = null
}
variable "guardrail_policy_statements" {
  description = "IAM policy statements for regulated guardrails."
  type        = list(string)
  default     = []
}
variable "enable_budget" {
  description = "Create regulated workload budget and optional alert."
  type        = bool
  default     = false
}
variable "budget_amount" {
  description = "Budget amount."
  type        = number
  default     = 1000
}
variable "budget_reset_period" {
  description = "Budget reset period."
  type        = string
  default     = "MONTHLY"
}
variable "budget_alert_recipients" {
  description = "Budget alert recipients."
  type        = string
  default     = null
}
variable "budget_alert_threshold" {
  description = "Budget alert threshold."
  type        = number
  default     = 80
}
variable "budget_alert_threshold_type" {
  description = "Budget alert threshold type."
  type        = string
  default     = "PERCENTAGE"
}
variable "budget_alert_type" {
  description = "Budget alert type."
  type        = string
  default     = "ACTUAL"
}
variable "budget_alert_message" {
  description = "Budget alert message."
  type        = string
  default     = "Regulated workload budget threshold reached."
}
variable "enable_data_safe_target_database" {
  description = "Register a target database with OCI Data Safe."
  type        = bool
  default     = false
}
variable "data_safe_database_type" {
  description = "Data Safe database type."
  type        = string
  default     = "AUTONOMOUS_DATABASE"
}
variable "data_safe_infrastructure_type" {
  description = "Data Safe infrastructure type."
  type        = string
  default     = "ORACLE_CLOUD"
}
variable "data_safe_autonomous_database_id" {
  description = "Autonomous Database OCID for Data Safe target registration."
  type        = string
  default     = null
}
variable "data_safe_service_name" {
  description = "Optional Data Safe service name."
  type        = string
  default     = null
}
variable "data_safe_user_name" {
  description = "Optional Data Safe credential username."
  type        = string
  default     = null
  sensitive   = true
}
variable "data_safe_password" {
  description = "Optional Data Safe credential password."
  type        = string
  default     = null
  sensitive   = true
}
