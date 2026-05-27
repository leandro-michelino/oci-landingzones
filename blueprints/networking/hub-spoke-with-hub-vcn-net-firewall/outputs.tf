output "blueprint_name" {
  description = "Stable blueprint deployment identifier used for reporting, runbooks, and cross-blueprint automation hand-offs."
  value       = local.blueprint_name
}

output "name_prefix" {
  description = "Resolved OCI naming prefix applied to resources and contracts in this blueprint; reuse it for consistent naming in downstream automation."
  value       = local.name_prefix
}
output "resource_ids" {
  description = "Map of primary resource identifiers created by this blueprint."
  value = merge(
    module.network.resource_ids,
    {
      firewall_policy = module.network_firewall.network_firewall_policy_id
      firewall        = module.network_firewall.network_firewall_id
    }
  )
}

output "hub_vcn_id" {
  description = "Hub VCN OCID."
  value       = module.network.hub_vcn_id
}

output "drg_id" {
  description = "DRG OCID."
  value       = module.network.drg_id
}

output "hub_subnet_ids" {
  description = "Hub subnet OCIDs keyed by role."
  value       = module.network.hub_subnet_ids
}

output "network_firewall_id" {
  description = "OCI Network Firewall OCID."
  value       = module.network_firewall.network_firewall_id
}

output "network_firewall_private_ip" {
  description = "OCI Network Firewall private IPv4 address."
  value       = module.network_firewall.network_firewall_private_ip
}
