output "blueprint_name" {
  description = "OCVS blueprint identifier."
  value       = local.blueprint_name
}
output "resource_ids" {
  description = "Only created resources; existing networking is not adopted."
  value       = { sddc = try(oci_ocvp_sddc.this[0].id, null) }
}
output "management_endpoints" {
  description = "SDDC management FQDNs only; no passwords or verified reachability. Protect deployment state and saved plans separately."
  value = {
    vcenter_fqdn     = try(oci_ocvp_sddc.this[0].vcenter_fqdn, null)
    nsx_manager_fqdn = try(oci_ocvp_sddc.this[0].nsx_manager_fqdn, null)
  }
}
output "network_references" {
  description = "Supplied network identifiers, not created resources or a working private path."
  value       = { vcn_id = var.vcn_id, cluster_networks = { for key, c in local.clusters : key => { provisioning_subnet_id = c.provisioning_subnet_id, vlan_ids = c.vlan_ids } } }
}
