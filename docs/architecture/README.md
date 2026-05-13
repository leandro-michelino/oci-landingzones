# Architecture Diagrams

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Architecture diagrams may live either in this shared architecture area or in a
blueprint's own local architecture folder. Deployable blueprint folders keep
their architecture notes beside the blueprint README so the use case stays
self-contained. Rendered exports are generated only when a review artifact is
needed.

## Diagram Tracker

| Architecture Area | Required By | Status |
|---|---|---|
| `docs/architecture/diagrams/` | Shared rendered or reference artifacts | Cleaned of editable sources |
| Blueprint-local `architecture/README.md` files | Core, CIS, identity, networking, operating entity, extension, compliance, data, disaster recovery, and industry folders | Architecture notes maintained |

## Rules

- Every Terraform blueprint must link to its diagram before real resources are
  added.
- Every deployable blueprint keeps architecture notes in its local
  `architecture/` folder.
- Draft, detailed LLD, professional, or customer-specific variants should be
  promoted into the canonical artifact or kept outside the reusable blueprint
  tree.
- Every production/customer-facing diagram should have a rendered export before
  implementation moves into customer review.
- Diagrams must use OCI naming examples for resource labels.
- Production applies are blocked until the relevant diagram is complete.
- GitHub Actions and repository workflows are intentionally not used for now.
