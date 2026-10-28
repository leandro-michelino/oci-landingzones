output "network_id" {
  description = "Created VPC ID."
  value       = try(google_compute_network.this[0].id, null)
}

output "subnet_id" {
  description = "Created private subnet ID."
  value       = try(google_compute_subnetwork.this[0].id, null)
}

output "router_id" {
  description = "Created Cloud Router ID; control plane, not packet forwarding."
  value       = try(google_compute_router.this[0].id, null)
}

output "router_name" {
  description = "Created router name."
  value       = try(google_compute_router.this[0].name, null)
}

output "network_tag" {
  description = "Target tag required on eligible workload VMs."
  value       = var.name
}
