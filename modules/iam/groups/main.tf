# Last successful validation: 2026-10-14 | Terraform init/validate | oracle/oci 9.9.0.
# Scope: isolated module schema validation; no live apply or traffic verification.
# Evidence: docs/EPHEMERAL-DEPLOYMENT-EVIDENCE.md (module validation metadata).
resource "oci_identity_group" "this" {
  for_each = local.groups

  compartment_id = var.tenancy_ocid
  name           = each.value.name
  description    = each.value.description
  defined_tags   = var.defined_tags
  freeform_tags  = var.freeform_tags
}
