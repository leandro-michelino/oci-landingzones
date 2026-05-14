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
