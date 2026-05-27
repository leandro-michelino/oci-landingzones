output "blueprint_name" {
  description = "Stable blueprint deployment identifier used for reporting, runbooks, and cross-blueprint automation hand-offs."
  value       = local.blueprint_name
}
output "name_prefix" {
  description = "Resolved OCI naming prefix applied to resources and contracts in this blueprint; reuse it for consistent naming in downstream automation."
  value       = local.name_prefix
}
output "resource_ids" {
  description = "Consolidated map of resource and contract identifiers produced by this blueprint; use it as the primary machine-readable hand-off for integration and runbook steps."
  value = {
    container_instance = try(oci_container_instances_container_instance.this[0].id, null)
    access_policy      = try(oci_identity_policy.access[0].id, null)
  }
}
output "container_instance_id" {
  description = "Container Instance OCID."
  value       = try(oci_container_instances_container_instance.this[0].id, null)
}
output "container_instance_state" {
  description = "Container Instance lifecycle state."
  value       = try(oci_container_instances_container_instance.this[0].state, null)
}
output "vnic_ids" {
  description = "VNIC OCIDs attached to the Container Instance."
  value       = try([for vnic in oci_container_instances_container_instance.this[0].vnics : vnic.vnic_id], [])
}
output "container_ids" {
  description = "Container IDs created inside the Container Instance."
  value       = try([for container in oci_container_instances_container_instance.this[0].containers : container.container_id], [])
}
output "access_policy_id" {
  description = "Optional IAM policy OCID."
  value       = try(oci_identity_policy.access[0].id, null)
}
