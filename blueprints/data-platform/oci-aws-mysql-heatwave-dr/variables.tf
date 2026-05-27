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
  description = "Compartment OCID where OCI resources are created. Defaults to tenancy_ocid for validation-only tests."
  type        = string
  default     = null
}

variable "oci_is_primary" {
  description = "Set to true. This variant keeps OCI as the primary write endpoint."
  type        = bool
  default     = true

  validation {
    condition     = var.oci_is_primary == true
    error_message = "oci_is_primary must be true for this blueprint variant."
  }
}

variable "enable_oci_primary_network" {
  description = "Create OCI primary networking resources (VCN, subnet, route table, security list, and DRG attachment)."
  type        = bool
  default     = true
}

variable "oci_primary_vcn_cidr" {
  description = "CIDR block for the OCI primary VCN."
  type        = string
  default     = "10.74.0.0/16"
}

variable "oci_primary_db_subnet_cidr" {
  description = "CIDR block for OCI primary MySQL subnet."
  type        = string
  default     = "10.74.10.0/24"
}

variable "oci_app_ingress_allowed_cidr" {
  description = "Source CIDR allowed for application access to OCI MySQL port 3306."
  type        = string
  default     = "10.0.0.0/8"
}

variable "aws_replication_cidr" {
  description = "AWS CIDR allowed for cross-cloud MySQL replication traffic into OCI on port 3306."
  type        = string
  default     = "10.84.0.0/16"
}

variable "enable_ipsec_connectivity" {
  description = "Create OCI DRG, CPE, and IPSec connection for OCI-to-AWS encrypted connectivity."
  type        = bool
  default     = true
}

variable "aws_cpe_public_ip" {
  description = "AWS VPN endpoint public IP used by OCI CPE when enable_ipsec_connectivity is true."
  type        = string
  default     = null
}

variable "aws_bgp_asn" {
  description = "AWS side BGP ASN used for IPSec dynamic routing contracts."
  type        = number
  default     = 64512
}

variable "create_db_system" {
  description = "Create OCI MySQL DB System for the primary database."
  type        = bool
  default     = false
}

variable "existing_db_system_id" {
  description = "Existing OCI MySQL DB System OCID when create_db_system is false."
  type        = string
  default     = null
}

variable "create_heatwave_cluster" {
  description = "Create OCI HeatWave cluster attached to the primary DB System."
  type        = bool
  default     = false
}

variable "existing_heatwave_cluster_id" {
  description = "Existing HeatWave cluster identifier when create_heatwave_cluster is false."
  type        = string
  default     = null
}

variable "mysql_version" {
  description = "OCI MySQL version for the primary DB System."
  type        = string
  default     = null
}

variable "db_shape_name" {
  description = "OCI MySQL DB System shape name."
  type        = string
  default     = "MySQL.VM.Standard.E4.1.8GB"
}

variable "availability_domain" {
  description = "Availability domain for OCI MySQL DB System when created."
  type        = string
  default     = null
}

variable "fault_domain" {
  description = "Optional fault domain for OCI MySQL DB System."
  type        = string
  default     = null
}

variable "data_storage_size_in_gb" {
  description = "OCI MySQL DB System storage size in GB."
  type        = number
  default     = 100
}

variable "is_highly_available" {
  description = "Enable high availability for OCI MySQL DB System."
  type        = bool
  default     = true
}

variable "admin_username" {
  description = "OCI MySQL administrator username."
  type        = string
  default     = null
}

variable "admin_password" {
  description = "OCI MySQL administrator password. Supply through local ignored tfvars or secure pipeline secrets."
  type        = string
  default     = null
  sensitive   = true
}

variable "backup_enabled" {
  description = "Enable automatic OCI MySQL backups."
  type        = bool
  default     = true
}

variable "backup_retention_in_days" {
  description = "OCI MySQL backup retention in days."
  type        = number
  default     = 7
}

variable "backup_window_start_time" {
  description = "Optional backup window start time (for example 02:00)."
  type        = string
  default     = null
}

variable "heatwave_shape_name" {
  description = "OCI HeatWave cluster shape name."
  type        = string
  default     = "HeatWave.512GB"
}

variable "heatwave_cluster_size" {
  description = "OCI HeatWave cluster node count."
  type        = number
  default     = 1
}

variable "enable_heatwave_lakehouse" {
  description = "Enable HeatWave Lakehouse feature on OCI HeatWave cluster."
  type        = bool
  default     = false
}

variable "create_lakehouse_bucket" {
  description = "Create OCI Object Storage bucket for HeatWave Lakehouse and replication evidence files."
  type        = bool
  default     = true
}

variable "lakehouse_bucket_name" {
  description = "Optional custom name for the OCI lakehouse bucket."
  type        = string
  default     = null
}

variable "kms_key_id" {
  description = "Optional OCI KMS key OCID for bucket and database encryption."
  type        = string
  default     = null
}

variable "enable_dr_alert_topic" {
  description = "Create OCI Notifications topic for replication and failover alerts."
  type        = bool
  default     = true
}

variable "dr_alert_topic_name" {
  description = "Optional custom name for DR alert topic."
  type        = string
  default     = null
}

variable "primary_dns_name" {
  description = "Primary DNS record used by applications for database writes."
  type        = string
  default     = "mysql-primary.example.internal"
}

variable "oci_primary_endpoint" {
  description = "OCI primary endpoint used for runbook and DNS contracts."
  type        = string
  default     = null
}

variable "aws_secondary_endpoint" {
  description = "AWS secondary endpoint used for replication and failover contracts."
  type        = string
  default     = null
}

variable "replication_user_name" {
  description = "Replication user name expected by cross-cloud MySQL replication runbooks."
  type        = string
  default     = "replicator"
}

variable "replication_channel_name" {
  description = "Logical replication channel name used in runbooks and operations dashboards."
  type        = string
  default     = "oci_to_aws_secondary"
}

variable "replication_ssl_required" {
  description = "Require TLS on replication channel between OCI primary and AWS secondary."
  type        = bool
  default     = true
}

variable "target_rto_minutes" {
  description = "Target recovery time objective in minutes."
  type        = number
  default     = 30
}

variable "target_rpo_minutes" {
  description = "Target recovery point objective in minutes."
  type        = number
  default     = 10
}

variable "dns_ttl_seconds" {
  description = "DNS TTL used by failover runbooks for database endpoint cutover."
  type        = number
  default     = 30
}

variable "dr_drill_frequency" {
  description = "Expected DR drill cadence for governance and evidence capture."
  type        = string
  default     = "quarterly"
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
