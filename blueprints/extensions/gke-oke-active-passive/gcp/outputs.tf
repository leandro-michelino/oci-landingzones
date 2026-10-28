output "network_id" {
  description = "Created VPC ID."
  value       = module.network.network_id
}

output "subnet_id" {
  description = "Created private subnet ID."
  value       = module.network.subnet_id
}
