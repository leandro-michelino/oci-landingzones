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
    oda_network_contract_id = terraform_data.oda_network_contract.id
    oda_vcn_id              = try(oci_core_vcn.oda[0].id, null)
    oda_subnet_id           = try(oci_core_subnet.oda[0].id, null)
    oda_nsg_id              = try(oci_core_network_security_group.oda[0].id, null)
    oda_instance_id         = local.oda_instance_id_effective
    oda_private_endpoint_id = local.oda_private_endpoint_id_effective
    oda_attachment_id       = try(oci_oda_oda_private_endpoint_attachment.this[0].id, null)
    oda_alert_topic_id      = try(oci_ons_notification_topic.alert[0].id, null)
    oda_access_policy_id    = try(oci_identity_policy.access[0].id, null)
    oda_contract_id         = terraform_data.oda_contract.id
  }
}

output "oda_instance_id" {
  description = "ODA instance OCID."
  value       = local.oda_instance_id_effective
}

output "oda_instance_state" {
  description = "ODA instance lifecycle state."
  value       = var.create_oda_instance ? try(oci_oda_oda_instance.this[0].state, null) : null
}

output "oda_instance_web_app_url" {
  description = "ODA web application URL for console access."
  value       = var.create_oda_instance ? try(oci_oda_oda_instance.this[0].web_app_url, null) : null
}

output "oda_instance_connector_url" {
  description = "ODA connector URL for integration channels."
  value       = var.create_oda_instance ? try(oci_oda_oda_instance.this[0].connector_url, null) : null
}

output "oda_private_endpoint_id" {
  description = "ODA private endpoint OCID."
  value       = local.oda_private_endpoint_id_effective
}

output "oda_private_endpoint_state" {
  description = "ODA private endpoint lifecycle state."
  value       = var.create_oda_private_endpoint ? try(oci_oda_oda_private_endpoint.this[0].state, null) : null
}

output "oda_network_contract" {
  description = "ODA network contract for endpoint placement and routing hand-off."
  value       = terraform_data.oda_network_contract.input
}

output "oda_operational_contract" {
  description = "ODA operational contract with shape, access, and endpoint attachment details."
  value       = terraform_data.oda_contract.input
}

output "alert_topic_name" {
  description = "ODA alert notifications topic name."
  value       = try(oci_ons_notification_topic.alert[0].name, null)
}
