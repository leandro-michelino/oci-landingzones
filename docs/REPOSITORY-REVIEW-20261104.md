# Repository-wide transport and source review — 2026-11-04

## Scope

Reviewed all **123 Terraform roots** under blueprints and modules, **93 published blueprint architecture overviews**, their source/resource inventories, the conceptual three-tier drawing and the portfolio banner. This extends the [networking review](NETWORKING-REVIEW-20261103.md) to the whole repository. The review combines local provider-schema validation, committed mocked suites, static source/diagram checks, template compilation, Ansible syntax and explicit wrapper simulation. It is not a comprehensive security audit or evidence of deployed behavior.

Source and current default/example behavior were compared for the transport corrections below. Existing dependencies were resolved at their exact same-repository Git revisions; no dependency revision was silently upgraded. Root suites with mocked `apply` commands remain simulations, not live cloud deployments. State, saved plans, private tfvars and activation keys are excluded from this commit.

## Applied transport standard

- Prefer native Interconnect in supported connection locations, or a reviewed private partner circuit, for private cross-cloud workload traffic. Use VPN as a separately configured backup or alternative when dedicated connectivity cannot be used.
- FastConnect/Interconnect and VPN use separate labelled connectors and distinct transport segments. Use exact provider-native symbols and OCI toolkit transport badges where available. Public CDN/API HTTPS and replication intent arrows retain their application semantics.
- Circuit IDs, default route weights, private subnet declarations and runbook targets do not activate circuits or demonstrate route symmetry, encryption, availability or automatic failover. External gateways, BGP, return routes and service limitations stay explicit.
- AKS/EKS partner-only contracts explicitly forbid IPSec backup; this review does not invent a VPN leg for them. Azure vWAN classic VNet VPN remains an alternative topology, not an implemented concurrent hub VPN backup. See the networking record for the adoption limits.

The standard is recorded in [AGENTS.md](../AGENTS.md). The [commercial region matrix](multicloud/INTERCONNECT-REGIONS.md) is a **2026-11-03 snapshot**, not a live account/region eligibility check. Revalidate offering, locations, capacity and entitlement before ordering.

## Corrections

| Area | Correction | Evidence |
| --- | --- | --- |
| OCI/AWS MySQL HeatWave DR | Added optional existing dedicated-circuit handoff inputs. DRG, VCN attachment, remote-prefix route and scoped MySQL ingress now work independently of the VPN flag. VPN remains optional and separately gated. | Eight mocked cases, including dedicated transport with VPN disabled and rejection of missing circuit identifiers. |
| Transport drawings | Redrew MySQL DR with prominent FastConnect/AWS private-connectivity and independent VPN connectors. Marked the existing external circuit paths in AWS DR, Azure DR, OKE/AKS and OKE/EKS as preferred private Interconnect. | Five paired draw.io/PNG overview exports visually inspected; source layout and native references checked. No missing gateway/circuit is claimed as created. |
| Ansible portability | Corrected 94 entry points that used bare role names without the repository's role-search configuration, including central playbooks. Explicit relative role paths now resolve from the documented working directory. | 358 syntax checks passed without requiring an external role path. Shared apply/destroy confirmations remain enforced. |
| Diagram guard | Reject combined cross-cloud Interconnect/VPN transport labels while allowing internal route-policy annotations to mention both choices. | Three policy regressions plus six existing inventory parser tests passed. This check does not infer actual live packet routes or prove all possible polyline geometries. |
| Presentation registry | Registered the portfolio banner separately from workload topologies. Refactored its builder so validation can compare its generated XML without rendering on import; full regeneration now includes its native/PNG/SVG artifacts. | Banner source/XML equality, SVG XML, native page IDs/references and PNG checks passed. No transport edges are fabricated for the banner. |
| Documentation | Added source-bounded transport guidance to 40 operator/architecture documents; clarified MySQL dedicated activation and the existing partner-only/public-service exceptions. Regenerated the blueprint catalog and reconciled connector/source review snapshots. | Local links, catalog and repository documentation/naming contracts checked. |

### MySQL dedicated transport adoption

`enable_interconnect_connectivity=true` requires existing `fastconnect_virtual_circuit_id` and `aws_private_connection_id`. This root creates or inspects neither circuit. In a staged handoff, create its DRG/VCN foundation, then externally attach the activated FastConnect circuit to **that same DRG**, associate the correct AWS gateway and configure symmetric return routes. Native managed AWS Interconnect and conventional partner Direct Connect have different availability/activation workflows; an arbitrary supplied ID does not establish either.

The default dedicated/VPN flags remain false. If both are enabled, `preferred_path=interconnect` records intent; it does not program BGP preference or automatic failover. This correction adds no data replication channel, seed transfer, DNS switch, recovery workflow or application workload. See [the operator guide](../blueprints/data-platform/oci-aws-mysql-heatwave-dr/README.md) and [overlay example](../blueprints/data-platform/oci-aws-mysql-heatwave-dr/interconnect.tfvars.example).

## Validation

Resolved providers used by the checks: OCI **9.11.0**, AWS **6.70.0**, Google **7.46.2**, Cloudflare **5.28.1**, where declared by a root. Existing provider constraints remain unchanged. The [machine-readable result matrix](REPOSITORY-REVIEW-20261104.json) records every root and its exact mock-case count.

| Check | Result |
| --- | --- |
| Terraform formatting and schema validation | **123 / 123 roots passed** |
| Committed Terraform mocked suites | **254 cases passed across 61 roots**; remaining roots received schema checks only |
| Ansible syntax | **358 passed** |
| TFLint | **123 passed** |
| Azure Bicep compilation | **8 passed**; no service-side deployment validation |
| AWS/Azure wrapper simulations | **12 passed** using the explicit simulation flags; no cloud CLI deployment operations |
| CloudFormation local parsing | **4 templates / 66 resource declarations**; not AWS service-side template acceptance |
| Python regressions | **9 passed** |
| Blueprint source/resource diagram maps | **93 passed** |
| Connector/geometry/source/native registry | **93 blueprint + 1 conceptual overview**, **735 connectors**, **349 native documents with PNG pairs**, plus the separately registered presentation asset within that document count |
| Repository docs, naming, catalog, local links and shell syntax | Passed |

All native pages received ID/connector/reference checks. Five changed overviews were rendered and visually inspected in this pass; unchanged editable overviews were compared with their authoring scripts and prior connector snapshots. Their PNGs received presence/signature checks, not individual re-rendering or visual re-review. The 12 snapshot deltas include seven networking entries already reviewed during this conversation and five updated transport drawings. There are no unpublished/unregistered blueprint overview files in this inventory.

Initial cache failures were environment failures, not passed checks: concurrent writes/first-time provider installation produced checksum and plugin-load errors. Packages were downloaded and signature-verified in an isolated cache; prior generated dependency locks were backed up locally, initialization was serialized and remaining failed checks rerun sequentially. All 123 roots then passed. Only disposable provider/module work directories were changed; deployment state/plans were preserved. No private logs or generated lock/backups are committed.

## Family coverage

| Source family | Terraform roots | Schema result |
| --- | --- | --- |
| `blueprints/ai` | 12 | Passed |
| `blueprints/cis` | 2 | Passed |
| `blueprints/compliance` | 4 | Passed |
| `blueprints/core` | 1 | Passed |
| `blueprints/data-platform` | 11 | Passed |
| `blueprints/devops` | 1 | Passed |
| `blueprints/disaster-recovery` | 5 | Passed |
| `blueprints/extensions` | 19 | Passed |
| `blueprints/identity` | 3 | Passed |
| `blueprints/industry` | 4 | Passed |
| `blueprints/networking` | 28 | Passed |
| `blueprints/operating-entity` | 3 | Passed |
| `blueprints/operations` | 1 | Passed |
| `blueprints/vmware` | 4 | Passed |
| `modules/governance` | 4 | Passed |
| `modules/iam` | 4 | Passed |
| `modules/networking` | 10 | Passed |
| `modules/operations` | 2 | Passed |
| `modules/security` | 5 | Passed |

## Limits and reproduction

No real cloud plan, apply, tenancy/project inventory call, circuit order/activation, BGP session, DNS query, data replication, application inference, latency/throughput, failover or live cleanup was performed. No live resource was created by this review. Mocked tests, template compilation, graph guards and source inventories cannot establish runtime availability, security/compliance or an RPO/RTO outcome.

Use `terraform init -backend=false`, `terraform fmt -check`, `terraform validate` and the committed mocked `terraform test` suites per root. Inspect tests and credentials before execution; these results do not authorize a live lifecycle. Use `scripts/check-repo-contracts.sh`, `scripts/check-markdown-links.sh`, `scripts/simulate-cloud-deployments.sh` (explicit simulation mode), `python3 -m unittest discover -s scripts/diagrams -p 'test_*.py'` and `scripts/diagrams/check-connections.py` for the corresponding local guards. A new connector snapshot must follow source and PNG review, rather than bypassing a mismatch. [regenerate-all.py](../scripts/diagrams/regenerate-all.py) rebuilds the registered diagram assets with the installed official toolkit and draw.io exporter.
