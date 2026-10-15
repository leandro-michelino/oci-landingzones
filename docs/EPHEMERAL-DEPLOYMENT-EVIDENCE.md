# Ephemeral Deployment Evidence

This note records the low-risk real deployment checks performed against the OCI
blueprints during repository validation. Raw Terraform logs and outputs are kept in
the local ignored `.leo-local/deployment-evidence/` tree because they can contain
tenant-specific OCIDs and operator metadata.

## Historical Scope (May 2026)

The deployment checks use short-lived Terraform runs with unique `TestRun` tags.
Each real apply is followed by destroy or direct OCI cleanup verification.

Skipped by request:

- `blueprints/networking`
- AWS, Azure, and multicloud blueprints
- `blueprints/data-platform`
- `blueprints/ai`
- `blueprints/cis`
- `blueprints/disaster-recovery`
- `blueprints/compliance`
- `blueprints/operations`

Cost-sensitive blueprints such as Exadata are plan-only unless explicitly approved
for real deployment.

## Completed Real Runs

| Blueprint | Region | Mode | Outcome |
| --- | --- | --- | --- |
| `blueprints/devops/oci-devops-pipeline` | Sao Paulo | Apply/destroy | `ephem-20260528070009`: created and destroyed DevOps project, repository, build pipeline, deploy pipeline, and topic. |
| `blueprints/devops/oci-devops-pipeline` | Vinhedo | Apply/destroy | `ephem-20260528074413`: created and destroyed DevOps project, repository, build pipeline, deploy pipeline, and topic. |
| `blueprints/extensions/streaming` | Sao Paulo | Apply/destroy | `ephem-20260528070911`: created and destroyed stream pool and stream. |
| `blueprints/extensions/streaming` | Vinhedo | Apply/destroy | `ephem-20260528074234`: created and destroyed stream pool and stream. |
| `blueprints/extensions/event-driven-platform` | Sao Paulo | Apply/destroy | `ephem-20260528072342`: created and destroyed archive bucket, stream pool, stream, and topic after fixing pool-backed streams. |
| `blueprints/extensions/event-driven-platform` | Vinhedo | Apply/destroy | `ephem-20260528073049`: created and destroyed archive bucket, stream pool, stream, and topic after fixing pool-backed streams. |
| `blueprints/extensions/observability` | Sao Paulo | Apply/destroy | `ephem-20260528075835`: created and destroyed an APM free-tier domain. |
| `blueprints/extensions/observability` | Vinhedo | Apply/cleanup | `ephem-20260528080303`: created an APM free-tier domain; interrupted local state was cleaned up directly and verified as deleted. |
| `blueprints/identity/cis-basic` | Home region | Apply/destroy | `ephem-20260528082617`: created and destroyed one disposable IAM group with default CIS groups and policies disabled. |

## Plan-Only Runs

| Blueprint | Region | Mode | Outcome |
| --- | --- | --- | --- |
| `blueprints/extensions/exadata` | Sao Paulo | Plan only | `plan-20260528081154`: planned one Exadata Cloud Infrastructure resource with a concrete test shape; no apply was run. |
| `blueprints/extensions/exadata` | Vinhedo | Plan only | `plan-20260528081157`: planned one Exadata Cloud Infrastructure resource with a concrete test shape; no apply was run. |
| `blueprints/extensions/exadata` | Sao Paulo | Safety plan only | `plan-20260528081238`: verified the default disabled mode plans no Exadata infrastructure resource. |
| `blueprints/extensions/exadata` | Vinhedo | Safety plan only | `plan-20260528081258`: verified the default disabled mode plans no Exadata infrastructure resource. |
| `blueprints/identity/cis-basic` | Sao Paulo | Apply blocked | `ephem-20260528081309`: planned one disposable IAM group; OCI blocked the create because IAM writes must run in the tenancy home region. No resource was created. |
| `blueprints/identity/cis-basic` | Vinhedo | Plan only | `plan-20260528081352`: planned one disposable IAM group after the Sao Paulo home-region blocker. No apply was run. |
| `blueprints/operating-entity/workload-vending` | Sao Paulo | Plan only | `plan-20260528081627`: planned one workload root, one child compartment, three groups, and scoped policies. No apply was run. |
| `blueprints/operating-entity/workload-vending` | Vinhedo | Plan only | `plan-20260528081630`: planned one workload root, one child compartment, three groups, and scoped policies. No apply was run. |
| `blueprints/core` | Sao Paulo | Plan only | `plan-20260528081801`: planned the reduced core compartment baseline with tagging, logging, and default IAM disabled. No apply was run. |
| `blueprints/core` | Vinhedo | Plan only | `plan-20260528081805`: planned the reduced core compartment baseline with tagging, logging, and default IAM disabled. No apply was run. |

## Evidence README Standard

Each new local evidence folder should include a `README.md` with:

- Blueprint path.
- Region and run ID.
- Deployment mode.
- Resource mode.
- Result.
- Evidence files.
- Cleanup status.

## Networking First Ten Review (2026-10-13)

The first ten Networking entry points were processed in catalog order with
profile `DEFAULT`, region `sa-saopaulo-1`, and the compartment explicitly
confirmed by the operator. The authoritative compartment OCID is stored in the
private execution fixtures and workspace operating instructions, not here.

Eight OCI network foundations were created and verified against the OCI API.
Each subsequent Terraform plan returned no changes before teardown. One
blueprint performed a local output-contract test without creating cloud
resources. The dual-region blueprint was not deployed because only Sao Paulo
was authorized for the round. These are reduced infrastructure lifecycle tests,
not full cross-cloud, application connectivity, HA, SSH, or DR acceptance tests.

| # | Blueprint | Declared OCI Resources Created | Result And Boundaries | Cleanup |
| --- | --- | --- | --- | --- |
| 1 | `aws-oci-hybrid-network-backbone` | 7 | OCI backbone only; VPN, Direct Connect/FastConnect, AWS resources, and notifications disabled. | Verified: empty managed state, API deletion checks, and no tagged VCN/DRG leftovers |
| 2 | `azure-oci-dual-connectivity` | 7 | OCI primary network only; Azure resources, IPSec fallback, DNS contract, and notifications disabled. | Verified: empty managed state, API deletion checks, and no tagged VCN/DRG leftovers |
| 3 | `azure-vwan-oci-drg-transit` | 7 | OCI transit foundation only; Azure vWAN/vHub, IPSec fallback, DNS contract, and notifications disabled. | Verified: empty managed state, API deletion checks, and no tagged VCN/DRG leftovers |
| 4 | `externally-managed-vcns` | 0 | Local output-contract smoke test with empty external-reference maps; no existing network adopted or created. | Verified: empty managed state, API deletion checks, and no tagged VCN/DRG leftovers |
| 5 | `hub-spoke-with-azure-vwan-expressroute` | 20 | OCI hub/spoke foundation only; Azure, ExpressRoute, FastConnect, and IPSec paths disabled. | Verified: empty managed state, API deletion checks, and no tagged VCN/DRG leftovers |
| 6 | `hub-spoke-with-drg-and-three-tier-vcns` | 20 | Declared hub/spoke/DRG foundation; no workload packet paths or HA probes tested. | Verified: empty managed state, API deletion checks, and no tagged VCN/DRG leftovers |
| 7 | `hub-spoke-with-dual-region-dr` | 0 | Not deployed: genuine dual-region DR requires a second region outside the Sao Paulo-only scope. | No creation attempted |
| 8 | `hub-spoke-with-fortigate-ha` | 21 | OCI network foundation only; FortiGate Compute, licensing, floating IPs, and IAM failover resources disabled. | Verified: empty managed state, API deletion checks, and no tagged VCN/DRG leftovers |
| 9 | `hub-spoke-with-hub-vcn-bastion-jump-host` | 20 | OCI network foundation only; managed Bastion disabled because approved client CIDRs were not supplied. | Verified: empty managed state, API deletion checks, and no tagged VCN/DRG leftovers |
| 10 | `hub-spoke-with-hub-vcn-fastconnect-vc` | 20 | OCI network foundation only; paid FastConnect virtual circuit disabled. | Verified: empty managed state, API deletion checks, and no tagged VCN/DRG leftovers |

### Errors Corrected

- The AWS/OCI backbone and Azure/OCI dual-connectivity attachments used
  computed resource IDs in `count`. Their attachment toggles now determine the
  count, allowing a new VCN and DRG to plan together without staged applies.
- The first real run showed drift that would remove OCI provenance tags. The
  first ten OCI provider files now ignore only `Oracle-Tags.CreatedBy` and
  `Oracle-Tags.CreatedOn`; other configured tags remain managed. This follows
  [Oracle's provider troubleshooting guidance](https://docs.oracle.com/en-us/iaas/Content/dev/terraform/troubleshooting.htm).
- A transient connection reset interrupted the third item's API verification.
  All of its resources were destroyed and independently verified as removed.
  Read retries were added to the private harness; the repeated test passed.

The first drifted run and the interrupted verification attempt were both
completely cleaned before their repeats. Their logs and deletion checks remain
with the private evidence. No paid firewall, Compute instance, dedicated circuit,
external-cloud resource, or additional-region resource was activated. This is
not an account-wide billing audit.

### Dependency And Release Boundary

The live fixtures use the exact cached pinned dependency code, with the
corrected shared provider configuration staged into separate disposable
dependency copies. The original pinned archives remain unchanged. This proves
the working-tree provider fix, not a repair of the already-published `v0.2.0`
release. Composed blueprints need a newly published immutable dependency version
and a reviewed reference update before consuming that fix from their remote
source. No Git release, push, or source-reference publication was performed.

### Validation And Evidence

- Four mocked Terraform regression cases passed. The original AWS attachment
  implementation fails the new planning test with `Invalid count argument`,
  proving that the regression test detects the real defect.
- TFLint passed for all ten entry points. Terraform formatting and repository
  documentation contracts were checked after the edits.
- Private logs, planned changes, live resource GET results, drift plans,
  destruction logs, per-OCID deletion results, and final inventory are in
  `.leo-local/architecture-review-20261013/live-first10/`.

The final regional inventory audit is recorded in `final-api-audit.json` and
checks VCNs, DRGs, subnets, route tables, security lists, internet gateways, NAT
gateways, service gateways, and NSGs in the selected compartment.

The final audit returned **zero active resources in every checked network
category and zero leftovers from this test round**. All non-skipped test
workspaces also have zero remaining managed resources.

## Networking Items 11 Through 20 (2026-10-14)

The next ten catalog entries were processed with `DEFAULT`, `sa-saopaulo-1`,
and the same operator-confirmed compartment. Each apply was followed by
resource GET verification, a Terraform plan returning no changes, destroy,
empty managed-state verification, per-ID deletion checks, and scoped inventory
checks before the next item.

All ten lifecycle attempts passed in the modes below. Nine were reduced network
foundations; the NLB entry also created its private managed service and empty
backend set/listener. No paid Firewall, appliance Compute, dedicated circuit,
external tenancy, or ZPR root-scope resource was activated. DNS was disabled in
the real fixtures, so no DNS acceptance result is claimed.

| # | Blueprint | Declared OCI Resources | Tested Mode And Remaining Limits | Cleanup |
| --- | --- | --- | --- | --- |
| 11 | `hub-spoke-with-hub-vcn-ipsec-vpn` | 20 | OCI foundation only; IPSec disabled because no actual CPE/tunnel inputs were supplied. | Verified |
| 12 | `hub-spoke-with-hub-vcn-net-appliance` | 20 | OCI foundation only; appliance Compute and reserved route IPs disabled. | Verified |
| 13 | `hub-spoke-with-hub-vcn-net-firewall` | 20 | OCI foundation only; billed Firewall instance disabled; module pin corrected to published SHA 2369fef3285b79670b842a5072a6bebf38c4796d. | Verified |
| 14 | `hub-spoke-with-multicloud-interconnect` | 20 | OCI foundation only; FastConnect, IPSec, and remote cloud services disabled. | Verified |
| 15 | `hub-spoke-with-private-dns-split-horizon` | 20 | OCI foundation only; private DNS view/zones, resolver attachments, forwarding and resolution untested. | Verified |
| 16 | `hub-spoke-with-transit-routing-nva-ha` | 20 | OCI foundation only; NVA instances, route IPs, guest forwarding and failover disabled. | Verified |
| 17 | `hub-spoke-with-zpr-micro-segmentation` | 20 | OCI foundation only; ZPR onboarding/policies disabled to respect compartment-only scope; root/home-region code corrected and tested locally. | Verified |
| 18 | `multi-tenancy-shared-services` | 20 | Local OCI foundation only; private DNS disabled; no cross-tenancy peering or IAM delegation created. | Verified |
| 19 | `network-load-balancer` | 6 | Private NLB, empty TCP backend set/listener, and isolated private subnet created; no backend hosts, traffic, or application health tested. | Verified |
| 20 | `regional-prod-nonprod-hubs` | 40 | Separate prod/nonprod hub/spoke foundations in Sao Paulo; verified distinct VCN/DRG groups and their attachment membership; no packet-isolation test. | Verified |

### Corrections And Regression Checks

- Updated the Firewall module reference to the published immutable revision
  containing the disabled-mode fix. The older `v0.2.0` and `v0.2.1` module
  implementations call `coalesce()` with only null values when no policy exists.
- Preserved the two OCI provenance tags in the ten OCI provider files.
- Corrected the working-tree ZPR module to use tenancy root for configuration
  and policies. Added a blueprint guard rejecting onboarding outside an
  explicitly supplied home region. The corrected root-scope module test passes;
  the original implementation fails it. A negative real plan rejected ZPR
  onboarding in Sao Paulo without executing apply. ZPR stays disabled here.
- Added two mocked Firewall disabled-mode regression cases; both pass.
- Corrected diagrams and notes to show one default workload spoke, separately
  supplied workloads/security attributes, and the missing cross-tenancy
  prerequisites. Multiple resource objects do not establish HA or application
  connectivity by themselves.
- TFLint passed for all ten entry points and the two reviewed modules.

The home-region and root-scope rules follow [Oracle ZPR onboarding](https://docs.oracle.com/en-us/iaas/Content/zero-trust-packet-routing/enable-zpr.htm)
and [ZPR policy creation](https://docs.oracle.com/en-us/iaas/Content/zero-trust-packet-routing/create-zpr-policy.htm).
The [Flexible Network Load Balancer](https://www.oracle.com/cloud/networking/flexible-network-load-balancer/)
is offered as a no-cost service; this round used no backend hosts or traffic
generation. No account-wide billing audit or financial cost estimate was run.

### Release And Evidence Boundaries

The original pinned archives remain intact. Real fixtures stage the corrected
shared provider configuration into disposable dependency copies. The ZPR fixture
uses the corrected working-tree module with its flags disabled. Those shared
provider/ZPR corrections still require a new published immutable version and
reviewed reference updates for remote consumers. The Firewall fix already
exists in the published SHA now selected by its blueprint. No push or release
was performed during this round.

Private evidence is in `.leo-local/architecture-review-20261014/live-next10/`,
including each plan, created resource set, live GET results, drift check, destroy
log, deletion check, and the final `final-api-audit.json`. That audit additionally
checks the Network Load Balancer inventory. The prod/nonprod attachment grouping
check is recorded in `20-regional-prod-nonprod-hubs/separation-verification.json`.

The final API audit returned **zero active resources in every checked network
category, including Network Load Balancers, and zero test leftovers**. All ten
workspaces also have zero remaining managed resources.

## Networking Items 21 Through 24, October 14, 2026

The remaining four Networking entries were reviewed and tested using profile
`DEFAULT`, `sa-saopaulo-1`, and the explicitly selected Leandro.Michelino
compartment. After an automatic approval rejection concerning possible NAT
charges, the user explicitly authorized ephemeral NAT tests even if chargeable.
No other paid service, workload, second region, or tenancy-root ZPR action was
included. This authorization does not establish a zero account bill.

| Item | Blueprint | Declared Cloud Resources | Live Scope | Cleanup |
| --- | --- | --- | --- | --- |
| 21 | `standalone-private-endpoint-only` | 7 | Private network and Service Gateway; no NAT or Internet Gateway | API and state verified |
| 22 | `standalone-three-tier-vcn-custom` | 11 | Three-tier network with NAT | API and state verified |
| 23 | `standalone-three-tier-vcn-defaults` | 11 | Three-tier network with NAT | API and state verified |
| 24 | `standalone-three-tier-vcn-zpr` | 11 | Three-tier network with NAT; ZPR disabled | API and state verified |

All four completed apply, per-resource OCI GET checks, a no-change Terraform
plan, destroy, empty managed state, and per-ID deletion verification. The final
API audit found zero active resources in every checked network category and
zero test leftovers. An earlier reduced run also created and removed Custom,
Defaults, and ZPR foundations without NAT before the explicit authorization.
The first Private Endpoint plan failure occurred before apply and was corrected.

### Corrections And Validation Limits

- Custom now attaches its public HTTPS security list only to the web subnet.
  Application/database baseline ingress is empty. Defaults has the previously
  corrected HTTP/HTTPS web-only separation, now verified against live objects.
- Standalone ZPR exposes explicit route/security-list inputs, separates public
  web ingress from private tiers, and rejects onboarding outside an explicitly
  supplied tenancy home region. The negative Sao Paulo plan was rejected.
- Private Endpoint now adds baseline HTTPS egress to the regional Oracle Services
  Network label, matching its Service Gateway route. The new switch can disable
  this addition for customer-supplied service-specific rules. Typed Terraform
  rule concatenation was corrected after a plan-time error and retested.
- All four providers ignore only the two OCI-managed provenance tags. Customer
  defined tags remain managed. Architecture notes distinguish managed security
  lists from separately supplied NSGs and workloads.
- Terraform init/validate, repository-configured TFLint (4/4), formatting,
  repository contracts, and Markdown links passed. Live security checks verified
  subnet security-list membership, empty private-tier ingress, NAT presence,
  HTTPS OSN egress, and absence of tenancy-root ZPR resources.

The regional Service Gateway route and security-rule requirements follow [Oracle VCN FAQ](https://www.oracle.com/cloud/networking/virtual-cloud-network/faq/).

No workload hosts, application traffic, service-specific private endpoints,
security attributes, or active ZPR enforcement were tested. Explicit application
flows/NSGs remain required for workloads. The staged corrected ZPR module still
requires publication and refreshed immutable pins for remote consumers; no push
or release was performed.

Private evidence is in `.leo-local/architecture-review-20261014/live-last4-nat/`;
the earlier reduced tests remain in `live-last4/`. The final audit is
`final-api-audit.json`; resource security assertions are in
`security-verification.json`. All 24 Networking catalog entries have now been
reviewed, with the skipped/reduced scopes in previous sections still applicable.
This does not mean all 24 full end-to-end architectures were deployed.

## Module Validation Metadata

On October 14, 2026, all **24 shared module definitions** passed isolated
`terraform init -backend=false` and `terraform validate` using OCI provider
**9.9.0**. No module-level live apply was performed by this validation. The
private per-module logs and result ledger are in
`.leo-local/architecture-review-20261014/module-validation/`.

English comments now record the last successful schema validation on each shared
module definition and all 80 blueprint entry points (81 module calls plus
headers for entry points without module calls). Blueprint schema dates preserve
the October 13 baseline unless a later validation is recorded. Where a real
lifecycle passed, its date and reduced scope are recorded separately. These
comments identify historical evidence; they do not guarantee runtime correctness
or automatically certify a later dependency/provider update.

The workspace instructions require refreshing success dates only after relevant
checks pass, preserving the previous successful date after a failure, and
recording a failed check separately with its date and cause. All metadata and
future validation comments must remain in English.

## Repository Publication Follow-Up, October 14, 2026

The previously pending shared Networking/ZPR corrections are now published in commit `d7938f4`, integrated into main through `a87a87f`, and selected by immutable references in affected blueprints. The [repository synchronization review](REPOSITORY-VALIDATION-20261014.md) records the additional complete schema/mocked audit and AI corrections. This follow-up created no new cloud resources and does not broaden the earlier live-test coverage.

## CIS, Compliance, Core, And Database Follow-Up

The [October 14 item review](CIS-COMPLIANCE-DATA-REVIEW-20261014.md) records ten additional blueprint reviews, Budget/Core scope corrections, 35 mocked regression cases, and two private database-network foundations that were created, verified, and removed. The final scoped network inventory, including DHCP options, is empty. Database services and tenancy-wide administration were not deployed.

## Data Platform, DevOps, And DR Items 21-30, October 15, 2026

The [item-by-item review](DATA-DEVOPS-DR-REVIEW-20261015.md) records eight
reduced OCI network-only lifecycle tests: 40 resources in the passing runs,
each destroyed and verified by managed state and OCI API. A first item 26
attempt created seven additional network resources, found provenance-tag
drift, and was completely cleaned before a corrected retest. Items 27 and 30
were validated locally only. The final scoped inventory found no active
network resources or test leftovers in the selected compartment. No database,
DevOps, FSDR, AWS, or Azure service was deployed by these tests.
