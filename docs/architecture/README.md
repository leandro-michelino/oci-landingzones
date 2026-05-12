# Architecture Diagrams

Architecture diagrams are source-controlled as Excalidraw files under
`docs/architecture/diagrams/`. Exported images belong under
`docs/architecture/exports/`.

## Diagram Tracker

| Diagram File | Required By | Status |
|---|---|---|
| `00-overview.excalidraw` | `README.md` | TODO |
| `01-iam-compartments.excalidraw` | `core`, `identity/*` | TODO |
| `02-hub-spoke-drg.excalidraw` | Hub-spoke DRG blueprint | TODO |
| `02-hub-spoke-bastion.excalidraw` | Hub-spoke Bastion blueprint | TODO |
| `02-hub-spoke-fastconnect.excalidraw` | Hub-spoke FastConnect blueprint | TODO |
| `02-hub-spoke-ipsec.excalidraw` | Hub-spoke IPSec blueprint | TODO |
| `02-hub-spoke-net-appliance.excalidraw` | Hub-spoke NVA blueprint | TODO |
| `02-hub-spoke-net-firewall.excalidraw` | Hub-spoke OCI Network Firewall blueprint | TODO |
| `03-standalone-vcn.excalidraw` | Standalone VCN blueprints | TODO |
| `04-security-posture.excalidraw` | Security modules | TODO |
| `05-governance.excalidraw` | Governance modules | TODO |
| `06-operating-entity.excalidraw` | Operating entity blueprint | TODO |

## Rules

- Every Terraform blueprint must link to its diagram before real resources are
  added.
- Every diagram source must have an exported image before implementation moves
  beyond scaffold files.
- Diagrams must use OCI naming examples for resource labels.
- Production applies are blocked until the relevant diagram is complete.
- GitHub Actions and repository workflows are intentionally not used for now.
