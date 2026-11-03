# Networking source review — 2026-11-03

## Scope and decision

Reviewed all **27 networking blueprints**, their separately executed Google root (**28 blueprint Terraform roots** in total), and **10 local networking modules**. Schema validation therefore covers **38 roots**. Source review includes root/provider/input/output contracts, same-repository Git dependencies at their exact pinned revisions, three Azure Bicep templates, the AWS CloudFormation companion, local Ansible entry points and all 27 published architecture inventories.

Prefer native Interconnect in documented supported connection locations, or an explicitly reviewed private partner circuit, for the normal cross-cloud data path. VPN is an independently configured backup, or the alternative when dedicated connectivity is unavailable or unsuitable. Preserve cost gates, explicit circuit activation and separate cloud credentials. Private transport alone does not establish application encryption or automatic failover. The [commercial region matrix](multicloud/INTERCONNECT-REGIONS.md) is dated and must be rechecked before ordering.

This was a local source/schema/simulation review. No live cloud plan, apply, circuit order, activation, resource inventory API, application traffic, latency, throughput, HA/failover, DNS query or teardown operation was performed. Historical live-lifecycle dates in the source remain historical. No claim is made that every possible input combination has been tested or that every residual issue has been eliminated.

## Corrections

| Finding | Correction | Local evidence |
| --- | --- | --- |
| GCP hybrid Interconnect and HA VPN peers used `cidrhost(interface_cidr, 0)`, converting an assigned host into the subnet address. | Preserve the host portion before `/`. Example: `169.254.10.1/30` now yields peer `169.254.10.1`, rather than `169.254.10.0`. | Seven Google-root mocked plans, including exact Partner peer IP assertions and all four VPN peer addresses. |
| Azure vWAN companion created a direct hub-to-VNet connection alongside a classic VPN Gateway in the same VNet. Microsoft does not support this combination. | Default to the hub-connected VNet with classic VPN disabled. Classic VPN mode omits the direct hub connection and returns an empty hub-connection ID. | Compiled ARM resource condition and false default checked; Bicep compilation passed. |
| Azure vWAN subnet routes advertised remote prefixes with no selected transport. | Add remote-prefix routes only in Interconnect or VPN mode, independent of the VPN flag for dedicated connections. OCI VPN now defaults disabled. | Two mocked plans cover no path and dedicated path without VPN. |
| VPN pre-shared keys and the ExpressRoute authorization key were ordinary Bicep string parameters; VPN keys also had shared defaults. | Use secure parameters in all three templates; remove default VPN keys. | Compiled ARM parameter types verified as `securestring`; VPN defaults absent. Operator example strings remain placeholders, not operational secrets. |
| NLB flattening could silently overwrite targets when `a-b` + `c` and `a` + `b-c` both produced `a-b-c`. | Reject ambiguous combined backend keys while preserving existing unambiguous Terraform addresses. | Three mocked plans: disabled, distinct targets retained, colliding keys rejected. |
| DNS resolver forwarding rules referenced endpoint names as strings with no creation-order dependency on the module's endpoints. | Add an explicit resolver-to-endpoint dependency. | Two mocked plans and the actual Terraform plan dependency graph. |
| Six FortiGate/NLB Ansible entry points depended on an external roles search path and failed from the documented working directory. | Resolve the shared Terraform runner with the same explicit relative path used by other blueprints. | All six failed syntax checks passed on retry without an externally configured roles path. Apply/destroy confirmations in the shared runner remain enforced. |
| Validation scripts discovered only `main.tf`, missing the Google root named `infrastructure.tf`. | Full validation discovers roots through `versions.tf`, including local modules; changed validation recognizes `versions.tf`, `main.tf` and `infrastructure.tf`. | Shell syntax passed; changed-root discovery returned the nested Google root and DNS module for their changed inputs/tests. |
| Some operator summaries implied implemented NVA HA, inspection steering, cross-tenancy networking or regional DR. | Describe the source-defined foundations and separate the unimplemented routing, failover and tenancy dependencies. Align cross-cloud recommendations with Interconnect primary. | Source/README comparison, regenerated catalog, local link and repository contract checks. |

Azure reference: [Microsoft Virtual WAN VNet prerequisites](https://learn.microsoft.com/en-us/azure/virtual-wan/virtual-wan-site-to-site-portal). DNS reference: [OCI resolver forwarding endpoint requirement](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/dns_resolver).

## Important behavior and adoption limits

- **Azure vWAN classic VPN is an alternative topology.** Switching `deployVpnGateway` can remove the existing hub-to-VNet connection. Review the deployment diff and state ownership. Concurrent Interconnect/VPN backup through Virtual WAN requires a separately engineered native hub VPN gateway/site/link design; this blueprint does not implement it. Its ExpressRoute gateway and actual circuits remain external prerequisites.
- **DNS module revisions stay explicit.** The working-tree DNS module includes the endpoint-order correction. Existing wrappers pinned to earlier revisions were not silently repinned; they do not expose endpoint creation. A direct module consumer must adopt a revision containing the correction. Managing resolver views/rules can replace configuration owned by other tools.
- **Inspection and NVA HA remain external.** Creating a firewall or two appliance VMs does not install inspection steering, vendor policy, health checks or failover automation. Existing FortiGate bootstrap/floating-IP ownership still requires its documented vendor configuration and acceptance tests.
- **Dual-region networks remain independent.** Their inherited CIDRs overlap, and the wrapper exposes no per-region overrides. No RPC, data replication, DNS cutover or failover controller is created. Use a separate disjoint address plan before connecting them.
- **Multi-tenancy is a design extension.** The shared-services wrapper creates one tenancy's network/DNS foundation, not cross-tenancy IAM or peering.
- **Legacy cross-cloud VPN-only defaults are not production recommendations.** Except for the corrected Azure vWAN conflicting topology, existing Terraform creation defaults and pinned dependency versions were preserved. Explicit supported Interconnect configuration and staged activation are still required. The native services' on-premises transit limitations remain documented in the region matrix.

## Validation results

Date: **2026-11-03**. Resolved providers: **oracle/oci 9.11.0**, **hashicorp/aws 6.70.0**, **hashicorp/google 7.46.2** where declared. Init used exact same-repository revisions resolved from the existing local Git repository; public provider packages were fetched normally. No dependency source or module revision was rewritten for validation.

- Formatting and `terraform validate` passed for all **38 roots**.
- **54 mocked plan cases** passed across 14 committed suites. Roots without a suite received schema validation, not a default or live plan.
- **105 Ansible syntax checks**, **38 TFLint checks** (including the nested Google root) and **3 Bicep compilations** passed. Compiled ARM checks also verified secure parameter typing and mutually exclusive vWAN/classic-VPN attachment behavior.
- The AWS CloudFormation template parsed locally with intrinsic tags retained; this is not AWS service-side template validation.
- All **27 source-to-diagram inventories** and page-local native XML IDs/connector references passed across **109 draw.io files / 187 native pages**. The Azure vWAN overview and affected companion resource pages were regenerated and visually inspected. Other existing overview images were not all individually re-rendered or visually re-reviewed in this source audit.
- Shell syntax, resource-inventory parser regressions, local Markdown links, generated catalog and repository documentation/naming contracts passed.

Initial environment-only failures: the last module's provider installation ran out of disk space due to duplicate disposable packages. Reused identical provider packages through a local cache, preserved state/plans, and successfully repeated ZPR init, validation and its mock suite. Initial unconfigured Ansible role-path failures are corrected as described above. Successful checks were not inferred from those initial failures.

## Root-by-root matrix

A passed schema check is not evidence of deployment, permissions, packet routing or workload behavior. Mock counts refer only to local simulated plans.

| Root | Formatting / schema | Mock cases |
| --- | --- | --- |
| [blueprints/networking/aws-oci-hybrid-network-backbone](../blueprints/networking/aws-oci-hybrid-network-backbone/) | Passed | 5 |
| [blueprints/networking/aws-oci-managed-interconnect](../blueprints/networking/aws-oci-managed-interconnect/) | Passed | 9 |
| [blueprints/networking/azure-oci-dual-connectivity](../blueprints/networking/azure-oci-dual-connectivity/) | Passed | 3 |
| [blueprints/networking/azure-vwan-oci-drg-transit](../blueprints/networking/azure-vwan-oci-drg-transit/) | Passed | 2 |
| [blueprints/networking/externally-managed-vcns](../blueprints/networking/externally-managed-vcns/) | Passed | No committed mock suite |
| [blueprints/networking/gcp-oci-hybrid-network-backbone](../blueprints/networking/gcp-oci-hybrid-network-backbone/) | Passed | 3 |
| [blueprints/networking/gcp-oci-hybrid-network-backbone/gcp](../blueprints/networking/gcp-oci-hybrid-network-backbone/gcp/) | Passed | 7 |
| [blueprints/networking/gcp-oci-partner-interconnect](../blueprints/networking/gcp-oci-partner-interconnect/) | Passed | 11 |
| [blueprints/networking/hub-spoke-with-azure-vwan-expressroute](../blueprints/networking/hub-spoke-with-azure-vwan-expressroute/) | Passed | No committed mock suite |
| [blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns](../blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns/) | Passed | No committed mock suite |
| [blueprints/networking/hub-spoke-with-dual-region-dr](../blueprints/networking/hub-spoke-with-dual-region-dr/) | Passed | No committed mock suite |
| [blueprints/networking/hub-spoke-with-fortigate-ha](../blueprints/networking/hub-spoke-with-fortigate-ha/) | Passed | No committed mock suite |
| [blueprints/networking/hub-spoke-with-hub-vcn-bastion-jump-host](../blueprints/networking/hub-spoke-with-hub-vcn-bastion-jump-host/) | Passed | No committed mock suite |
| [blueprints/networking/hub-spoke-with-hub-vcn-fastconnect-vc](../blueprints/networking/hub-spoke-with-hub-vcn-fastconnect-vc/) | Passed | No committed mock suite |
| [blueprints/networking/hub-spoke-with-hub-vcn-ipsec-vpn](../blueprints/networking/hub-spoke-with-hub-vcn-ipsec-vpn/) | Passed | No committed mock suite |
| [blueprints/networking/hub-spoke-with-hub-vcn-net-appliance](../blueprints/networking/hub-spoke-with-hub-vcn-net-appliance/) | Passed | No committed mock suite |
| [blueprints/networking/hub-spoke-with-hub-vcn-net-firewall](../blueprints/networking/hub-spoke-with-hub-vcn-net-firewall/) | Passed | No committed mock suite |
| [blueprints/networking/hub-spoke-with-multicloud-interconnect](../blueprints/networking/hub-spoke-with-multicloud-interconnect/) | Passed | No committed mock suite |
| [blueprints/networking/hub-spoke-with-private-dns-split-horizon](../blueprints/networking/hub-spoke-with-private-dns-split-horizon/) | Passed | No committed mock suite |
| [blueprints/networking/hub-spoke-with-transit-routing-nva-ha](../blueprints/networking/hub-spoke-with-transit-routing-nva-ha/) | Passed | No committed mock suite |
| [blueprints/networking/hub-spoke-with-zpr-micro-segmentation](../blueprints/networking/hub-spoke-with-zpr-micro-segmentation/) | Passed | No committed mock suite |
| [blueprints/networking/multi-tenancy-shared-services](../blueprints/networking/multi-tenancy-shared-services/) | Passed | No committed mock suite |
| [blueprints/networking/network-load-balancer](../blueprints/networking/network-load-balancer/) | Passed | 3 |
| [blueprints/networking/regional-prod-nonprod-hubs](../blueprints/networking/regional-prod-nonprod-hubs/) | Passed | 1 |
| [blueprints/networking/standalone-private-endpoint-only](../blueprints/networking/standalone-private-endpoint-only/) | Passed | 1 |
| [blueprints/networking/standalone-three-tier-vcn-custom](../blueprints/networking/standalone-three-tier-vcn-custom/) | Passed | No committed mock suite |
| [blueprints/networking/standalone-three-tier-vcn-defaults](../blueprints/networking/standalone-three-tier-vcn-defaults/) | Passed | No committed mock suite |
| [blueprints/networking/standalone-three-tier-vcn-zpr](../blueprints/networking/standalone-three-tier-vcn-zpr/) | Passed | No committed mock suite |
| [modules/networking/dns](../modules/networking/dns/) | Passed | 2 |
| [modules/networking/drg](../modules/networking/drg/) | Passed | No committed mock suite |
| [modules/networking/fastconnect](../modules/networking/fastconnect/) | Passed | No committed mock suite |
| [modules/networking/gcp-private-network](../modules/networking/gcp-private-network/) | Passed | 4 |
| [modules/networking/hub-vcn](../modules/networking/hub-vcn/) | Passed | No committed mock suite |
| [modules/networking/ipsec-vpn](../modules/networking/ipsec-vpn/) | Passed | No committed mock suite |
| [modules/networking/net-appliance](../modules/networking/net-appliance/) | Passed | No committed mock suite |
| [modules/networking/net-firewall](../modules/networking/net-firewall/) | Passed | 2 |
| [modules/networking/spoke-vcn](../modules/networking/spoke-vcn/) | Passed | No committed mock suite |
| [modules/networking/zpr](../modules/networking/zpr/) | Passed | 1 |

## Reproduction

For each root above, run `terraform init -backend=false`, `terraform fmt -check`, `terraform validate` and, where a committed `tests/` directory exists, `terraform test`. Inspect those tests before execution: the evidence above is for mocked plan cases only. Use the repository Ansible config or explicit runner paths for `ansible-playbook --syntax-check`. Compile Azure templates locally with `bicep build`; do not substitute `what-if`, apply or lifecycle scripts for local source checks.

Run `scripts/check-repo-contracts.sh` and `scripts/check-markdown-links.sh`, regenerate `BLUEPRINTS.md` with `scripts/generate-blueprints-index.sh`, and use `scripts/diagrams/multicloud-resource-coverage.py --check --blueprint networking/<name>` for architecture/source consistency. Diagram generation requires the installed OCI architecture-diagrams skill, official toolkit and draw.io Desktop. Generic `validate-all.sh` covers the whole repository, not just this networking review.

## Diagram clarification follow-up — 2026-11-03

Redrew the Azure vWAN overview so the preferred FastConnect/ExpressRoute path has a prominent independent upper connector and native ExpressRoute icon. Classic VPN uses a separate lower connector between separate VPN gateway/CPE endpoints, explicitly disabled by default and labelled as an alternative rather than concurrent implemented backup. Source generators, editable overview and PNG were synchronized; layout, visual review, resource inventory and native connector reference checks passed. This is a presentation correction; the preceding Terraform/Bicep test evidence and external prerequisites are unchanged.
