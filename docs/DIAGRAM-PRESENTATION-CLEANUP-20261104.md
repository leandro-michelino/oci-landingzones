# Diagram presentation cleanup — 2026-11-04

Removed standalone source-audit paragraphs, repeated implementation-absence summaries, runtime-proof disclaimers and summary footers from the architecture authoring generators and their exported documents. This includes the OCI cluster/default-contract and AWS IAM/readiness paragraphs identified by the repository owner in the OKE/AKS/EKS drawings. Unused footer helpers, text dictionaries and scope-note plumbing were removed so regeneration cannot restore those blocks.

The catalog was rebuilt from its registered authoring scripts, including companion resource and existing-input pages. **89 blueprint overviews and the conceptual three-tier overview** changed: **90 paired draw.io/PNG documents**, with **129 standalone text/summary vertices removed**. Short repeated review clauses were also removed from legends and labels. Four blueprint overviews and the presentation banner did not require content changes. Companion inventory and input-page content remains unchanged.

Official icons, resource creation conditions, configuration values, external-resource labels, connector legends and technical prerequisites remain with their relevant resources or relationships. The separate Interconnect/FastConnect and optional VPN paths remain intact. Application arrows retain their original meaning. No Terraform, Bicep, CloudFormation or Ansible deployment behavior changed.

## Verification

- Rebuilt the full catalog from the authoring generators; all 93 blueprint source/resource maps passed.
- Exported the 90 changed native documents through draw.io Desktop and reviewed contact sheets, with larger checks of the identified OKE/EKS drawing and representative layouts.
- Checked all 349 registered native documents/PNG pairs, page IDs/references, generated-source equality, geometry and all 735 connector relationships. Only removal of review clauses from endpoint labels changes the relationship snapshots; endpoints, arrows, connector labels and paths remain the same.
- Existing nine Python regressions and repository documentation/catalog/local-link checks passed.
- Confirmed the identified paragraphs and repeated runtime-review clauses are absent from the generated native documents and authoring sources.

This is a presentation-only follow-up to the [repository review](REPOSITORY-REVIEW-20261104.md). Its provider versions and cloud-validation results have not been re-dated or expanded. No cloud deployment or live network test was performed for this cleanup.
