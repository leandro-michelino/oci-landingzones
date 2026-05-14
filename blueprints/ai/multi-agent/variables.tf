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
  description = "Create audit and tool registry buckets."
  type        = bool
  default     = false
}
variable "audit_bucket_name" {
  description = "Optional session audit bucket name override."
  type        = string
  default     = null
}
variable "tool_registry_bucket_name" {
  description = "Optional tool registry bucket name override."
  type        = string
  default     = null
}
variable "bucket_storage_tier" {
  description = "Bucket storage tier."
  type        = string
  default     = "Standard"
}
variable "bucket_versioning" {
  description = "Bucket versioning setting."
  type        = string
  default     = "Enabled"
}
variable "kms_key_id" {
  description = "Optional KMS key OCID for bucket and stream encryption."
  type        = string
  default     = null
}

variable "create_stream_pool" {
  description = "Create a Streaming pool for agent task hand-offs."
  type        = bool
  default     = false
}
variable "stream_pool_id" {
  description = "Existing stream pool OCID when create_stream_pool is false."
  type        = string
  default     = null
}
variable "stream_pool_name" {
  description = "Optional stream pool name override."
  type        = string
  default     = null
}
variable "create_task_stream" {
  description = "Create the inter-agent task stream."
  type        = bool
  default     = false
}
variable "task_stream_partitions" {
  description = "Task stream partition count."
  type        = number
  default     = 1
}
variable "task_stream_retention_in_hours" {
  description = "Task stream retention in hours."
  type        = number
  default     = 24
}

variable "create_knowledge_base" {
  description = "Create a GenAI Agent knowledge base backed by OpenSearch or a database connection."
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
  default     = "Knowledge base for multi-agent orchestration."
}
variable "knowledge_base_index_config_type" {
  description = "Knowledge base index config type."
  type        = string
  default     = "OCI_OPEN_SEARCH_INDEX_CONFIG"
}
variable "opensearch_cluster_id" {
  description = "OpenSearch cluster OCID for knowledge base indexing."
  type        = string
  default     = null
}

variable "create_orchestrator_agent" {
  description = "Create the top-level orchestrator GenAI Agent."
  type        = bool
  default     = false
}
variable "orchestrator_agent_id" {
  description = "Existing orchestrator agent OCID when create_orchestrator_agent is false."
  type        = string
  default     = null
}
variable "orchestrator_display_name" {
  description = "Orchestrator agent display name."
  type        = string
  default     = null
}
variable "orchestrator_description" {
  description = "Orchestrator agent description."
  type        = string
  default     = "Multi-agent orchestrator managed by Terraform."
}
variable "orchestrator_welcome_message" {
  description = "Welcome message for the orchestrator agent."
  type        = string
  default     = "How can I help route this task?"
}
variable "orchestrator_knowledge_base_ids" {
  description = "Existing knowledge base OCIDs attached to the orchestrator."
  type        = list(string)
  default     = []
}
variable "orchestrator_model_id" {
  description = "Model OCID used for orchestrator routing."
  type        = string
  default     = null
}
variable "orchestrator_endpoint_model_id" {
  description = "Model endpoint OCID used for orchestrator routing."
  type        = string
  default     = null
}
variable "routing_instruction" {
  description = "Routing instruction for the orchestrator model."
  type        = string
  default     = null
}

variable "create_orchestrator_endpoint" {
  description = "Create an endpoint for the orchestrator agent."
  type        = bool
  default     = false
}
variable "orchestrator_endpoint_id" {
  description = "Existing orchestrator endpoint OCID when create_orchestrator_endpoint is false."
  type        = string
  default     = null
}
variable "endpoint_display_name" {
  description = "Orchestrator endpoint display name."
  type        = string
  default     = null
}
variable "enable_endpoint_trace" {
  description = "Enable session trace for the orchestrator endpoint."
  type        = bool
  default     = true
}
variable "enable_endpoint_session" {
  description = "Enable sessions for the orchestrator endpoint."
  type        = bool
  default     = true
}

variable "specialist_agents" {
  description = "Specialist agents keyed by logical name."
  type = map(object({
    display_name       = optional(string)
    description        = optional(string)
    welcome_message    = optional(string)
    knowledge_base_ids = optional(list(string))
    model_id           = optional(string)
    endpoint_model_id  = optional(string)
    instruction        = optional(string)
  }))
  default = {}
}
variable "agent_tools" {
  description = "Agent tools keyed by logical name."
  type = map(object({
    agent_key            = optional(string)
    agent_id             = optional(string)
    display_name         = optional(string)
    description          = optional(string)
    tool_config_type     = string
    function_name        = optional(string)
    function_description = optional(string)
    function_parameters  = optional(map(string))
  }))
  default = {}
}
variable "policy_compartment_ocid" {
  description = "Compartment OCID where the IAM policy is created. Defaults to tenancy_ocid."
  type        = string
  default     = null
}
variable "policy_statements" {
  description = "IAM policy statements for agents, tools, streams, audit logs, and specialist permissions."
  type        = list(string)
  default     = []
}
