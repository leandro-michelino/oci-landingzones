# Architecture Diagrams

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Architecture diagrams may live either in this shared architecture area or in the
blueprint's own `architecture/` folder. New deployment folders should keep their
editable Excalidraw source and exported image beside the blueprint README so the
use case stays self-contained.

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
| `blueprints/operating-entity/architecture/operating-entity.excalidraw` | Single operating entity blueprint | TODO |
| `blueprints/operating-entity/multi-operating-entities/architecture/multi-operating-entities.excalidraw` | Multi-operating-entity blueprint | TODO |
| `blueprints/operating-entity/workload-vending/architecture/workload-vending.excalidraw` | Workload vending blueprint | TODO |
| `09-cis-level1.excalidraw` | CIS Level 1 landing zone blueprint | TODO |
| `09-cis-level2.excalidraw` | CIS Level 2 landing zone blueprint | TODO |

## Rules

- Every Terraform blueprint must link to its diagram before real resources are
  added.
- Every diagram source must have an exported image before implementation moves
  beyond scaffold files.
- Diagrams must use OCI naming examples for resource labels.
- Production applies are blocked until the relevant diagram is complete.
- GitHub Actions and repository workflows are intentionally not used for now.
