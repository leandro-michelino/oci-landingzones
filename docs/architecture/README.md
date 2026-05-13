# Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Architecture intent lives close to the Terraform that implements it. Deployable
blueprint folders keep their design scope, assumptions, and update guidance in a
local `architecture/README.md` beside the blueprint README so the use case stays
self-contained.

Rendered review artifacts should be generated only when a customer or design
review package needs them. Editable diagram sources and tool-specific work files
should stay outside the reusable blueprint tree unless they become an approved
repository artifact.

## Tracker

| Architecture Area | Required By | Status |
|---|---|---|
| Blueprint-local `architecture/README.md` files | Core, CIS, identity, networking, operating entity, extension, compliance, data, disaster recovery, and industry folders | Architecture notes maintained |

## Rules

- Every deployable blueprint keeps architecture notes in its local
  `architecture/` folder.
- Draft, detailed LLD, professional, or customer-specific variants should be
  promoted into the canonical artifact or kept outside the reusable blueprint
  tree.
- Every production/customer-facing diagram should have a rendered export before
  implementation moves into customer review.
- Diagrams must use OCI naming examples for resource labels.
- Production applies are blocked until the relevant architecture notes are
  complete and any required rendered review artifact is approved.
- GitHub Actions and repository workflows are intentionally not used for now.
