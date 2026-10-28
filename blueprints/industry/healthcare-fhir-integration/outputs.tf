output "blueprint_name" {
  description = "Hospital/FHIR integration infrastructure identifier."
  value       = local.blueprint_name
}
output "name_prefix" {
  description = "Resolved integration project prefix."
  value       = local.name_prefix
}
output "resource_ids" {
  description = "Created integration resources only; backend, identity, KMS and DRG remain external."
  value       = merge({ vcn = try(oci_core_vcn.this[0].id, null), gateway = try(oci_apigateway_gateway.fhir[0].id, null), deployment = try(oci_apigateway_deployment.fhir[0].id, null), queue = try(oci_queue_queue.integration[0].id, null) }, { for k, v in oci_core_subnet.private : "subnet.${k}" => v.id })
}
output "fhir_endpoint" {
  description = "Private API deployment endpoint; not a verified FHIR server or SMART-on-FHIR endpoint."
  value       = try(oci_apigateway_deployment.fhir[0].endpoint, null)
}
output "integration_subnet_id" {
  description = "Private subnet for separately deployed integration workers."
  value       = try(oci_core_subnet.private["integration"].id, null)
}
output "integration_nsg_id" {
  description = "NSG for separately deployed workers; only regional OSN HTTPS egress is configured."
  value       = try(oci_core_network_security_group.tier["integration"].id, null)
}
