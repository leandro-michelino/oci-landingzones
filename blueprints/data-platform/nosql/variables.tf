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
  description = "Compartment OCID where NoSQL resources are created. Defaults to tenancy_ocid for validation-only tests."
  type        = string
  default     = null
}

variable "enable_app_network" {
  description = "Create deploy-and-use app network resources for NoSQL consumer workloads."
  type        = bool
  default     = true
}

variable "app_vcn_cidr" {
  description = "CIDR block for the app VCN when enable_app_network is true."
  type        = string
  default     = "10.84.0.0/16"
}

variable "app_subnet_cidr" {
  description = "CIDR block for the app subnet when enable_app_network is true."
  type        = string
  default     = "10.84.10.0/24"
}

variable "app_ingress_allowed_cidr" {
  description = "Optional CIDR allowed to reach app workloads on TCP/443. Null creates no app ingress rule; this is not a NoSQL service endpoint rule."
  type        = string
  default     = null
}

variable "create_table" {
  description = "Create the NoSQL table. Disable for a network-only foundation plan or lifecycle test; index and replica then remain disabled."
  type        = bool
  default     = true

  validation {
    condition     = var.create_table || (!var.create_secondary_index && !var.enable_table_replica)
    error_message = "When create_table=false, disable create_secondary_index and enable_table_replica."
  }
}

variable "table_name" {
  description = "Optional NoSQL table name override."
  type        = string
  default     = null

  validation {
    condition     = var.table_name == null || can(regex("^[A-Za-z][A-Za-z0-9_]*$", var.table_name))
    error_message = "table_name must be a valid NoSQL SQL identifier: start with a letter and use only letters, numbers, and underscores."
  }
}

variable "table_ddl_statement" {
  description = "Optional DDL statement for the NoSQL table schema. When null, the blueprint creates a default orders table DDL using table_name."
  type        = string
  default     = null
}

variable "table_max_read_units" {
  description = "Maximum read units for the NoSQL table."
  type        = number
  default     = 100
}

variable "table_max_write_units" {
  description = "Maximum write units for the NoSQL table."
  type        = number
  default     = 100
}

variable "table_max_storage_in_gbs" {
  description = "Maximum storage for the NoSQL table in GB."
  type        = number
  default     = 25
}

variable "table_capacity_mode" {
  description = "Capacity mode for table limits."
  type        = string
  default     = "PROVISIONED"
}

variable "create_secondary_index" {
  description = "Create a NoSQL secondary index."
  type        = bool
  default     = false
}

variable "secondary_index_name" {
  description = "Optional NoSQL secondary index name override."
  type        = string
  default     = null

  validation {
    condition     = var.secondary_index_name == null || can(regex("^[A-Za-z][A-Za-z0-9_]*$", var.secondary_index_name))
    error_message = "secondary_index_name must be a valid NoSQL SQL identifier: start with a letter and use only letters, numbers, and underscores."
  }
}

variable "secondary_index_columns" {
  description = "Columns included in the NoSQL secondary index."
  type = list(object({
    column_name = string
  }))
  default = [
    {
      column_name = "customerId"
    }
  ]
}

variable "enable_table_replica" {
  description = "Create a cross-region NoSQL table replica."
  type        = bool
  default     = false
}

variable "replica_region" {
  description = "Target region for NoSQL table replica when enable_table_replica is true."
  type        = string
  default     = null
}

variable "replica_max_read_units" {
  description = "Max read units for NoSQL table replica."
  type        = number
  default     = 100
}

variable "replica_max_write_units" {
  description = "Max write units for NoSQL table replica."
  type        = number
  default     = 100
}

variable "create_alert_topic" {
  description = "Create a notifications topic for NoSQL operations and alerts."
  type        = bool
  default     = true
}

variable "alert_topic_name" {
  description = "Optional notifications topic name override."
  type        = string
  default     = null
}

variable "policy_compartment_ocid" {
  description = "Compartment OCID where IAM policy is created. Defaults to tenancy_ocid."
  type        = string
  default     = null
}

variable "policy_statements" {
  description = "IAM policy statements for NoSQL operators and consumers."
  type        = list(string)
  default     = []
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
