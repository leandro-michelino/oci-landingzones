# Last successful validation: 2026-10-14 | Terraform init/validate | oracle/oci 9.9.0.
# Scope: isolated module schema validation; no live apply or traffic verification.
# Evidence: docs/EPHEMERAL-DEPLOYMENT-EVIDENCE.md (module validation metadata).
resource "oci_bastion_bastion" "this" {
  count = var.enable_bastion ? 1 : 0

  bastion_type                 = var.bastion_type
  compartment_id               = var.compartment_ocid
  target_subnet_id             = var.target_subnet_id
  name                         = "${local.name_prefix}-bst-${var.bastion_label}"
  client_cidr_block_allow_list = var.client_cidr_block_allow_list
  max_session_ttl_in_seconds   = var.max_session_ttl_in_seconds
  dns_proxy_status             = var.dns_proxy_status
  defined_tags                 = var.defined_tags
  freeform_tags = merge(
    var.freeform_tags,
    {
      Blueprint = local.module_name
    }
  )
}
