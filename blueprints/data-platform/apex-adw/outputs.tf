# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
output "blueprint_name" {
  description = "Blueprint identifier."
  value       = local.blueprint_name
}

output "name_prefix" {
  description = "Standard OCI naming prefix for resources created by this blueprint."
  value       = local.name_prefix
}

output "resource_ids" {
  description = "Map of resource identifiers created by this blueprint."
  value = {
    autonomous_database = var.autonomous_database_id
    load_balancer       = local.load_balancer_id
    backend_set         = try(oci_load_balancer_backend_set.ords[0].id, null)
    listener            = try(oci_load_balancer_listener.https[0].id, null)
    admin_secret        = local.admin_secret_id
  }
}

output "autonomous_database_id" {
  description = "Autonomous Database OCID that hosts APEX."
  value       = var.autonomous_database_id
}

output "autonomous_database_private_endpoint_ip" {
  description = "Autonomous Database private endpoint IP used for ORDS backend routing."
  value       = local.autonomous_database_private_endpoint_ip
}

output "apex_workspace_name" {
  description = "APEX workspace name to bootstrap or hand off."
  value       = var.apex_workspace_name
}

output "apex_admin_username" {
  description = "APEX workspace admin username to bootstrap or hand off."
  value       = var.apex_admin_username
}

output "apex_direct_url" {
  description = "Direct ADB APEX URL from the Autonomous Database API or override."
  value       = local.direct_apex_url
}

output "ords_direct_url" {
  description = "Direct ADB ORDS URL from the Autonomous Database API or override."
  value       = local.direct_ords_url
}

output "apex_private_url" {
  description = "Private APEX URL using the supplied DNS name and APEX path."
  value       = local.private_apex_url
}

output "load_balancer_id" {
  description = "Created or referenced load balancer OCID."
  value       = local.load_balancer_id
}

output "load_balancer_ip_address_details" {
  description = "IP address details for the created load balancer."
  value       = try(oci_load_balancer_load_balancer.this[0].ip_address_details, [])
}

output "backend_set_name" {
  description = "ORDS backend set name."
  value       = try(oci_load_balancer_backend_set.ords[0].name, null)
}

output "listener_name" {
  description = "APEX/ORDS listener name."
  value       = try(oci_load_balancer_listener.https[0].name, null)
}

output "ords_backend_ip_addresses" {
  description = "ORDS backend IP addresses attached to the backend set."
  value       = local.ords_backend_ip_addresses
}

output "admin_secret_id" {
  description = "Vault secret OCID containing APEX admin or bootstrap material."
  value       = local.admin_secret_id
}

output "apex_details" {
  description = "APEX and ORDS version details returned by Autonomous Database."
  value       = try(data.oci_database_autonomous_database.this[0].apex_details, null)
}
