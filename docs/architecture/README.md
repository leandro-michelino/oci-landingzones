# Architecture Diagrams

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Architecture diagrams may live either in this shared architecture area or in a
blueprint's own local architecture folder. Shared Phase 7 sources live in
`docs/architecture/diagrams/`. New deployment folders should keep their editable
Excalidraw source beside the blueprint README so the use case stays
self-contained. PNG exports are generated only when a rendered review artifact
is needed.

## Diagram Tracker

| Diagram File | Required By | Status |
|---|---|---|
| `docs/architecture/diagrams/00-overview.excalidraw` | Repository overview | Source created |
| `docs/architecture/diagrams/01-iam-compartments.excalidraw` | IAM and compartment foundation | Source created |
| `docs/architecture/diagrams/04-security-posture.excalidraw` | Shared security posture | Source created |
| `docs/architecture/diagrams/05-governance.excalidraw` | Shared governance and operations | Source created |
| `docs/architecture/diagrams/09-cis-level1.excalidraw` | CIS Level 1 blueprint | Source created |
| `docs/architecture/diagrams/09-cis-level2.excalidraw` | CIS Level 2 blueprint | Source created |
| Blueprint-local architecture sources | Core, CIS, identity, networking, operating entity, extension, compliance, data, disaster recovery, and industry folders | Source created |

## Rules

- Every Terraform blueprint must link to its diagram before real resources are
  added.
- Every production/customer-facing diagram source should have a rendered PNG
  export before implementation moves into customer review.
- Diagrams must use OCI naming examples for resource labels.
- Production applies are blocked until the relevant diagram is complete.
- GitHub Actions and repository workflows are intentionally not used for now.
