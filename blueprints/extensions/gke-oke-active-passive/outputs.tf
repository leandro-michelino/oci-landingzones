output "blueprint_name" {
  description = "Stable blueprint identifier."
  value       = "extensions-gke-oke-active-passive"
}

output "cluster_id" {
  description = "OKE cluster ID; apps and data synchronization are separate."
  value       = module.oke.cluster_id
}
