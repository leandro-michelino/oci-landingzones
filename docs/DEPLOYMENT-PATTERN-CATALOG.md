# Deployment Pattern Catalog

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This catalog keeps the deployment menu broader than a single reference
implementation. It borrows from OCI landing zone repositories, OCI reference
architectures, and patterns that show up in real customer conversations.

Each pattern should have a self-contained blueprint folder with its own
`README.md`, `architecture/README.md`, Terraform files, variables example, and
validation notes. Status `Implementing` means the folder has deployable
foundation wiring, even when some expensive or external resources are disabled
by default.

## Pattern Families

| Family | Pattern | Blueprint | Status |
|---|---|---|---|
| Core | Core landing zone with no application networking | `blueprints/core/` | Implementing |
| CIS | CIS Level 1 landing zone | `blueprints/cis/level1/` | Implementing |
| CIS | CIS Level 2 landing zone | `blueprints/cis/level2/` | Implementing |
| Identity | CIS basic identity baseline | `blueprints/identity/cis-basic/` | Scaffold |
| Identity | New identity domain | `blueprints/identity/new-identity-domain/` | Scaffold |
| Identity | Custom identity domain | `blueprints/identity/custom-identity-domain/` | Scaffold |
| Operating entity | Single operating entity onboarding | `blueprints/operating-entity/` | Scaffold |
| Operating entity | Multi-operating-entity landing zone | `blueprints/operating-entity/multi-operating-entities/` | Scaffold |
| Operating entity | Workload vending / application team onboarding | `blueprints/operating-entity/workload-vending/` | Scaffold |
| Networking | Standalone three-tier VCN defaults | `blueprints/networking/standalone-three-tier-vcn-defaults/` | Implementing |
| Networking | Standalone three-tier VCN custom | `blueprints/networking/standalone-three-tier-vcn-custom/` | Implementing |
| Networking | Standalone three-tier VCN with ZPR | `blueprints/networking/standalone-three-tier-vcn-zpr/` | Implementing |
| Networking | Standalone private endpoint only | `blueprints/networking/standalone-private-endpoint-only/` | Implementing |
| Networking | Externally managed VCNs | `blueprints/networking/externally-managed-vcns/` | Implementing |
| Networking | Hub-spoke with DRG and three-tier VCNs | `blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns/` | Implementing |
| Networking | Hub-spoke with IPSec VPN | `blueprints/networking/hub-spoke-with-hub-vcn-ipsec-vpn/` | Implementing |
| Networking | Hub-spoke with FastConnect virtual circuit | `blueprints/networking/hub-spoke-with-hub-vcn-fastconnect-vc/` | Implementing |
| Networking | Hub-spoke with network firewall | `blueprints/networking/hub-spoke-with-hub-vcn-net-firewall/` | Implementing |
| Networking | Hub-spoke with network appliance | `blueprints/networking/hub-spoke-with-hub-vcn-net-appliance/` | Implementing |
| Networking | Hub-spoke with bastion jump host | `blueprints/networking/hub-spoke-with-hub-vcn-bastion-jump-host/` | Implementing |
| Networking | Hub-spoke with transit routing NVA HA | `blueprints/networking/hub-spoke-with-transit-routing-nva-ha/` | Implementing |
| Networking | Hub-spoke with private DNS split horizon | `blueprints/networking/hub-spoke-with-private-dns-split-horizon/` | Implementing |
| Networking | Hub-spoke with ZPR micro-segmentation | `blueprints/networking/hub-spoke-with-zpr-micro-segmentation/` | Implementing |
| Networking | Hub-spoke with dual-region DR | `blueprints/networking/hub-spoke-with-dual-region-dr/` | Implementing |
| Networking | Multi-tenancy shared services | `blueprints/networking/multi-tenancy-shared-services/` | Implementing |
| Networking | Hub-spoke with multicloud interconnect | `blueprints/networking/hub-spoke-with-multicloud-interconnect/` | Implementing |
| Networking | Regional prod/nonprod hub separation | `blueprints/networking/regional-prod-nonprod-hubs/` | Implementing |
| Compliance | SCCA-style cloud-native landing zone | `blueprints/compliance/scca-cloud-native/` | Scaffold |
| Compliance | Zero Trust landing zone | `blueprints/compliance/zero-trust/` | Scaffold |
| Disaster recovery | Full Stack Disaster Recovery | `blueprints/disaster-recovery/fsdr/` | Scaffold |
| Data platform | Private data platform landing zone | `blueprints/data-platform/private-data-platform/` | Scaffold |
| Industry | Telco cloud-native landing zone | `blueprints/industry/telco-cloud-native/` | Scaffold |
| Extensions | OKE extension | `blueprints/extensions/oke/` | Scaffold |
| Extensions | Exadata extension | `blueprints/extensions/exadata/` | Scaffold |
| Extensions | API Gateway extension | `blueprints/extensions/apigw/` | Scaffold |
| Extensions | Streaming extension | `blueprints/extensions/streaming/` | Scaffold |
| Extensions | WAF extension | `blueprints/extensions/waf/` | Scaffold |

## Selection Notes

- Use `core` first for the shared compartment, tagging, and IAM foundation.
- Use operating entity patterns when the main question is ownership and
  delegated administration.
- Use networking patterns when the main question is traffic path, inspection,
  connectivity, or DNS.
- Use compliance patterns when control enforcement, auditability, or regulator
  mapping drives the design.
- Use data platform and industry patterns when the workload shape needs its own
  landing zone conventions.

## Research Inputs

The catalog should continue to evolve from:

- OCI core landing zone reference implementations.
- OCI operating entity landing zone implementations.
- OCI reference architectures for hub-spoke, DRG, network firewall, FastConnect,
  VPN, private DNS, OKE, Exadata, Zero Trust, and SCCA.
- Customer-specific requirements seen during real OCI landing zone work.
