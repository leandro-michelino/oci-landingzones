# Architecture Diagram Sources

[oci-3tier-adb.drawio](oci-3tier-adb.drawio) and its [PNG preview](oci-3tier-adb.png) show an illustrative three-tier architecture with web/app VMs, a public load balancer and an Autonomous Database private endpoint. The diagram was regenerated with the official OCI toolkit and visually reviewed on October 28, 2026. Oracle services use the Service Gateway path; database sessions use the separate private endpoint path. This is a conceptual design, not deployment evidence for a Terraform blueprint. Routes, security, DNS, certificates and availability placement require separate configuration and validation.


## Networking Draw.io Diagrams

All 24 existing Networking blueprints have editable draw.io sources and PNG
previews beside their architecture documentation. The PNGs replace the previous
ASCII architecture blocks in all 24 architecture files. Planned patterns without
a deployable blueprint, such as public-edge-ingress, are outside this inventory.
The catalog now also lists the existing Azure vWAN ExpressRoute blueprint,
previously present only in the generated blueprint index.

Generated using the [oci-architecture-diagrams skill](https://github.com/leandro-michelino/oci-architecture-diagrams)
(source revision `d00360c5dc9942c49189416b9ad677b863db54a3`) and Oracle's official
OCI Architecture Diagram Toolkit v24.2. The toolkit is a local prerequisite and
is not redistributed here. Install the skill and place the official toolkit in
its `toolkit/` folder, or set `OCI_DIAGRAM_SKILL` and `OCI_TOOLKIT`.

| Catalog entry | Blueprint | PNG preview | Editable source |
| --- | --- | --- | --- |
| 1 | `standalone-three-tier-vcn-defaults` | [PNG](../../blueprints/networking/standalone-three-tier-vcn-defaults/architecture/architecture.png) | [draw.io](../../blueprints/networking/standalone-three-tier-vcn-defaults/architecture/architecture.drawio) |
| 2 | `standalone-three-tier-vcn-custom` | [PNG](../../blueprints/networking/standalone-three-tier-vcn-custom/architecture/architecture.png) | [draw.io](../../blueprints/networking/standalone-three-tier-vcn-custom/architecture/architecture.drawio) |
| 3 | `standalone-three-tier-vcn-zpr` | [PNG](../../blueprints/networking/standalone-three-tier-vcn-zpr/architecture/architecture.png) | [draw.io](../../blueprints/networking/standalone-three-tier-vcn-zpr/architecture/architecture.drawio) |
| 4 | `standalone-private-endpoint-only` | [PNG](../../blueprints/networking/standalone-private-endpoint-only/architecture/architecture.png) | [draw.io](../../blueprints/networking/standalone-private-endpoint-only/architecture/architecture.drawio) |
| 5 | `externally-managed-vcns` | [PNG](../../blueprints/networking/externally-managed-vcns/architecture/architecture.png) | [draw.io](../../blueprints/networking/externally-managed-vcns/architecture/architecture.drawio) |
| 6 | `hub-spoke-with-drg-and-three-tier-vcns` | [PNG](../../blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns/architecture/architecture.png) | [draw.io](../../blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns/architecture/architecture.drawio) |
| 7 | `hub-spoke-with-hub-vcn-ipsec-vpn` | [PNG](../../blueprints/networking/hub-spoke-with-hub-vcn-ipsec-vpn/architecture/architecture.png) | [draw.io](../../blueprints/networking/hub-spoke-with-hub-vcn-ipsec-vpn/architecture/architecture.drawio) |
| 8 | `hub-spoke-with-hub-vcn-fastconnect-vc` | [PNG](../../blueprints/networking/hub-spoke-with-hub-vcn-fastconnect-vc/architecture/architecture.png) | [draw.io](../../blueprints/networking/hub-spoke-with-hub-vcn-fastconnect-vc/architecture/architecture.drawio) |
| 9 | `hub-spoke-with-hub-vcn-net-firewall` | [PNG](../../blueprints/networking/hub-spoke-with-hub-vcn-net-firewall/architecture/architecture.png) | [draw.io](../../blueprints/networking/hub-spoke-with-hub-vcn-net-firewall/architecture/architecture.drawio) |
| 10 | `hub-spoke-with-hub-vcn-net-appliance` | [PNG](../../blueprints/networking/hub-spoke-with-hub-vcn-net-appliance/architecture/architecture.png) | [draw.io](../../blueprints/networking/hub-spoke-with-hub-vcn-net-appliance/architecture/architecture.drawio) |
| 11 | `hub-spoke-with-fortigate-ha` | [PNG](../../blueprints/networking/hub-spoke-with-fortigate-ha/architecture/architecture.png) | [draw.io](../../blueprints/networking/hub-spoke-with-fortigate-ha/architecture/architecture.drawio) |
| 12 | `hub-spoke-with-hub-vcn-bastion-jump-host` | [PNG](../../blueprints/networking/hub-spoke-with-hub-vcn-bastion-jump-host/architecture/architecture.png) | [draw.io](../../blueprints/networking/hub-spoke-with-hub-vcn-bastion-jump-host/architecture/architecture.drawio) |
| 13 | `hub-spoke-with-transit-routing-nva-ha` | [PNG](../../blueprints/networking/hub-spoke-with-transit-routing-nva-ha/architecture/architecture.png) | [draw.io](../../blueprints/networking/hub-spoke-with-transit-routing-nva-ha/architecture/architecture.drawio) |
| 14 | `hub-spoke-with-private-dns-split-horizon` | [PNG](../../blueprints/networking/hub-spoke-with-private-dns-split-horizon/architecture/architecture.png) | [draw.io](../../blueprints/networking/hub-spoke-with-private-dns-split-horizon/architecture/architecture.drawio) |
| 15 | `hub-spoke-with-zpr-micro-segmentation` | [PNG](../../blueprints/networking/hub-spoke-with-zpr-micro-segmentation/architecture/architecture.png) | [draw.io](../../blueprints/networking/hub-spoke-with-zpr-micro-segmentation/architecture/architecture.drawio) |
| 16 | `hub-spoke-with-dual-region-dr` | [PNG](../../blueprints/networking/hub-spoke-with-dual-region-dr/architecture/architecture.png) | [draw.io](../../blueprints/networking/hub-spoke-with-dual-region-dr/architecture/architecture.drawio) |
| 17 | `multi-tenancy-shared-services` | [PNG](../../blueprints/networking/multi-tenancy-shared-services/architecture/architecture.png) | [draw.io](../../blueprints/networking/multi-tenancy-shared-services/architecture/architecture.drawio) |
| 18 | `hub-spoke-with-multicloud-interconnect` | [PNG](../../blueprints/networking/hub-spoke-with-multicloud-interconnect/architecture/architecture.png) | [draw.io](../../blueprints/networking/hub-spoke-with-multicloud-interconnect/architecture/architecture.drawio) |
| 19 | `aws-oci-hybrid-network-backbone` | [PNG](../../blueprints/networking/aws-oci-hybrid-network-backbone/architecture/architecture.png) | [draw.io](../../blueprints/networking/aws-oci-hybrid-network-backbone/architecture/architecture.drawio) |
| 20 | `azure-oci-dual-connectivity` | [PNG](../../blueprints/networking/azure-oci-dual-connectivity/architecture/architecture.png) | [draw.io](../../blueprints/networking/azure-oci-dual-connectivity/architecture/architecture.drawio) |
| 21 | `azure-vwan-oci-drg-transit` | [PNG](../../blueprints/networking/azure-vwan-oci-drg-transit/architecture/architecture.png) | [draw.io](../../blueprints/networking/azure-vwan-oci-drg-transit/architecture/architecture.drawio) |
| 22 | `regional-prod-nonprod-hubs` | [PNG](../../blueprints/networking/regional-prod-nonprod-hubs/architecture/architecture.png) | [draw.io](../../blueprints/networking/regional-prod-nonprod-hubs/architecture/architecture.drawio) |
| 23 | `network-load-balancer` | [PNG](../../blueprints/networking/network-load-balancer/architecture/architecture.png) | [draw.io](../../blueprints/networking/network-load-balancer/architecture/architecture.drawio) |
| 24 | `hub-spoke-with-azure-vwan-expressroute` | [PNG](../../blueprints/networking/hub-spoke-with-azure-vwan-expressroute/architecture/architecture.png) | [draw.io](../../blueprints/networking/hub-spoke-with-azure-vwan-expressroute/architecture/architecture.drawio) |

From the repository root, regenerate a batch and export its PNGs with:

```bash
python3 scripts/diagrams/networking-batch-01.py --render
python3 scripts/diagrams/networking-batch-02.py --render
python3 scripts/diagrams/networking-batch-03.py --render
python3 scripts/diagrams/networking-batch-04.py --render
python3 scripts/diagrams/networking-batch-05.py --render
```

Each generator runs the skill's layout checks and stops on warnings before
exporting. The output uses source-default CIDRs, marks unspecified deployment
placement, and distinguishes optional disabled services from the network
foundation. It does not discover live OCI resources.

On October 28, 2026, all 24 sources passed the skill's layout checks; all 24
PNGs were exported through draw.io and visually reviewed. Repository contracts,
Markdown links and diff whitespace checks passed. This documentation-only work
performed no Terraform apply, provider revalidation, connectivity, failover or
cost test and does not change historical deployment validation dates.


## Core, CIS And Identity Diagrams

The next five available patterns in deployment-catalog order now have draw.io
sources and PNGs in place of ASCII architecture blocks. These diagrams separate
home-region IAM, tenancy-wide controls and regional services, mark optional
services and preserve the historical Terraform validation metadata.

| Batch order | Blueprint | PNG preview | Editable source |
| --- | --- | --- | --- |
| 1 | `core` | [PNG](../../blueprints/core/architecture/architecture.png) | [draw.io](../../blueprints/core/architecture/architecture.drawio) |
| 2 | `cis/level1` | [PNG](../../blueprints/cis/level1/architecture/architecture.png) | [draw.io](../../blueprints/cis/level1/architecture/architecture.drawio) |
| 3 | `cis/level2` | [PNG](../../blueprints/cis/level2/architecture/architecture.png) | [draw.io](../../blueprints/cis/level2/architecture/architecture.drawio) |
| 4 | `identity/cis-basic` | [PNG](../../blueprints/identity/cis-basic/architecture/architecture.png) | [draw.io](../../blueprints/identity/cis-basic/architecture/architecture.drawio) |
| 5 | `identity/new-identity-domain` | [PNG](../../blueprints/identity/new-identity-domain/architecture/architecture.png) | [draw.io](../../blueprints/identity/new-identity-domain/architecture/architecture.drawio) |

Regenerate using the same installed skill and toolkit prerequisites:

```bash
python3 scripts/diagrams/foundation-batch-01.py --render
```

On October 28, 2026, all five passed the skill layout checks, draw.io PNG export
and visual review; repository contracts and Markdown link checks passed.
Core creates default IAM and compartment resources; the two Identity wrappers
create nothing under their default inputs. CIS Level 1 and Level 2 currently
share service-enable defaults; their labels are not evidence of certification.

Coverage after the first foundation batch was 29 of 80. The latest coverage
is recorded below. Planned patterns without blueprint folders remain outside
this conversion inventory.


## Custom Identity, Operating Entity And SCCA Diagrams

The next five available catalog patterns now use editable draw.io sources and
PNG previews in place of ASCII. These views distinguish map-driven domain
creation, per-entity compartment/IAM delegation, and the SCCA pattern's actual
enabled/disabled security services. They are not security or compliance attestations.

| Batch order | Blueprint | PNG preview | Editable source |
| --- | --- | --- | --- |
| 6 | `identity/custom-identity-domain` | [PNG](../../blueprints/identity/custom-identity-domain/architecture/architecture.png) | [draw.io](../../blueprints/identity/custom-identity-domain/architecture/architecture.drawio) |
| 7 | `operating-entity` | [PNG](../../blueprints/operating-entity/architecture/architecture.png) | [draw.io](../../blueprints/operating-entity/architecture/architecture.drawio) |
| 8 | `operating-entity/multi-operating-entities` | [PNG](../../blueprints/operating-entity/multi-operating-entities/architecture/architecture.png) | [draw.io](../../blueprints/operating-entity/multi-operating-entities/architecture/architecture.drawio) |
| 9 | `operating-entity/workload-vending` | [PNG](../../blueprints/operating-entity/workload-vending/architecture/architecture.png) | [draw.io](../../blueprints/operating-entity/workload-vending/architecture/architecture.drawio) |
| 10 | `compliance/scca-cloud-native` | [PNG](../../blueprints/compliance/scca-cloud-native/architecture/architecture.png) | [draw.io](../../blueprints/compliance/scca-cloud-native/architecture/architecture.drawio) |

Regenerate with the same installed skill and official toolkit:

```bash
python3 scripts/diagrams/foundation-batch-02.py --render
```

On October 28, 2026, all five passed layout checks, PNG export and visual review;
repository contracts and Markdown links passed. No cloud resource was created
and no historical Terraform/provider validation date was changed.

Coverage after the preceding batch was 34 of 80. Latest coverage is recorded below.


## Compliance And Disaster Recovery Diagrams

The following five patterns now have draw.io sources and PNG previews replacing
ASCII. The diagrams distinguish service creation from compliance outcomes,
Data Safe registration from database provisioning, FSDR associations from workload
replication, and cross-cloud metadata contracts from implemented failover.

| Batch order | Blueprint | PNG preview | Editable source |
| --- | --- | --- | --- |
| 11 | `compliance/zero-trust` | [PNG](../../blueprints/compliance/zero-trust/architecture/architecture.png) | [draw.io](../../blueprints/compliance/zero-trust/architecture/architecture.drawio) |
| 12 | `compliance/healthcare-pci` | [PNG](../../blueprints/compliance/healthcare-pci/architecture/architecture.png) | [draw.io](../../blueprints/compliance/healthcare-pci/architecture/architecture.drawio) |
| 13 | `compliance/security-posture` | [PNG](../../blueprints/compliance/security-posture/architecture/architecture.png) | [draw.io](../../blueprints/compliance/security-posture/architecture/architecture.drawio) |
| 14 | `disaster-recovery/fsdr` | [PNG](../../blueprints/disaster-recovery/fsdr/architecture/architecture.png) | [draw.io](../../blueprints/disaster-recovery/fsdr/architecture/architecture.drawio) |
| 15 | `disaster-recovery/azure-oci-cross-cloud-dr` | [PNG](../../blueprints/disaster-recovery/azure-oci-cross-cloud-dr/architecture/architecture.png) | [draw.io](../../blueprints/disaster-recovery/azure-oci-cross-cloud-dr/architecture/architecture.drawio) |

Regenerate with the same skill and official toolkit prerequisites:

```bash
python3 scripts/diagrams/compliance-dr-batch-01.py --render
```

On October 28, 2026, all five passed layout checks, draw.io export and visual
review; repository contracts and Markdown links passed. No provisioning,
provider revalidation, compliance assessment or recovery drill was performed.
Historical validation metadata remains unchanged.

Coverage after that batch was 39 of 80. Latest coverage is recorded below.


## Cross-Cloud Resource Coverage

Cross-cloud overview diagrams are accompanied by explicit resource maps for every
cloud represented in the source templates. Main draw.io documents include the
overview plus each resource-detail page. Each companion PNG has one named card
per source resource declaration, including conditional and collection declarations.
The separate contracts page enumerates local Terraform metadata, not cloud services.

The coverage generator reads root Terraform, recursively follows pinned
same-repository module sources, and enumerates companion Bicep, CloudFormation
and Terraform templates. OCI, Azure, AWS and GCP Terraform resource prefixes
are classified separately. The GCP Partner Interconnect blueprint now includes Google resource definitions
and a generated GCP resource map.

The following completed cross-cloud overviews have full resource-detail companions:

| Blueprint | OCI detail | External-cloud detail | Source coverage |
| --- | --- | --- | --- |
| `networking/hub-spoke-with-azure-vwan-expressroute` | [OCI PNG](../../blueprints/networking/hub-spoke-with-azure-vwan-expressroute/architecture/oci-resources.png) | [AZURE PNG](../../blueprints/networking/hub-spoke-with-azure-vwan-expressroute/architecture/azure-resources.png) | [Inventory](../../blueprints/networking/hub-spoke-with-azure-vwan-expressroute/architecture/resource-inventory.json) |
| `networking/azure-vwan-oci-drg-transit` | [OCI PNG](../../blueprints/networking/azure-vwan-oci-drg-transit/architecture/oci-resources.png) | [AZURE PNG](../../blueprints/networking/azure-vwan-oci-drg-transit/architecture/azure-resources.png) | [Inventory](../../blueprints/networking/azure-vwan-oci-drg-transit/architecture/resource-inventory.json) |
| `networking/azure-oci-dual-connectivity` | [OCI PNG](../../blueprints/networking/azure-oci-dual-connectivity/architecture/oci-resources.png) | [AZURE PNG](../../blueprints/networking/azure-oci-dual-connectivity/architecture/azure-resources.png) | [Inventory](../../blueprints/networking/azure-oci-dual-connectivity/architecture/resource-inventory.json) |
| `networking/aws-oci-hybrid-network-backbone` | [OCI PNG](../../blueprints/networking/aws-oci-hybrid-network-backbone/architecture/oci-resources.png) | [AWS PNG](../../blueprints/networking/aws-oci-hybrid-network-backbone/architecture/aws-resources.png) | [Inventory](../../blueprints/networking/aws-oci-hybrid-network-backbone/architecture/resource-inventory.json) |
| `disaster-recovery/azure-oci-cross-cloud-dr` | [OCI PNG](../../blueprints/disaster-recovery/azure-oci-cross-cloud-dr/architecture/oci-resources.png) | [AZURE PNG](../../blueprints/disaster-recovery/azure-oci-cross-cloud-dr/architecture/azure-resources.png) | [Inventory](../../blueprints/disaster-recovery/azure-oci-cross-cloud-dr/architecture/resource-inventory.json) |

Regenerate overviews first, then rebuild and validate the resource-detail pages:

```bash
python3 scripts/diagrams/multicloud-resource-coverage.py --render
python3 scripts/diagrams/multicloud-resource-coverage.py --check
```

The inventory maps source addresses/symbols to diagram node IDs and retains source
file hashes and module revisions. Coverage checks compare declarations with the
current source, verify diagram labels and ensure PNG files exist. Declarations
are not a Terraform plan, resolved instance count or deployment inventory.

For subsequent cross-cloud conversions, include every cloud's source-declared
resources, preserve conditional/collection status, and run the coverage generator
after the overview export. External services only referenced by input IDs remain
explicit prerequisites rather than resources purportedly created by the blueprint.


## AWS Disaster Recovery And Data Platform Diagrams

This batch replaces five ASCII overviews with editable draw.io documents and PNGs.
Every new blueprint also has a resource-detail inventory following pinned modules.
The database diagrams distinguish optional network/database creation from supplied
resources; APEX adds ingress support to an existing database, not a new workspace.
AWS DR includes the separately deployed CloudFormation stack and its supporting
IAM, KMS, flow logs, launch template, EC2 and Elastic IP resources.

| Batch order | Blueprint | Preview | Editable source | Source coverage |
| --- | --- | --- | --- | --- |
| 16 | `disaster-recovery/aws-oci-cross-cloud-dr` | [PNG](../../blueprints/disaster-recovery/aws-oci-cross-cloud-dr/architecture/architecture.png) | [draw.io](../../blueprints/disaster-recovery/aws-oci-cross-cloud-dr/architecture/architecture.drawio) | [Inventory](../../blueprints/disaster-recovery/aws-oci-cross-cloud-dr/architecture/resource-inventory.json) |
| 17 | `data-platform/autonomous-database` | [PNG](../../blueprints/data-platform/autonomous-database/architecture/architecture.png) | [draw.io](../../blueprints/data-platform/autonomous-database/architecture/architecture.drawio) | [Inventory](../../blueprints/data-platform/autonomous-database/architecture/resource-inventory.json) |
| 18 | `data-platform/private-data-platform` | [PNG](../../blueprints/data-platform/private-data-platform/architecture/architecture.png) | [draw.io](../../blueprints/data-platform/private-data-platform/architecture/architecture.drawio) | [Inventory](../../blueprints/data-platform/private-data-platform/architecture/resource-inventory.json) |
| 19 | `data-platform/postgresql` | [PNG](../../blueprints/data-platform/postgresql/architecture/architecture.png) | [draw.io](../../blueprints/data-platform/postgresql/architecture/architecture.drawio) | [Inventory](../../blueprints/data-platform/postgresql/architecture/resource-inventory.json) |
| 20 | `data-platform/apex-adw` | [PNG](../../blueprints/data-platform/apex-adw/architecture/architecture.png) | [draw.io](../../blueprints/data-platform/apex-adw/architecture/architecture.drawio) | [Inventory](../../blueprints/data-platform/apex-adw/architecture/resource-inventory.json) |

Regenerate overviews before resource pages:

```bash
python3 scripts/diagrams/data-dr-batch-01.py --render
python3 scripts/diagrams/multicloud-resource-coverage.py --render
python3 scripts/diagrams/multicloud-resource-coverage.py --check
```

### Provider Icons

Azure cards now use embedded Azure SVGs, and AWS cards use native AWS stencils.
The five previously published cross-cloud overviews and resource maps were also
updated. Exact names, source types and conditional status remain visible. Native
GCP mappings use verified stencil names; the subsequent Interconnect addition
now includes GCP resource declarations. Unmapped association/metadata types retain
named boxes. See [provider icon sources](../../scripts/diagrams/assets/README.md).

On October 28, 2026, the five new overviews passed layout checks, PNG export and
visual review. Source coverage checks include 198 declarations across ten detailed
blueprints, with 38 Azure and 35 AWS declarations. Repository contracts and local
Markdown links passed. No cloud resources, database sessions, replication paths or
failover drills were provisioned or tested; historical validation dates are unchanged.

Coverage after the AWS/data batch was **44 of 80** existing blueprint entry points
with editable draw.io and PNG overviews; **36 remained** pending conversion.


## Retrospective Review Of The Original 39

The [first-39 review](FIRST-39-REVIEW.md) applies the current complete-resource and
provider-icon standard to every original overview. It adds all conditional and
collection declarations from pinned modules, paginated detail views and separate
existing-resource/override references. The main native documents include every
page; each page has a PNG companion. Source counts, mappings and exact scope are
recorded in the review and inventories.

```bash
python3 scripts/diagrams/multicloud-resource-coverage.py --first-39 --render
python3 scripts/diagrams/review-first-39.py --write-report
```

This retrospective review keeps overall progress at **44/80**, with **36** pending
conversions. No cloud resource was provisioned or adopted.


## Final Follow-On Phase: GCP Blueprints

After completing the original 80 diagram conversions and resource-coverage work,
implement the [GCP counterpart batch](../multicloud/GCP-OCI-BLUEPRINTS.md) following
the existing AWS/Azure blueprint contracts. Include the full OCI and GCP resource
sides, appropriate provider icons, editable draw.io, PNGs and source inventories.
These are new infrastructure blueprints, not diagram-only examples. They remain
planned and are excluded from the original 80-entry conversion denominator.


## Data And AI Continuation

Five further ASCII overviews now have editable draw.io documents and PNGs.
Resource maps include every source declaration, optional AWS RDS and supporting
resources, local DR contracts and existing-resource/override references.

| Batch order | Blueprint | Preview | Editable source | Source coverage |
| --- | --- | --- | --- | --- |
| 21 | `data-platform/opensearch` | [PNG](../../blueprints/data-platform/opensearch/architecture/architecture.png) | [draw.io](../../blueprints/data-platform/opensearch/architecture/architecture.drawio) | [Inventory](../../blueprints/data-platform/opensearch/architecture/resource-inventory.json) |
| 22 | `data-platform/mysql-heatwave` | [PNG](../../blueprints/data-platform/mysql-heatwave/architecture/architecture.png) | [draw.io](../../blueprints/data-platform/mysql-heatwave/architecture/architecture.drawio) | [Inventory](../../blueprints/data-platform/mysql-heatwave/architecture/resource-inventory.json) |
| 23 | `data-platform/oci-aws-mysql-heatwave-dr` | [PNG](../../blueprints/data-platform/oci-aws-mysql-heatwave-dr/architecture/architecture.png) | [draw.io](../../blueprints/data-platform/oci-aws-mysql-heatwave-dr/architecture/architecture.drawio) | [Inventory](../../blueprints/data-platform/oci-aws-mysql-heatwave-dr/architecture/resource-inventory.json) |
| 24 | `ai/genai-private` | [PNG](../../blueprints/ai/genai-private/architecture/architecture.png) | [draw.io](../../blueprints/ai/genai-private/architecture/architecture.drawio) | [Inventory](../../blueprints/ai/genai-private/architecture/resource-inventory.json) |
| 25 | `ai/ai-services` | [PNG](../../blueprints/ai/ai-services/architecture/architecture.png) | [draw.io](../../blueprints/ai/ai-services/architecture/architecture.drawio) | [Inventory](../../blueprints/ai/ai-services/architecture/resource-inventory.json) |

```bash
python3 scripts/diagrams/data-ai-batch-01.py --render
python3 scripts/diagrams/multicloud-resource-coverage.py --render
python3 scripts/diagrams/multicloud-resource-coverage.py --check
```

On October 28, 2026, source coverage includes 57 declarations in this batch:
39 OCI, 13 AWS and 5 local contracts. They are declaration counts, not deployed
instance counts. Network and database flags, independently created buckets,
external network prerequisites and unimplemented replication/failover steps are
explicit. All 17 pages passed layout/export and visual review; 29 identifier
references are documented separately. Source checks, XML structure, regression
tests, repository contracts and local Markdown links passed.
No cloud resources, inference calls, database connections or DR drills
were created or tested. Historical validation dates remain unchanged.

Latest coverage: **49 of 80** existing blueprint entry points have editable
draw.io and PNG overviews; **31 remain**. The new deployable GCP counterparts
remain the final follow-on phase, after completing the original 80.


## Dedicated Interconnect Additions

The user's specific Interconnect request adds two entry points outside the
original 80: [OCI/AWS](../../blueprints/networking/aws-oci-managed-interconnect/architecture/README.md)
and [OCI/GCP](../../blueprints/networking/gcp-oci-partner-interconnect/architecture/README.md).
Each includes both cloud resource sides, draw.io/PNG, paginated resource maps
and an inventory. Provider-managed activation is explicitly distinguished from
Terraform-owned resources. See the [coverage and evidence record](../multicloud/INTERCONNECT-COVERAGE.md).

```bash
python3 scripts/diagrams/interconnect-batch-01.py --render
python3 scripts/diagrams/multicloud-resource-coverage.py --blueprint networking/aws-oci-managed-interconnect --blueprint networking/gcp-oci-partner-interconnect --render
```

The original conversion backlog remains **49/80**, with **31** pending.
Including these two new complete diagram sets, **51/82** current entry points
have editable overviews and PNGs. The other planned GCP counterparts remain a
follow-on phase; this explicit Interconnect request brings its networking base forward.


## Connection-Line Standard And Review

Every topology overview must visibly connect its related services. Every
cross-cloud overview must include an explicit bridge between the OCI and remote
cloud boundaries. Use solid lines for declared associations/routing and clearly
labelled dashed lines for missing transport, operator workflows and external
prerequisites. A line never establishes working traffic or successful failover.

Do not invent a direct service link to make every icon connected. Independent
buckets, alert topics and policy inputs can remain independent when the source
contains no producer, subscription or binding. Resource-detail inventories are
not traffic diagrams and need no artificial connections.

The October 28 connection review corrected nine overviews, including OCI/AWS
MySQL DR, service-level associations, logging and explicit Azure/AWS handoffs.
The [machine-readable audit](connection-review.json) covers all 51 published
overviews, checks layout/native references and requires a cross-cloud bridge
where the source inventory contains external-cloud resources. It does not
validate cloud traffic or expand the original conversion progress.

```bash
python3 scripts/diagrams/check-connections.py --write-report
```

The authoring scripts remain authoritative. Re-export an updated overview first,
then rebuild its native resource-detail pages with the coverage generator.
Extend the connection-check registry whenever a new overview batch is added.

All nine updated overview PNGs passed visual review after export. Repository
contracts, local Markdown links, source coverage and native XML reference checks
passed. The first-39 report was refreshed for the three changed original
views. No Terraform resources or historical validation metadata changed.


## AI Gateways, Fine-Tuning, Guardrails And Documents

Five existing entry points now have draw.io/PNG overviews, service-connection
lines, full source inventories and existing-resource reference pages. The Azure
view includes every Bicep resource and clearly distinguishes public hello-world
hosting, OpenAI model deployment, APIM and missing inference adapters. Training
and hosting cluster roles remain separate. Document processing and guardrail
redaction are not falsely represented as implemented application code.

| Batch order | Blueprint | Preview | Editable source | Source inventory |
| --- | --- | --- | --- | --- |
| 26 | `ai/genai-gateway` | [PNG](../../blueprints/ai/genai-gateway/architecture/architecture.png) | [draw.io](../../blueprints/ai/genai-gateway/architecture/architecture.drawio) | [Inventory](../../blueprints/ai/genai-gateway/architecture/resource-inventory.json) |
| 27 | `ai/azure-oci-ai-gateway` | [PNG](../../blueprints/ai/azure-oci-ai-gateway/architecture/architecture.png) | [draw.io](../../blueprints/ai/azure-oci-ai-gateway/architecture/architecture.drawio) | [Inventory](../../blueprints/ai/azure-oci-ai-gateway/architecture/resource-inventory.json) |
| 28 | `ai/genai-fine-tuning` | [PNG](../../blueprints/ai/genai-fine-tuning/architecture/architecture.png) | [draw.io](../../blueprints/ai/genai-fine-tuning/architecture/architecture.drawio) | [Inventory](../../blueprints/ai/genai-fine-tuning/architecture/resource-inventory.json) |
| 29 | `ai/genai-guardrails` | [PNG](../../blueprints/ai/genai-guardrails/architecture/architecture.png) | [draw.io](../../blueprints/ai/genai-guardrails/architecture/architecture.drawio) | [Inventory](../../blueprints/ai/genai-guardrails/architecture/resource-inventory.json) |
| 30 | `ai/document-intelligence` | [PNG](../../blueprints/ai/document-intelligence/architecture/architecture.png) | [draw.io](../../blueprints/ai/document-intelligence/architecture/architecture.drawio) | [Inventory](../../blueprints/ai/document-intelligence/architecture/resource-inventory.json) |

```bash
python3 scripts/diagrams/ai-batch-02.py --render
python3 scripts/diagrams/multicloud-resource-coverage.py --render
python3 scripts/diagrams/multicloud-resource-coverage.py --check
python3 scripts/diagrams/check-connections.py --write-report
```

Source review October 28, 2026: 46 declarations (OCI 32, Azure 10, local contracts
4). Counts are declarations, not deployed instances. Source coverage includes
conditional resources, optional endpoint/model configuration and ID overrides.
No cloud provisioning, provider validation, inference, training, quota enforcement
or document processing was executed; historical validation metadata is unchanged.

Latest original backlog: **54/80** converted; **26** pending. Including the two
new Interconnect entry points, **56/82** current entry points have editable
architecture overviews and PNGs. The connection audit covers all 56 overviews
and requires an explicit OCI bridge in all ten source-defined multicloud views.
Other planned GCP counterparts remain pending after the original backlog.

All 17 new overview/detail/reference PNGs passed export and visual review.
The five documents include 39 identifier references. Layout checks, source
coverage, native-page references, the three inventory-parser regressions,
repository contracts and local Markdown links passed. No infrastructure source
files changed in this diagram batch.

## Full Connector Re-review / October 28, 2026

The [full review](CONNECTOR-REVIEW.md) covers all 56 published blueprint overviews
and the separate conceptual drawing. It corrects 17 blueprint overviews and
regenerates the conceptual drawing. Every native draw.io document is included in
the structural registry; inventory/reference cards deliberately have no inferred
traffic paths. This review does not advance the original conversion backlog.

The [reviewed connector contract](reviewed-connectors.json) retains endpoints,
directions, labels, line types, paths and source-file revisions/hashes. Ordinary
checks reject changes to that contract until the diagram receives another source
and visual review. Run `python3 scripts/diagrams/check-connections.py --write-report`
after composing resource pages. Use `--record-reviewed-connectors` only after
reviewing changed relationships and rendered PNGs, including new catalog entries.

## Healthcare Platform Project / October 28, 2026

[Healthcare Platform](../../blueprints/industry/healthcare-platform/README.md)
adds a private industry application/data project with editable
[draw.io](../../blueprints/industry/healthcare-platform/architecture/architecture.drawio)
and a [PNG overview](../../blueprints/industry/healthcare-platform/architecture/architecture.png).
Hospital transport, identity, application integration, KMS and backup-policy
prerequisites are explicitly separated from created infrastructure. Conditional
resources and existing identifier inputs have complete companion pages.

The original backlog remains **54/80**. With the two Interconnect additions and
this healthcare blueprint, **57/83** current entry points have diagram sets.
The connector registry now also includes the healthcare overview; the separate
conceptual drawing is excluded from the blueprint conversion denominator.
No clinical application, hospital transport or real patient data was deployed.

## Separate Hospital/FHIR Integration Project / October 28, 2026

[Hospital Integration and FHIR](../../blueprints/industry/healthcare-fhir-integration/README.md)
is delivered separately from the patient-data foundation, with a private
[API/queue overview](../../blueprints/industry/healthcare-fhir-integration/architecture/architecture.png),
editable draw.io, full source inventories and existing-resource reference pages.
FHIR server software, source adapters, identity, clinical authorization and
message workers are explicitly external. No API-to-Queue pipeline is invented.

Latest diagram coverage is **58/84** current entry points. The original catalog
backlog remains **54/80**; neither healthcare addition counts as an original
conversion. Both projects include local schema and mocked-plan evidence, not
live patient-data or interoperability validation.

## AI, DevOps and Industry Continuation / October 28, 2026

Five further original-catalog entry points now have editable multi-page draw.io
documents, PNG overviews, complete resource inventories and existing-resource
reference pages. ASCII architecture drawings have been replaced in their local
architecture READMEs. Official toolkit icons are used where an exact service
glyph exists; unsupported agent subtypes use explicit labelled boxes.

| Batch order | Blueprint | Preview | Editable source | Source inventory |
| --- | --- | --- | --- | --- |
| 31 | `ai/embedding-pipeline` | [PNG](../../blueprints/ai/embedding-pipeline/architecture/architecture.png) | [draw.io](../../blueprints/ai/embedding-pipeline/architecture/architecture.drawio) | [Inventory](../../blueprints/ai/embedding-pipeline/architecture/resource-inventory.json) |
| 32 | `ai/multi-agent` | [PNG](../../blueprints/ai/multi-agent/architecture/architecture.png) | [draw.io](../../blueprints/ai/multi-agent/architecture/architecture.drawio) | [Inventory](../../blueprints/ai/multi-agent/architecture/resource-inventory.json) |
| 33 | `ai/agents` | [PNG](../../blueprints/ai/agents/architecture/architecture.png) | [draw.io](../../blueprints/ai/agents/architecture/architecture.drawio) | [Inventory](../../blueprints/ai/agents/architecture/resource-inventory.json) |
| 34 | `devops/oci-devops-pipeline` | [PNG](../../blueprints/devops/oci-devops-pipeline/architecture/architecture.png) | [draw.io](../../blueprints/devops/oci-devops-pipeline/architecture/architecture.drawio) | [Inventory](../../blueprints/devops/oci-devops-pipeline/architecture/resource-inventory.json) |
| 35 | `industry/telco-cloud-native` | [PNG](../../blueprints/industry/telco-cloud-native/architecture/architecture.png) | [draw.io](../../blueprints/industry/telco-cloud-native/architecture/architecture.drawio) | [Inventory](../../blueprints/industry/telco-cloud-native/architecture/resource-inventory.json) |

The five inventories enumerate **53 OCI resource declarations** and **32 existing
identifier inputs**, not deployed instances. Six resource-detail pages preserve
conditional declarations and all pinned transitive modules; five input pages
record existing-resource prerequisites. Together with the five overviews, this
batch adds **16 native documents and 16 PNGs**.

Embedding and multi-agent processing remain external application workflows. The
RAG blueprint includes a separately enabled one-time ingestion job, with no
successful indexing implied. DevOps resources are empty shells with project/topic
associations, without invented repository-to-build-to-deploy execution. Telco
uses network revision `d7938f4baef1aa512fc8dcee99a545ec17e0dab2` and `v0.2.0`
service modules, showing exact hub subnet bindings and no created service LB/CNF.
No external-cloud resource is declared by these five entry points.

```bash
python3 scripts/diagrams/ai-industry-batch-03.py --render
python3 scripts/diagrams/multicloud-resource-coverage.py --blueprint ai/embedding-pipeline --blueprint ai/multi-agent --blueprint ai/agents --blueprint devops/oci-devops-pipeline --blueprint industry/telco-cloud-native --render
python3 scripts/diagrams/multicloud-resource-coverage.py --check
python3 scripts/diagrams/check-connections.py --write-report
```

Latest original backlog: **59/80 converted**, **21 pending**. Including the four
additional Interconnect/healthcare projects, current diagram coverage is
**63/84** entry points. The separate conceptual drawing is excluded from that
denominator. Remaining GCP counterparts are still the final phase after the
original conversion backlog; see the [GCP plan](../multicloud/GCP-OCI-BLUEPRINTS.md).

This batch changes documentation, diagrams and their authoring/validation
registry only. Historical provider validation metadata remains unchanged; no
cloud deployment, inference, indexing, CI/CD execution or traffic test was run.

## Secure Desktops and Kubernetes Extensions / October 28, 2026

Five further original-catalog entry points now have editable multi-page draw.io
documents and PNG previews. The two multicloud views include complete companion
Azure/AWS declarations, exact native cluster glyphs and an explicit dashed
Interconnect prerequisite. ASCII architecture drawings were replaced in the
five local architecture READMEs.

| Batch order | Blueprint | Preview | Editable source | Source inventory |
| --- | --- | --- | --- | --- |
| 36 | `industry/secure-desktops` | [PNG](../../blueprints/industry/secure-desktops/architecture/architecture.png) | [draw.io](../../blueprints/industry/secure-desktops/architecture/architecture.drawio) | [Inventory](../../blueprints/industry/secure-desktops/architecture/resource-inventory.json) |
| 37 | `extensions/oke` | [PNG](../../blueprints/extensions/oke/architecture/architecture.png) | [draw.io](../../blueprints/extensions/oke/architecture/architecture.drawio) | [Inventory](../../blueprints/extensions/oke/architecture/resource-inventory.json) |
| 38 | `extensions/aks-oke-active-passive` | [PNG](../../blueprints/extensions/aks-oke-active-passive/architecture/architecture.png) | [draw.io](../../blueprints/extensions/aks-oke-active-passive/architecture/architecture.drawio) | [Inventory](../../blueprints/extensions/aks-oke-active-passive/architecture/resource-inventory.json) |
| 39 | `extensions/eks-oke-active-passive` | [PNG](../../blueprints/extensions/eks-oke-active-passive/architecture/architecture.png) | [draw.io](../../blueprints/extensions/eks-oke-active-passive/architecture/architecture.drawio) | [Inventory](../../blueprints/extensions/eks-oke-active-passive/architecture/resource-inventory.json) |
| 40 | `extensions/oke-service-mesh` | [PNG](../../blueprints/extensions/oke-service-mesh/architecture/architecture.png) | [draw.io](../../blueprints/extensions/oke-service-mesh/architecture/architecture.drawio) | [Inventory](../../blueprints/extensions/oke-service-mesh/architecture/resource-inventory.json) |

The source inventories contain **64 resource declarations**: OCI 33, Azure 5,
AWS 18 and local metadata/validation contracts 8. These are declarations, not
expanded or deployed instance counts. **47 existing identifier inputs** are
recorded separately. Five overviews, nine resource-detail pages and five input
reference pages add **19 native documents and 19 PNGs**.

Secure Desktops reuses supplied networks/images/backup policy; private-access
details are pool configuration. OKE creates no network or service Load Balancer.
The Service Mesh entry point declares an optional add-on definition and an
independent APM domain; no tracing integration or mTLS policy is invented.
AKS/EKS templates create cloud foundations separately; GitOps and Interconnect
contracts do not install controllers, circuits, gateways, routes or workloads.
Optional DNS policy/monitor/zone associations describe DNS answers and probes,
not a packet-forwarding tier. No recovery-time guarantee or supported Kubernetes
version is inferred from source parameters.

```bash
python3 scripts/diagrams/compute-extensions-batch-01.py --render
python3 scripts/diagrams/multicloud-resource-coverage.py --blueprint industry/secure-desktops --blueprint extensions/oke --blueprint extensions/aks-oke-active-passive --blueprint extensions/eks-oke-active-passive --blueprint extensions/oke-service-mesh --render
python3 scripts/diagrams/multicloud-resource-coverage.py --check
python3 scripts/diagrams/check-connections.py --write-report
```

Latest original catalog: **64/80 converted**, **16 pending**. Including four
additional Interconnect/healthcare projects, current diagram coverage is
**68/84** entry points, plus the separate conceptual drawing. Remaining GCP
counterparts stay in the final phase after the original conversion backlog;
see the [GCP plan](../multicloud/GCP-OCI-BLUEPRINTS.md).

Only diagrams, documentation, provider-icon assets and authoring/validation
registry files change in this batch. Historical infrastructure validation
metadata remains unchanged. No cloud provisioning, desktop session, node
registration, application request, mesh traffic or failover was tested.

This batch also fixes multiline creation-gate labels in generated resource
cards. Full conditions were already retained in the JSON inventory; cards now
show every condition instead of just the first line. A render regression checks
that all health-monitor enablement predicates survive into native draw.io XML.

## OCVS Blueprint Addition / October 28, 2026

[Oracle Cloud VMware Solution](../../blueprints/industry/ocvs/README.md) is now
an implemented industry entry point rather than a planned catalog row. The
[PNG](../../blueprints/industry/ocvs/architecture/architecture.png) and editable
[draw.io](../../blueprints/industry/ocvs/architecture/architecture.drawio) describe
an optional dense/vSAN SDDC with MANAGEMENT and explicit WORKLOAD clusters,
using dedicated existing subnet/VLAN sets per cluster. Corporate VMware, HCX
remote appliances and private transport/DNS are marked external prerequisites.

There is no matching OCVS/VMware glyph in the installed OCI toolkit, so named
component boxes retain exact service meaning. The native document contains the
overview, one OCI declaration page, one local-contract page and an existing
resource-input page with 15 entries, including the nested workload-cluster
network/BYOL collection. These are declarations/references, not deployed counts.

Current diagram coverage becomes **69/85** entry points plus one conceptual
drawing; the original backlog remains **64/80**, with **16** pending. This new
OCVS addition is separate from that original conversion backlog and from the
remaining final-phase GCP counterparts. Local schema validation and 19 mocked
plans passed; [evidence](../OCVS-20261028.md) distinguishes these checks from
provisioning, licensing/capacity, network acceptance and migration testing.

```bash
python3 scripts/diagrams/ocvs.py --render
python3 scripts/diagrams/multicloud-resource-coverage.py --blueprint industry/ocvs --render
python3 scripts/diagrams/multicloud-resource-coverage.py --blueprint industry/ocvs --check
python3 scripts/diagrams/check-connections.py --write-report
```

## Optional Platform Extensions / October 28, 2026

Five additional original catalog entries now have native draw.io overviews,
PNGs, complete declaration pages and existing-resource input pages. Source
conditions and default-disabled service flags remain visible.

| Blueprint | OCI declarations | Existing-resource references | Overview connectors |
| --- | ---: | ---: | ---: |
| [Exadata](../../blueprints/extensions/exadata/architecture/README.md) | 1 | 1 | 2 |
| [API Gateway](../../blueprints/extensions/apigw/architecture/README.md) | 2 | 5 | 5 |
| [Analytics Cloud](../../blueprints/extensions/oac/architecture/README.md) | 2 | 7 | 3 |
| [Integration](../../blueprints/extensions/oic/architecture/README.md) | 2 | 5 | 3 |
| [Observability](../../blueprints/extensions/observability/architecture/README.md) | 4 | 4 | 2 |

The batch covers **11 OCI declarations**, **22 existing-resource references**,
and **15 reviewed connectors** in **15 native documents with paired PNGs**.
The main documents each contain the overview, declaration map and input map.
Official service glyphs are used for Exadata, API Gateway, Analytics,
Integration, Logging Analytics, APM and Operations Insights. Attachments and
other resources without an exact matching glyph use named boxes.

Exadata declares infrastructure capacity only; no maintenance-window block,
VM cluster, database or network is added. API Gateway distinguishes an explicit
existing gateway ID from a created fallback, and shows only declared backend
route intent. OAC/OIC channel lines represent instance and existing-network
associations; no data connection or integration flow is invented. Observability
marks Log Analytics namespace onboarding as tenancy-root scope and leaves its
independent APM domain unconnected to other telemetry services.

```bash
python3 scripts/diagrams/extensions-batch-02.py --render
python3 scripts/diagrams/multicloud-resource-coverage.py --blueprint extensions/exadata --blueprint extensions/apigw --blueprint extensions/oac --blueprint extensions/oic --blueprint extensions/observability --render
python3 scripts/diagrams/multicloud-resource-coverage.py --check
python3 scripts/diagrams/check-connections.py --write-report
python3 -m unittest discover -s scripts/diagrams -p test_resource_coverage.py
bash scripts/check-repo-contracts.sh
```

Current original conversion progress is **69/80**, with **11 pending**.
Including the five additional Interconnect, healthcare and OCVS blueprints,
current coverage is **74/85**, plus the separate conceptual drawing. Current
audit totals are **622 reviewed connectors**, **273 native documents and PNGs**,
and **12 source-defined OCI/cloud bridges**. GCP counterparts remain in the
final phase after the original conversion backlog; see the
[GCP plan](../multicloud/GCP-OCI-BLUEPRINTS.md).

This is a diagram/documentation-only batch reviewed on 2026-10-28. No Terraform
resource configuration, historical validation date or provider evidence changes.
No cloud provisioning, service activation, ingestion, application request,
private connectivity or runtime test was performed.
