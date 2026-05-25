# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
output "blueprint_name" {
  description = "Stable blueprint deployment identifier used for reporting, runbooks, and cross-blueprint automation hand-offs."
  value       = local.blueprint_name
}

output "name_prefix" {
  description = "Resolved OCI naming prefix applied to resources and contracts in this blueprint; reuse it for consistent naming in downstream automation."
  value       = local.name_prefix
}

output "resource_ids" {
  description = "Consolidated map of resource identifiers created by this blueprint."
  value = merge(
    module.network.resource_ids,
    { for key, instance in oci_core_instance.fortigate : "fortigate_instance_${key}" => instance.id },
    { for key, attachment in oci_core_vnic_attachment.fortigate_interface : "fortigate_vnic_attachment_${key}" => attachment.id },
    { for key, private_ip in oci_core_private_ip.fortigate_floating : "fortigate_floating_private_ip_${key}" => private_ip.id },
    {
      fortigate_dynamic_group = try(oci_identity_dynamic_group.fortigate[0].id, null)
      fortigate_policy        = try(oci_identity_policy.fortigate[0].id, null)
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

output "spoke_vcn_ids" {
  description = "Spoke VCN OCIDs keyed by spoke name."
  value       = module.network.spoke_vcn_ids
}

output "spoke_subnet_ids" {
  description = "Spoke subnet OCIDs keyed by spoke name."
  value       = module.network.spoke_subnet_ids
}

output "fortigate_instance_ids" {
  description = "FortiGate HA compute instance OCIDs keyed by node."
  value       = { for key, instance in oci_core_instance.fortigate : key => instance.id }
}

output "fortigate_mgmt_private_ips" {
  description = "FortiGate management private IP addresses keyed by node."
  value       = { for key, instance in oci_core_instance.fortigate : key => instance.private_ip }
}

output "fortigate_secondary_vnic_ids" {
  description = "FortiGate secondary VNIC OCIDs keyed by node-interface."
  value       = { for key, attachment in oci_core_vnic_attachment.fortigate_interface : key => attachment.vnic_id }
}

output "fortigate_floating_private_ip_ids" {
  description = "Reserved FortiGate floating private IP OCIDs keyed by purpose."
  value       = { for key, private_ip in oci_core_private_ip.fortigate_floating : key => private_ip.id }
}

output "fortigate_dynamic_group_id" {
  description = "Dynamic group OCID for FortiGate HA instance-principal failover automation."
  value       = try(oci_identity_dynamic_group.fortigate[0].id, null)
}

output "fortigate_policy_id" {
  description = "IAM policy OCID for FortiGate HA instance-principal failover automation."
  value       = try(oci_identity_policy.fortigate[0].id, null)
}
