output "network_id" {
  description = "Created VPC ID."
  value       = module.network.network_id
}

output "subnet_id" {
  description = "Created private subnet ID."
  value       = module.network.subnet_id
}

output "service_uri" {
  description = "Internal authenticated Cloud Run URI; no OCI token exchange is configured."
  value       = try(google_cloud_run_v2_service.adapter[0].uri, null)
}
