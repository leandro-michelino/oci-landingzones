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

output "root_compartment_id" {
  description = "OCID of the landing zone root compartment."
  value       = oci_identity_compartment.root.id
}

output "root_compartment_name" {
  description = "Display name of the landing zone root compartment."
  value       = oci_identity_compartment.root.name
}

output "child_compartment_ids" {
  description = "Map of child compartment keys to OCIDs."
  value = {
    for key, compartment in oci_identity_compartment.children : key => compartment.id
  }
}

output "child_compartment_names" {
  description = "Map of child compartment keys to display names."
  value = {
    for key, compartment in oci_identity_compartment.children : key => compartment.name
  }
}

output "compartment_ids" {
  description = "Map of all landing zone compartment keys to OCIDs."
  value = merge(
    {
      root = oci_identity_compartment.root.id
    },
    {
      for key, compartment in oci_identity_compartment.children : key => compartment.id
    }
  )
}

output "compartment_names" {
  description = "Map of all landing zone compartment keys to display names."
  value = merge(
    {
      root = oci_identity_compartment.root.name
    },
    {
      for key, compartment in oci_identity_compartment.children : key => compartment.name
    }
  )
}

output "resource_ids" {
  description = "Map of resource identifiers created by this module."
  value = merge(
    {
      root = oci_identity_compartment.root.id
    },
    {
      for key, compartment in oci_identity_compartment.children : key => compartment.id
    }
  )
}
