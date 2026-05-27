output "blueprint_name" {
  description = "Stable blueprint deployment identifier used for reporting, runbooks, and cross-blueprint automation hand-offs."
  value       = local.blueprint_name
}
output "name_prefix" {
  description = "Resolved OCI naming prefix applied to resources and contracts in this blueprint; reuse it for consistent naming in downstream automation."
  value       = local.name_prefix
}
output "resource_ids" {
  description = "Map of resource identifiers created or referenced by this blueprint."
  value = {
    network_load_balancer = local.network_load_balancer_id
    backend_sets          = { for key, backend_set in oci_network_load_balancer_backend_set.this : key => backend_set.id }
    backends              = { for key, backend in oci_network_load_balancer_backend.this : key => backend.id }
    listeners             = { for key, listener in oci_network_load_balancer_listener.this : key => listener.id }
    access_policy         = try(oci_identity_policy.access[0].id, null)
  }
}
output "network_load_balancer_id" {
  description = "Network Load Balancer OCID."
  value       = local.network_load_balancer_id
}
output "network_load_balancer_ip_addresses" {
  description = "Assigned Network Load Balancer IP addresses when Terraform creates it."
  value       = try(oci_network_load_balancer_network_load_balancer.this[0].ip_addresses, [])
}
output "backend_set_names" {
  description = "Backend set names keyed by logical name."
  value       = { for key, backend_set in oci_network_load_balancer_backend_set.this : key => backend_set.name }
}
output "listener_ids" {
  description = "Listener OCIDs keyed by logical name."
  value       = { for key, listener in oci_network_load_balancer_listener.this : key => listener.id }
}
output "access_policy_id" {
  description = "IAM policy OCID for Network Load Balancer access."
  value       = try(oci_identity_policy.access[0].id, null)
}
