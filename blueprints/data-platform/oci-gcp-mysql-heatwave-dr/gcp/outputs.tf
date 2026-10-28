output "network_id" {
  description = "Created VPC ID."
  value       = module.network.network_id
}

output "subnet_id" {
  description = "Created private subnet ID."
  value       = module.network.subnet_id
}

output "private_ip" {
  description = "Private Cloud SQL IP; independent database until external replication setup."
  value       = try(google_sql_database_instance.standby[0].private_ip_address, null)
}
