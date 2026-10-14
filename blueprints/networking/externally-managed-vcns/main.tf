# Last successful validation: 2026-10-13 | blueprint Terraform init/validate | oracle/oci 9.9.0.
# Last successful lifecycle: 2026-10-13 | DEFAULT | sa-saopaulo-1 | apply, drift=0, destroy/API cleanup.
# Scope: Local output-contract smoke test with empty external-reference maps; no existing network adopted or created. No workload packet-flow verification.
# Evidence: docs/EPHEMERAL-DEPLOYMENT-EVIDENCE.md; module call validated in this blueprint context.
locals {
  external_resource_ids = merge(
    { for key, vcn_id in var.vcn_ids : "vcn_${key}" => vcn_id },
    { for key, subnet_id in var.subnet_ids : "subnet_${key}" => subnet_id },
    { for key, target_id in var.route_target_ids : "route_target_${key}" => target_id },
    var.drg_id == null ? {} : { drg = var.drg_id }
  )
}
