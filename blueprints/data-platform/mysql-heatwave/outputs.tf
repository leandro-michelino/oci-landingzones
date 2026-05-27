output "blueprint_name" {
  description = "Stable blueprint deployment identifier used for reporting, runbooks, and cross-blueprint automation hand-offs."
  value       = local.blueprint_name
}
output "name_prefix" {
  description = "Resolved OCI naming prefix applied to resources and contracts in this blueprint; reuse it for consistent naming in downstream automation."
  value       = local.name_prefix
}
output "resource_ids" {
  description = "Map of resource identifiers created or referenced by this blueprint."
  value = {
    vcn              = try(oci_core_vcn.mysql[0].id, null)
    subnet           = try(oci_core_subnet.mysql[0].id, null)
    nsg              = try(oci_core_network_security_group.mysql[0].id, null)
    db_system        = local.db_system_id
    heatwave_cluster = local.heatwave_cluster_id
    lakehouse_bucket = try(oci_objectstorage_bucket.lakehouse[0].id, null)
    access_policy    = try(oci_identity_policy.access[0].id, null)
  }
}
output "private_network" {
  description = "Optional private network resources created by this blueprint."
  value = {
    vcn_id    = try(oci_core_vcn.mysql[0].id, null)
    subnet_id = try(oci_core_subnet.mysql[0].id, null)
    nsg_id    = try(oci_core_network_security_group.mysql[0].id, null)
  }
}
output "mysql_db_system_id" {
  description = "MySQL DB System OCID."
  value       = local.db_system_id
}
output "heatwave_cluster_id" {
  description = "HeatWave cluster identifier."
  value       = local.heatwave_cluster_id
}
output "mysql_endpoints" {
  description = "MySQL DB System endpoint metadata when Terraform creates the DB System."
  value       = try(oci_mysql_mysql_db_system.this[0].endpoints, [])
}
output "lakehouse_bucket_name" {
  description = "Lakehouse Object Storage bucket name."
  value       = try(oci_objectstorage_bucket.lakehouse[0].name, local.lakehouse_bucket_name)
}
output "access_policy_id" {
  description = "IAM policy OCID for MySQL HeatWave access."
  value       = try(oci_identity_policy.access[0].id, null)
}
