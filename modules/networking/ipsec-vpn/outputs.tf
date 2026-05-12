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
  description = "Map of primary resource identifiers created by this module."
  value = {
    cpe   = try(oci_core_cpe.this[0].id, null)
    ipsec = try(oci_core_ipsec.this[0].id, null)
  }
}

output "cpe_id" {
  description = "CPE OCID."
  value       = try(oci_core_cpe.this[0].id, null)
}

output "ipsec_id" {
  description = "IPSec connection OCID."
  value       = try(oci_core_ipsec.this[0].id, null)
}

output "ipsec_state" {
  description = "IPSec lifecycle state."
  value       = try(oci_core_ipsec.this[0].state, null)
}
