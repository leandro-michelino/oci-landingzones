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
  description = "Compartment OCID where APEX support resources are created. Defaults to the Autonomous Database compartment when autonomous_database_id is supplied."
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

variable "autonomous_database_id" {
  description = "Existing Autonomous Database OCID that hosts APEX and ORDS."
  type        = string
  default     = null
}

variable "autonomous_database_private_endpoint_ip" {
  description = "Optional ADB private endpoint IP override. Used when the data source cannot read private_endpoint_ip or when a private endpoint proxy IP is preferred."
  type        = string
  default     = null
}

variable "apex_workspace_name" {
  description = "APEX workspace name for operator hand-off and optional secret content."
  type        = string
  default     = "APP_WORKSPACE"
}

variable "apex_admin_username" {
  description = "APEX workspace administrator username for operator hand-off."
  type        = string
  default     = "APEX_ADMIN"
}

variable "apex_path" {
  description = "Path appended to apex_fqdn when building the private APEX URL output."
  type        = string
  default     = "/ords/"
}

variable "apex_fqdn" {
  description = "Optional DNS name that points at the private load balancer."
  type        = string
  default     = null
}

variable "apex_url" {
  description = "Optional direct APEX URL override. Defaults to the Autonomous Database connection_urls apex_url when autonomous_database_id is supplied."
  type        = string
  default     = null
}

variable "ords_url" {
  description = "Optional direct ORDS URL override. Defaults to the Autonomous Database connection_urls ords_url when autonomous_database_id is supplied."
  type        = string
  default     = null
}

variable "enable_load_balancer" {
  description = "Create or configure private load balancer resources for APEX/ORDS ingress."
  type        = bool
  default     = false

  validation {
    condition     = !var.enable_load_balancer || var.create_load_balancer || var.load_balancer_id != null
    error_message = "When enable_load_balancer is true, set create_load_balancer to true or provide load_balancer_id."
  }

  validation {
    condition     = !var.enable_load_balancer || !var.create_load_balancer || length(var.load_balancer_subnet_ids) > 0
    error_message = "load_balancer_subnet_ids must be set when creating a load balancer."
  }

  validation {
    condition     = !var.enable_load_balancer || !var.enable_listener || upper(var.listener_protocol) != "HTTPS" || length(var.listener_certificate_ids) > 0 || var.listener_certificate_name != null
    error_message = "HTTPS listeners require listener_certificate_ids or listener_certificate_name."
  }

  validation {
    condition     = !var.enable_load_balancer || var.autonomous_database_id != null || var.autonomous_database_private_endpoint_ip != null || length(var.ords_backend_ip_addresses) > 0
    error_message = "When enable_load_balancer is true, provide autonomous_database_id, autonomous_database_private_endpoint_ip, or ords_backend_ip_addresses."
  }
}

variable "create_load_balancer" {
  description = "Create a private OCI Load Balancer. Disable when attaching backend set/listener to an existing load balancer."
  type        = bool
  default     = true
}

variable "load_balancer_id" {
  description = "Existing OCI Load Balancer OCID used when create_load_balancer is false."
  type        = string
  default     = null
}

variable "load_balancer_display_name" {
  description = "Optional load balancer display name."
  type        = string
  default     = null
}

variable "load_balancer_shape" {
  description = "OCI Load Balancer shape."
  type        = string
  default     = "flexible"
}

variable "minimum_bandwidth_in_mbps" {
  description = "Minimum flexible load balancer bandwidth."
  type        = number
  default     = 10
}

variable "maximum_bandwidth_in_mbps" {
  description = "Maximum flexible load balancer bandwidth."
  type        = number
  default     = 100
}

variable "load_balancer_subnet_ids" {
  description = "Subnet OCIDs for the private load balancer."
  type        = list(string)
  default     = []
}

variable "is_private_load_balancer" {
  description = "Create the load balancer as private."
  type        = bool
  default     = true
}

variable "load_balancer_network_security_group_ids" {
  description = "NSG OCIDs attached to the load balancer."
  type        = set(string)
  default     = []
}

variable "load_balancer_ip_mode" {
  description = "Load balancer IP mode."
  type        = string
  default     = "IPV4"
}

variable "is_delete_protection_enabled" {
  description = "Enable delete protection on the load balancer."
  type        = bool
  default     = false
}

variable "is_request_id_enabled" {
  description = "Enable request ID header support on the load balancer."
  type        = bool
  default     = true
}

variable "request_id_header" {
  description = "Request ID header name when request ID support is enabled."
  type        = string
  default     = "opc-request-id"
}

variable "backend_set_name" {
  description = "Optional backend set name. Defaults to a normalized blueprint prefix."
  type        = string
  default     = null
}

variable "backend_set_policy" {
  description = "Load balancer backend set policy."
  type        = string
  default     = "ROUND_ROBIN"
}

variable "ords_backend_ip_addresses" {
  description = "ORDS backend IP addresses. Add ADB private endpoint IPs here when not using the ADB data source output."
  type        = set(string)
  default     = []
}

variable "use_autonomous_database_private_endpoint_ip_as_backend" {
  description = "Use the Autonomous Database private_endpoint_ip from the data source as an ORDS backend."
  type        = bool
  default     = true
}

variable "ords_backend_port" {
  description = "Backend ORDS port."
  type        = number
  default     = 443
}

variable "backend_weight" {
  description = "Load balancer backend weight."
  type        = number
  default     = 1
}

variable "backend_backup" {
  description = "Mark ORDS backend as backup."
  type        = bool
  default     = false
}

variable "backend_drain" {
  description = "Drain ORDS backend connections."
  type        = bool
  default     = false
}

variable "backend_offline" {
  description = "Mark ORDS backend offline."
  type        = bool
  default     = false
}

variable "backend_max_connections" {
  description = "Maximum backend connections."
  type        = number
  default     = null
}

variable "health_checker_protocol" {
  description = "Backend health checker protocol."
  type        = string
  default     = "HTTPS"
}

variable "health_checker_url_path" {
  description = "Backend health checker URL path."
  type        = string
  default     = "/ords/"
}

variable "health_checker_port" {
  description = "Backend health checker port."
  type        = number
  default     = 443
}

variable "health_checker_return_code" {
  description = "Expected health checker HTTP status code."
  type        = number
  default     = 200
}

variable "health_checker_retries" {
  description = "Backend health checker retry count."
  type        = number
  default     = 3
}

variable "health_checker_timeout_in_millis" {
  description = "Backend health checker timeout in milliseconds."
  type        = number
  default     = 3000
}

variable "health_checker_interval_ms" {
  description = "Backend health checker interval in milliseconds."
  type        = number
  default     = 10000
}

variable "health_checker_force_plain_text" {
  description = "Force plain-text health checker behavior."
  type        = bool
  default     = false
}

variable "enable_backend_ssl" {
  description = "Enable backend SSL configuration for HTTPS traffic to ORDS."
  type        = bool
  default     = true
}

variable "backend_certificate_ids" {
  description = "Optional backend SSL certificate OCIDs."
  type        = list(string)
  default     = []
}

variable "backend_certificate_name" {
  description = "Optional backend SSL certificate name."
  type        = string
  default     = null
}

variable "backend_trusted_certificate_authority_ids" {
  description = "Optional backend trusted CA OCIDs."
  type        = list(string)
  default     = []
}

variable "backend_verify_peer_certificate" {
  description = "Verify backend ORDS certificate."
  type        = bool
  default     = false
}

variable "backend_verify_depth" {
  description = "Backend certificate verification depth."
  type        = number
  default     = null
}

variable "backend_ssl_protocols" {
  description = "Backend SSL protocol list."
  type        = list(string)
  default     = ["TLSv1.2", "TLSv1.3"]
}

variable "backend_ssl_cipher_suite_name" {
  description = "Backend SSL cipher suite name."
  type        = string
  default     = null
}

variable "backend_ssl_server_order_preference" {
  description = "Backend SSL server order preference."
  type        = string
  default     = null
}

variable "enable_listener" {
  description = "Create the load balancer listener."
  type        = bool
  default     = true
}

variable "listener_name" {
  description = "Optional listener name."
  type        = string
  default     = null
}

variable "listener_port" {
  description = "Listener port."
  type        = number
  default     = 443
}

variable "listener_protocol" {
  description = "Listener protocol."
  type        = string
  default     = "HTTPS"
}

variable "listener_certificate_ids" {
  description = "Certificate OCIDs for HTTPS listener."
  type        = list(string)
  default     = []
}

variable "listener_certificate_name" {
  description = "Certificate name for HTTPS listener."
  type        = string
  default     = null
}

variable "listener_trusted_certificate_authority_ids" {
  description = "Trusted CA OCIDs for client certificate validation."
  type        = list(string)
  default     = []
}

variable "listener_verify_peer_certificate" {
  description = "Require client certificate verification on the listener."
  type        = bool
  default     = false
}

variable "listener_verify_depth" {
  description = "Listener certificate verification depth."
  type        = number
  default     = null
}

variable "listener_ssl_protocols" {
  description = "Listener SSL protocols."
  type        = list(string)
  default     = ["TLSv1.2", "TLSv1.3"]
}

variable "listener_ssl_cipher_suite_name" {
  description = "Listener SSL cipher suite name."
  type        = string
  default     = null
}

variable "listener_ssl_server_order_preference" {
  description = "Listener SSL server order preference."
  type        = string
  default     = null
}

variable "listener_hostname_names" {
  description = "Optional hostname names attached to the listener."
  type        = list(string)
  default     = []
}

variable "listener_rule_set_names" {
  description = "Optional load balancer rule set names attached to the listener."
  type        = list(string)
  default     = []
}

variable "admin_secret_id" {
  description = "Existing Vault secret OCID containing APEX admin or bootstrap material."
  type        = string
  default     = null
}

variable "enable_admin_secret" {
  description = "Create a Vault secret for APEX admin or workspace bootstrap material."
  type        = bool
  default     = false

  validation {
    condition     = !var.enable_admin_secret || var.admin_secret_id != null || (var.vault_id != null && var.key_id != null && var.admin_secret_content_base64 != null)
    error_message = "When enable_admin_secret is true, provide admin_secret_id or vault_id, key_id, and admin_secret_content_base64."
  }
}

variable "vault_id" {
  description = "Vault OCID used for created APEX admin secret."
  type        = string
  default     = null
}

variable "key_id" {
  description = "KMS key OCID used for created APEX admin secret."
  type        = string
  default     = null
}

variable "admin_secret_name" {
  description = "Optional Vault secret name."
  type        = string
  default     = null
}

variable "admin_secret_content_base64" {
  description = "Base64-encoded APEX admin or bootstrap payload. Supply from local ignored tfvars or pipeline secrets only."
  type        = string
  default     = null
  sensitive   = true
}

variable "admin_secret_content_name" {
  description = "Secret content version name."
  type        = string
  default     = "apex-admin"
}

variable "admin_secret_version_expiry_interval" {
  description = "Optional ISO-8601 duration for secret version expiry, for example P90D."
  type        = string
  default     = null
}
