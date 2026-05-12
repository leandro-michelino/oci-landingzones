# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
output "module_name" {
  description = "Module identifier."
  value       = local.module_name
}

output "name_prefix" {
  description = "Standard OCI naming prefix for resources created by this module."
  value       = local.name_prefix
}

output "cis_level" {
  description = "Selected CIS OCI Benchmark profile."
  value       = local.cis_level
}

output "resource_ids" {
  description = "Map of resource identifiers created by this module."
  value = {
    virtual_circuit = try(oci_core_virtual_circuit.this[0].id, null)
  }
}

output "virtual_circuit_id" {
  description = "FastConnect virtual circuit OCID."
  value       = try(oci_core_virtual_circuit.this[0].id, null)
}

output "virtual_circuit_state" {
  description = "FastConnect virtual circuit lifecycle state."
  value       = try(oci_core_virtual_circuit.this[0].state, null)
}

output "provider_state" {
  description = "FastConnect provider state for partner circuits."
  value       = try(oci_core_virtual_circuit.this[0].provider_state, null)
}
