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
    oci_network_contract_id    = terraform_data.oci_network_contract.id
    connectivity_contract_id   = terraform_data.connectivity_contract.id
    replication_contract_id    = terraform_data.replication_contract.id
    dns_failover_contract_id   = terraform_data.dns_failover_contract.id
    runbook_contract_id        = terraform_data.runbook_contract.id
    oci_primary_vcn_id         = try(oci_core_vcn.primary[0].id, null)
    oci_primary_subnet_id      = try(oci_core_subnet.primary_db[0].id, null)
    oci_primary_route_table_id = try(oci_core_route_table.primary_db[0].id, null)
    oci_primary_security_list  = try(oci_core_security_list.primary_db[0].id, null)
    oci_primary_drg_id         = try(oci_core_drg.primary[0].id, null)
    oci_primary_drg_attachment = try(oci_core_drg_attachment.primary_db[0].id, null)
    oci_primary_cpe_id         = try(oci_core_cpe.aws[0].id, null)
    oci_primary_ipsec_id       = try(oci_core_ipsec.aws[0].id, null)
    oci_mysql_db_system_id     = local.db_system_id_effective
    oci_heatwave_cluster_id    = local.heatwave_id_effective
    oci_lakehouse_bucket_id    = try(oci_objectstorage_bucket.lakehouse[0].id, null)
    oci_dr_alert_topic_id      = try(oci_ons_notification_topic.dr_alert[0].id, null)
  }
}

output "oci_network_contract" {
  description = "OCI-side networking hand-off contract containing effective VCN, subnet, route table, security list, DRG, and IPSec references for the primary database stack."
  value       = terraform_data.oci_network_contract.input
}

output "connectivity_contract" {
  description = "IPSec connectivity contract with DRG, CPE, tunnel, and CIDR metadata used by network operations and incident runbooks."
  value       = terraform_data.connectivity_contract.input
}

output "replication_contract" {
  description = "Cross-cloud replication contract covering channel name, source/target endpoints, replication identity, TLS requirement, and target RPO objective."
  value       = terraform_data.replication_contract.input
}

output "dns_failover_contract" {
  description = "Database DNS cutover contract with OCI-primary and AWS-secondary endpoints, TTL values, and approval requirement metadata."
  value       = terraform_data.dns_failover_contract.input
}

output "runbook_contract" {
  description = "Operational runbook contract listing failover/failback sequence expectations and drill cadence with RTO/RPO targets."
  value       = terraform_data.runbook_contract.input
}

output "oci_mysql_primary_db_system_id" {
  description = "OCI MySQL primary DB System OCID created or referenced by this blueprint."
  value       = local.db_system_id_effective
}

output "oci_mysql_primary_heatwave_cluster_id" {
  description = "OCI HeatWave cluster identifier created or referenced for the primary database analytics plane."
  value       = local.heatwave_id_effective
}

output "oci_mysql_primary_endpoints" {
  description = "OCI MySQL endpoint metadata when Terraform creates the primary DB System."
  value       = try(oci_mysql_mysql_db_system.primary[0].endpoints, [])
}

output "oci_lakehouse_bucket_name" {
  description = "OCI Object Storage bucket name used for HeatWave lakehouse data and DR evidence artifacts."
  value       = try(oci_objectstorage_bucket.lakehouse[0].name, local.lakehouse_bucket_name)
}

output "oci_dr_alert_topic_name" {
  description = "OCI Notifications topic name used for replication, failover, and drill alert signaling."
  value       = try(oci_ons_notification_topic.dr_alert[0].name, null)
}
