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
    vcn              = oci_core_vcn.this.id
    internet_gateway = try(oci_core_internet_gateway.this[0].id, null)
    nat_gateway      = try(oci_core_nat_gateway.this[0].id, null)
    service_gateway  = try(oci_core_service_gateway.this[0].id, null)
  }
}

output "vcn_id" {
  description = "VCN OCID."
  value       = oci_core_vcn.this.id
}

output "vcn_cidr_blocks" {
  description = "VCN CIDR blocks."
  value       = oci_core_vcn.this.cidr_blocks
}

output "subnet_ids" {
  description = "Subnet OCIDs keyed by logical subnet name."
  value       = { for key, subnet in oci_core_subnet.this : key => subnet.id }
}

output "route_table_ids" {
  description = "Route table OCIDs keyed by logical route table name."
  value       = { for key, route_table in oci_core_route_table.this : key => route_table.id }
}

output "security_list_ids" {
  description = "Security list OCIDs keyed by logical security list name."
  value       = local.security_list_ids
}

output "gateway_ids" {
  description = "Gateway OCIDs keyed by logical gateway name."
  value = {
    internet = try(oci_core_internet_gateway.this[0].id, null)
    nat      = try(oci_core_nat_gateway.this[0].id, null)
    service  = try(oci_core_service_gateway.this[0].id, null)
  }
}
