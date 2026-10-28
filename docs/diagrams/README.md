# Architecture Diagram Sources

`oci-3tier-adb.drawio` is an editable conceptual three-tier architecture with web and app VMs, a public load balancer, and an Autonomous Database private endpoint. It is not a deployment-evidence diagram for a specific Terraform blueprint. The application reaches regional Oracle services through the Service Gateway; database sessions use the separate private endpoint path. Customer-specific NSGs, routes, ports, DNS, availability placement, and workload resources require separate configuration and validation. The XML was parsed successfully during the October 14, 2026 repository review; rendered layout and packet flows were not tested.


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
are classified separately. No GCP resource definitions were found in the current
repository; a GCP resource map is generated when GCP definitions are present.

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
GCP mappings are prepared and their stencil names verified, but the current source
contains no GCP resource declarations. Unmapped association/metadata types retain
named boxes. See [provider icon sources](../../scripts/diagrams/assets/README.md).

On October 28, 2026, the five new overviews passed layout checks, PNG export and
visual review. Source coverage checks include 198 declarations across ten detailed
blueprints, with 38 Azure and 35 AWS declarations. Repository contracts and local
Markdown links passed. No cloud resources, database sessions, replication paths or
failover drills were provisioned or tested; historical validation dates are unchanged.

Latest coverage: **44 of 80** existing blueprint entry points have editable draw.io
and PNG architecture overviews; **36 remain** pending conversion.
