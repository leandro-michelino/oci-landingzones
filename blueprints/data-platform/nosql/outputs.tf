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
  description = "Consolidated map of resource and contract identifiers produced by this blueprint; use it as the primary machine-readable hand-off for integration and runbook steps."
  value = {
    app_network_contract = terraform_data.app_network_contract.id
    app_vcn_id           = try(oci_core_vcn.app[0].id, null)
    app_subnet_id        = try(oci_core_subnet.app[0].id, null)
    nosql_table_id       = oci_nosql_table.this.id
    secondary_index_id   = try(oci_nosql_index.secondary[0].id, null)
    replica_id           = try(oci_nosql_table_replica.this[0].id, null)
    alert_topic_id       = try(oci_ons_notification_topic.alert[0].id, null)
    access_policy_id     = try(oci_identity_policy.access[0].id, null)
    nosql_contract_id    = terraform_data.nosql_contract.id
  }
}

output "nosql_table_id" {
  description = "OCI NoSQL table OCID."
  value       = oci_nosql_table.this.id
}

output "nosql_table_name" {
  description = "OCI NoSQL table name."
  value       = oci_nosql_table.this.name
}

output "nosql_table_state" {
  description = "OCI NoSQL table lifecycle state."
  value       = oci_nosql_table.this.state
}

output "nosql_secondary_index_name" {
  description = "NoSQL secondary index name when enabled."
  value       = var.create_secondary_index ? try(oci_nosql_index.secondary[0].name, null) : null
}

output "nosql_replica_region" {
  description = "NoSQL replica region when enabled."
  value       = var.enable_table_replica ? var.replica_region : null
}

output "nosql_capacity_contract" {
  description = "NoSQL capacity contract for read, write, and storage limits."
  value       = terraform_data.nosql_contract.input.capacity
}

output "app_network_contract" {
  description = "App network contract for NoSQL consumer workloads."
  value       = terraform_data.app_network_contract.input
}

output "alert_topic_name" {
  description = "NoSQL alert notifications topic name."
  value       = try(oci_ons_notification_topic.alert[0].name, null)
}
