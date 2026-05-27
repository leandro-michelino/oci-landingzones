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
  value = merge(
    module.network.resource_ids,
    module.fastconnect.resource_ids,
    module.ipsec_vpn.resource_ids,
    {
      azure_vwan_contract = terraform_data.azure_vwan_contract.id
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

output "spoke_vcn_ids" {
  description = "Spoke VCN OCIDs keyed by spoke name."
  value       = module.network.spoke_vcn_ids
}

output "hub_subnet_ids" {
  description = "Hub subnet OCIDs keyed by subnet role."
  value       = module.network.hub_subnet_ids
}

output "spoke_subnet_ids" {
  description = "Spoke subnet OCIDs keyed by spoke name."
  value       = module.network.spoke_subnet_ids
}

output "virtual_circuit_id" {
  description = "FastConnect virtual circuit OCID."
  value       = module.fastconnect.virtual_circuit_id
}

output "ipsec_id" {
  description = "IPSec connection OCID."
  value       = module.ipsec_vpn.ipsec_id
}

output "azure_vwan_contract" {
  description = "Azure Virtual WAN, Virtual Hub, ExpressRoute Gateway, and VNet-to-OCI-spoke routing contract."
  value       = terraform_data.azure_vwan_contract.input
}

output "spoke_vnet_peering_contract" {
  description = "Matrix that maps OCI spoke VCNs to Azure VNets connected through Azure Virtual WAN."
  value       = local.spoke_vnet_peering_matrix
}
