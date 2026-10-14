# Last successful validation: 2026-10-14 | Terraform init/validate | oracle/oci 9.9.0.
# Scope: isolated module schema validation; no live apply or traffic verification.
# Evidence: docs/EPHEMERAL-DEPLOYMENT-EVIDENCE.md (module validation metadata).
resource "oci_identity_policy" "this" {
  for_each = local.policies

  compartment_id = each.value.compartment_id
  name           = each.value.name
  description    = each.value.description
  statements     = each.value.statements
  defined_tags   = var.defined_tags
  freeform_tags  = var.freeform_tags
}
