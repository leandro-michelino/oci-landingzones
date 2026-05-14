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

variable "create_buckets" {
  description = "Create source, processed, and audit Object Storage buckets."
  type        = bool
  default     = false
}
variable "source_bucket_name" {
  description = "Optional source document bucket name override."
  type        = string
  default     = null
}
variable "processed_bucket_name" {
  description = "Optional processed chunk bucket name override."
  type        = string
  default     = null
}
variable "audit_bucket_name" {
  description = "Optional agent audit bucket name override."
  type        = string
  default     = null
}
variable "source_bucket_prefix" {
  description = "Object Storage prefix used by the created source bucket data source."
  type        = string
  default     = ""
}
variable "bucket_storage_tier" {
  description = "Object Storage bucket storage tier."
  type        = string
  default     = "Standard"
}
variable "bucket_versioning" {
  description = "Object Storage bucket versioning setting."
  type        = string
  default     = "Enabled"
}
variable "kms_key_id" {
  description = "Optional KMS key OCID for bucket encryption."
  type        = string
  default     = null
}

variable "create_knowledge_base" {
  description = "Create a GenAI Agent knowledge base."
  type        = bool
  default     = false
}
variable "knowledge_base_id" {
  description = "Existing knowledge base OCID when create_knowledge_base is false."
  type        = string
  default     = null
}
variable "knowledge_base_display_name" {
  description = "Knowledge base display name."
  type        = string
  default     = null
}
variable "knowledge_base_description" {
  description = "Knowledge base description."
  type        = string
  default     = "RAG knowledge base managed by Terraform."
}
variable "knowledge_base_index_config_type" {
  description = "Knowledge base index config type."
  type        = string
  default     = "OCI_OPEN_SEARCH_INDEX_CONFIG"
}
variable "opensearch_cluster_id" {
  description = "OpenSearch cluster OCID used for vector indexing."
  type        = string
  default     = null
}
variable "should_enable_hybrid_search" {
  description = "Enable hybrid search when supported by the selected index backend."
  type        = bool
  default     = null
}
variable "knowledge_base_indexes" {
  description = "Optional knowledge base index definitions."
  type = list(object({
    name = optional(string)
    schema = optional(object({
      body_key           = optional(string)
      embedding_body_key = optional(string)
      title_key          = optional(string)
      url_key            = optional(string)
    }))
  }))
  default = []
}

variable "create_data_source" {
  description = "Create an Object Storage data source for the knowledge base."
  type        = bool
  default     = false
}
variable "data_source_id" {
  description = "Existing data source OCID when create_data_source is false."
  type        = string
  default     = null
}
variable "data_source_display_name" {
  description = "Data source display name."
  type        = string
  default     = null
}
variable "data_source_description" {
  description = "Data source description."
  type        = string
  default     = "Object Storage documents for RAG ingestion."
}
variable "data_source_config_type" {
  description = "GenAI Agent data source config type."
  type        = string
  default     = "OCI_OBJECT_STORAGE_PREFIXES"
}
variable "data_source_metadata" {
  description = "Optional data source metadata."
  type        = map(string)
  default     = {}
}
variable "data_source_prefixes" {
  description = "Existing Object Storage prefixes to ingest."
  type = list(object({
    namespace = string
    bucket    = string
    prefix    = optional(string)
  }))
  default = []
}

variable "create_ingestion_job" {
  description = "Create a one-time data ingestion job for the data source."
  type        = bool
  default     = false
}
variable "ingestion_job_display_name" {
  description = "Data ingestion job display name."
  type        = string
  default     = null
}
variable "ingestion_job_description" {
  description = "Data ingestion job description."
  type        = string
  default     = "Initial RAG data ingestion job."
}

variable "create_agent" {
  description = "Create the GenAI Agent that uses the knowledge base."
  type        = bool
  default     = false
}
variable "agent_id" {
  description = "Existing GenAI Agent OCID when create_agent is false."
  type        = string
  default     = null
}
variable "agent_display_name" {
  description = "Agent display name."
  type        = string
  default     = null
}
variable "agent_description" {
  description = "Agent description."
  type        = string
  default     = "Retrieval augmented generation agent managed by Terraform."
}
variable "agent_welcome_message" {
  description = "Agent welcome message."
  type        = string
  default     = "Ask a question about the indexed knowledge base."
}
variable "agent_knowledge_base_ids" {
  description = "Existing knowledge base OCIDs attached to the agent."
  type        = list(string)
  default     = []
}
variable "agent_model_id" {
  description = "GenAI model OCID used by the agent."
  type        = string
  default     = null
}
variable "agent_endpoint_model_id" {
  description = "GenAI endpoint OCID used by the agent."
  type        = string
  default     = null
}
variable "agent_instruction" {
  description = "Routing or answer instruction for the agent model."
  type        = string
  default     = null
}

variable "create_agent_endpoint" {
  description = "Create an endpoint for the RAG agent."
  type        = bool
  default     = false
}
variable "agent_endpoint_id" {
  description = "Existing agent endpoint OCID when create_agent_endpoint is false."
  type        = string
  default     = null
}
variable "agent_endpoint_display_name" {
  description = "Agent endpoint display name."
  type        = string
  default     = null
}
variable "agent_endpoint_description" {
  description = "Agent endpoint description."
  type        = string
  default     = "Endpoint for private RAG agent access."
}
variable "enable_endpoint_session" {
  description = "Enable sessions on the agent endpoint."
  type        = bool
  default     = true
}
variable "enable_endpoint_trace" {
  description = "Enable trace on the agent endpoint."
  type        = bool
  default     = true
}
variable "enable_endpoint_citation" {
  description = "Enable citations on the agent endpoint."
  type        = bool
  default     = true
}

variable "policy_compartment_ocid" {
  description = "Compartment OCID where the optional IAM policy is created. Defaults to tenancy_ocid."
  type        = string
  default     = null
}
variable "policy_statements" {
  description = "Optional IAM policy statements for agent callers, ingestion operators, and data stewards."
  type        = list(string)
  default     = []
}
