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

variable "create_training_bucket" {
  description = "Create the Object Storage bucket used for fine-tuning datasets."
  type        = bool
  default     = false
}
variable "training_bucket_name" {
  description = "Optional training bucket name override."
  type        = string
  default     = null
}
variable "training_bucket_storage_tier" {
  description = "Training bucket storage tier."
  type        = string
  default     = "Standard"
}
variable "training_bucket_versioning" {
  description = "Training bucket versioning setting."
  type        = string
  default     = "Enabled"
}
variable "kms_key_id" {
  description = "Optional KMS key OCID for bucket encryption."
  type        = string
  default     = null
}

variable "create_dedicated_ai_cluster" {
  description = "Create a dedicated AI cluster for fine-tuning."
  type        = bool
  default     = false
}
variable "dedicated_ai_cluster_id" {
  description = "Existing dedicated AI cluster OCID when create_dedicated_ai_cluster is false."
  type        = string
  default     = null
}
variable "cluster_display_name" {
  description = "Optional dedicated AI cluster display name override."
  type        = string
  default     = null
}
variable "cluster_type" {
  description = "Dedicated AI cluster type."
  type        = string
  default     = "FINE_TUNING"
}
variable "cluster_unit_count" {
  description = "Dedicated AI cluster unit count."
  type        = number
  default     = 1
}
variable "cluster_unit_shape" {
  description = "Dedicated AI cluster unit shape."
  type        = string
  default     = "LARGE_COHERE"
}

variable "create_fine_tuned_model" {
  description = "Create a fine-tuned GenAI model."
  type        = bool
  default     = false
}
variable "model_id" {
  description = "Existing model OCID when create_fine_tuned_model is false."
  type        = string
  default     = null
}
variable "base_model_id" {
  description = "Base model OCID used for fine-tuning."
  type        = string
  default     = null
}
variable "model_display_name" {
  description = "Optional fine-tuned model display name override."
  type        = string
  default     = null
}
variable "model_description" {
  description = "Fine-tuned model description."
  type        = string
  default     = "Fine-tuned GenAI model managed by Terraform."
}
variable "training_dataset_bucket" {
  description = "Training dataset bucket name."
  type        = string
  default     = null
}
variable "training_dataset_namespace" {
  description = "Training dataset Object Storage namespace."
  type        = string
  default     = null
}
variable "training_dataset_object" {
  description = "Training dataset object path."
  type        = string
  default     = "datasets/training.jsonl"
}
variable "training_dataset_type" {
  description = "Training dataset type."
  type        = string
  default     = "OBJECT_STORAGE"
}
variable "training_config_type" {
  description = "Training config type."
  type        = string
  default     = "TFEW_TRAINING_CONFIG"
}
variable "total_training_epochs" {
  description = "Optional total training epochs."
  type        = number
  default     = null
}
variable "training_batch_size" {
  description = "Optional training batch size."
  type        = number
  default     = null
}
variable "learning_rate" {
  description = "Optional training learning rate."
  type        = number
  default     = null
}

variable "create_endpoint" {
  description = "Create a GenAI endpoint for the fine-tuned model."
  type        = bool
  default     = false
}
variable "endpoint_display_name" {
  description = "Optional model endpoint display name override."
  type        = string
  default     = null
}
variable "endpoint_description" {
  description = "Model endpoint description."
  type        = string
  default     = "Private endpoint for fine-tuned GenAI model."
}
variable "generative_ai_private_endpoint_id" {
  description = "Optional GenAI private endpoint OCID from the genai-private blueprint."
  type        = string
  default     = null
}
variable "policy_compartment_ocid" {
  description = "Compartment OCID where the IAM policy is created. Defaults to tenancy_ocid."
  type        = string
  default     = null
}
variable "policy_statements" {
  description = "IAM policy statements for fine-tuning operators and endpoint callers."
  type        = list(string)
  default     = []
}
