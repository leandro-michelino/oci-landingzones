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
variable "enable_devops_project" {
  description = "Create the OCI DevOps project."
  type        = bool
  default     = false
}
variable "project_name" {
  description = "Optional DevOps project name override."
  type        = string
  default     = null
}
variable "project_description" {
  description = "DevOps project description."
  type        = string
  default     = "Landing zone OCI DevOps project managed by Terraform."
}
variable "create_notification_topic" {
  description = "Create a notification topic for the DevOps project."
  type        = bool
  default     = false
}
variable "notification_topic_id" {
  description = "Existing ONS topic OCID when not creating one."
  type        = string
  default     = null
}
variable "topic_name" {
  description = "Optional notification topic name override."
  type        = string
  default     = null
}
variable "enable_repository" {
  description = "Create an OCI DevOps code repository."
  type        = bool
  default     = false
}
variable "repository_name" {
  description = "Optional repository name override."
  type        = string
  default     = null
}
variable "repository_type" {
  description = "OCI DevOps repository type."
  type        = string
  default     = "HOSTED"
}
variable "default_branch" {
  description = "Default repository branch."
  type        = string
  default     = "main"
}
variable "repository_description" {
  description = "Repository description."
  type        = string
  default     = "Landing zone application repository."
}
variable "enable_build_pipeline" {
  description = "Create an empty build pipeline shell."
  type        = bool
  default     = false
}
variable "build_pipeline_name" {
  description = "Optional build pipeline display name override."
  type        = string
  default     = null
}
variable "build_pipeline_description" {
  description = "Build pipeline description."
  type        = string
  default     = "Landing zone build pipeline shell."
}
variable "enable_deploy_pipeline" {
  description = "Create an empty deployment pipeline shell."
  type        = bool
  default     = false
}
variable "deploy_pipeline_name" {
  description = "Optional deploy pipeline display name override."
  type        = string
  default     = null
}
variable "deploy_pipeline_description" {
  description = "Deployment pipeline description."
  type        = string
  default     = "Landing zone deployment pipeline shell."
}
variable "existing_project_id" {
  description = "Existing DevOps project OCID used when enable_devops_project is false."
  type        = string
  default     = null
}
