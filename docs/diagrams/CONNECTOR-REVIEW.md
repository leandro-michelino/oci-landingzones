# Full Connector Review

Review date: October 28, 2026. Scope: every published architecture overview in
this repository, including the standalone conceptual three-tier drawing.

The review covers **56 blueprint overviews plus one conceptual overview**.
Seventeen blueprint overviews were corrected. All original overview PNGs were
inspected; changed PNGs were exported and inspected again. Resource/reference
pages enumerate declarations and operator inputs, so they intentionally do not
invent traffic paths. Four older data-platform inventories were upgraded to include
the same complete source expressions and existing-resource reference pages.

## Corrections

| Area | Corrected relationship | Source evidence |
| --- | --- | --- |
| Standalone three-tier defaults/custom/ZPR | Public route table points toward IGW; subnet association remains a plain line | Pinned spoke-vcn route rules and subnet bindings in each resource inventory |
| Private DNS and shared services | Resolver associations bind the private view; zones belong to that view | `modules/networking/dns/main.tf`, `oci_dns_zone.private.view_id` and `oci_dns_resolver.vcn.attached_views.view_id`; pinned revisions in each inventory |
| Dual-region and production/nonproduction | Explicit subnet-to-RT associations and RT-to-IGW/NAT/SGW/DRG arrows replace text-only descriptions | Pinned hub-vcn and spoke-vcn modules; each foundation remains independent |
| Operating entity / multiple entities / workload vending | Policies connect to generated compartment roots rather than implying grants over the parent; lines avoid placement text | Each blueprint's `locals.tf` policy definitions and module compartment/group inputs |
| Zero Trust | NAT now explicitly connects to outbound Internet | Pinned network route rules; no inbound NAT path |
| Azure DR | Subnet-to-environment binding and environment-to-workspace log configuration are explicitly labelled | `azure/main.bicep`: `infrastructureSubnetId` and `appLogsConfiguration` |
| Private data platform | All subnet RT associations, regional SGW path and declared private-endpoint configuration links are visible | Pinned private-network, Object Storage endpoint and Streaming modules in the inventory |
| OCI/AWS MySQL DR | `route_table_id` connects the subnet to RT, instead of the DB System to RT | `oci_core_subnet.primary_db.route_table_id`; AWS routing and replication remain external dashed prerequisites |
| AWS managed Interconnect | OCI subnet-to-RT, RT-to-DRG, AWS subnet-to-RT and RT-to-VGW paths are explicit | Root `main.tf`: subnet bindings, `aws_route_table_association.this`, `aws_route.oci` |
| GCP Partner Interconnect | OCI subnet-to-RT route path and Cloud Router-to-VPC network binding are explicit | Root `main.tf`: OCI route rule and `google_compute_router.this.network`; Router binding is labelled control plane |
| GenAI fine-tuning | Training-cluster association uses the exact property name | `fine_tune_details.dedicated_ai_cluster_id` in root `main.tf` |
| Conceptual three-tier | Proper nested resources, explicit outbound NAT path and separate ADB/OSN paths | Illustrative design only; no Terraform deployment claim |

## Repeatable Checks

The [connector contract](reviewed-connectors.json) records each relationship's
source/target labels and kinds, arrows, dashed state, anchors, waypoints and
source-file revisions/hashes. This captures the reviewed diagram state; it is
not an automatic proof of architectural correctness. Changes require another
source and visual review before recording a replacement contract.

The 57 overviews contain **476 connectors**. Structural checks cover all
**210 native documents**, including resource and prerequisite-reference maps.
The [audit report](connection-review.json) records current diagram counts,
connector counts, PNG hashes and explicit OCI bridges in ten multicloud views.
The checker also checks icon/text crossings, valid native references, overview
agreement with authoring scripts, subnet RT bindings and DNS-view associations.
Every `.drawio` file must belong to the registered overview/detail/reference set.

```bash
python3 scripts/diagrams/check-connections.py --write-report
python3 scripts/diagrams/review-first-39.py --write-report
python3 scripts/diagrams/multicloud-resource-coverage.py --check
python3 -m unittest discover -s scripts/diagrams -p test_resource_coverage.py
bash scripts/check-repo-contracts.sh
```

Only after inspecting changed sources and PNGs, explicitly record new reviewed
relationships with `check-connections.py --record-reviewed-connectors --write-report`.
Never replace the contract simply to make a failing check pass.

No Terraform, Bicep or CloudFormation infrastructure configuration was changed.
No provisioning, BGP, packet-flow, inference, replication or failover test was
performed. Historical provider/live validation metadata is unchanged. Original
catalog progress remains **54/80**, with **26** pending; the two additional
Interconnect blueprints make current diagram coverage **56/82**. Remaining GCP
counterpart blueprints are still a separate final phase.

## Subsequent Healthcare Additions

The baseline review above preceded the two healthcare projects. The current
registry adds `industry/healthcare-platform` (19 connectors, five native/PNG
documents) and `industry/healthcare-fhir-integration` (16 connectors, four
native/PNG documents). Current totals are 58 blueprint plus one conceptual
overviews, 511 connectors and 219 native documents. The two projects have no
automatically provisioned connection or clinical data exchange between them.

See [patient data](../../blueprints/industry/healthcare-platform/README.md),
[hospital/FHIR integration](../../blueprints/industry/healthcare-fhir-integration/README.md)
and the [current audit](connection-review.json). The original 80-entry conversion
backlog remains unchanged; current diagram coverage is 58/84 entry points.

## Subsequent AI, DevOps and Telco Batch

The five additional overviews contribute 44 reviewed connectors: Embedding
Pipeline 7, Multi-Agent 7, Agents/RAG 5, DevOps 4 and Telco 21. Current totals
are **63 blueprint plus one conceptual overviews**, **555 connectors** and
**235 native documents**. Source declarations, creation conditions, ID bindings
and pinned module revisions bound the review. Inventory/reference card pages
remain enumeration views, with no invented traffic connections.

DevOps project/topic associations do not imply executable pipeline stages.
Embedding, task dispatch and tool execution are dashed external workflows.
RAG ingestion-job/data-source and agent/knowledge-base links are declared ID
bindings. Telco shows subnet route-table associations, configured network routes
and optional OKE module bindings, without implying an operational CNF platform.

The [current audit](connection-review.json) and [review contract](reviewed-connectors.json)
include these entries. Original conversion progress is **59/80**, with **21**
pending; current coverage including additional projects is **63/84**.
No cloud resources or runtime tests were introduced by this diagram batch.

## Subsequent Secure Desktops and Kubernetes Batch

Five overviews add **45 connectors**: Secure Desktops 4, OKE 2, AKS/OKE 15,
EKS/OKE 23 and OKE Service Mesh 1. Current totals are **68 blueprint plus one
conceptual overviews**, **600 connectors** and **254 native documents/PNGs**.
Both new source-defined multicloud views have an explicit OCI/cloud bridge,
bringing that audit to **12**. The bridges are dashed external dependencies:
no new circuit, edge gateway, peering or remote-prefix route is claimed.

Review covers subnet/RT bindings and IGW routes, cluster/subnet/SG associations,
managed-node placement, KMS secret/log encryption, VPC flow-log delivery and
optional DNS policy/zone/monitor/answer relationships. DNS is not represented
as a packet-forwarding hop. Independent APM and add-on resources have no
invented telemetry connection. No runtime or failover result is inferred.

The [audit](connection-review.json) and [review contract](reviewed-connectors.json)
include the new relationships and source fingerprints. Original conversion
progress is **64/80**, with **16** pending; current coverage is **68/84** including
the four additional Interconnect/healthcare projects.

## OCVS Addition

The OCVS overview adds seven reviewed relationships: external corporate-to-
transport and transport-to-VCN prerequisites; per-cluster provisioning-subnet
IDs; the VLAN role map; optional HCX and Replication-Net map entries; and the
VCF BYOL allocation reference. All ID bindings are plain lines. External
transport/migration prerequisites remain dashed; no private path or migration
is asserted. The BYOL line is routed separately from the HCX map association.

Current totals are **69 blueprint plus one conceptual overviews**, **607
connectors** and **258 native documents/PNGs**. There remain 12 explicitly
bridged source-defined multicloud overviews; the OCVS external corporate
prerequisites do not create another cloud deployment. Current catalog coverage
is **69/85**, while the original conversion backlog remains **64/80**.

## Subsequent Optional Platform Extensions Batch

Five overviews add **15 reviewed relationships**: Exadata 2, API Gateway 5,
Analytics Cloud 3, Integration 3 and Observability 2. Exadata lines identify
availability-domain and contact configuration rather than database traffic.
API Gateway has distinct conditional bindings for a supplied gateway ID and
the newly created fallback, supplied subnet/NSGs/certificate associations,
and configured backend-route intent. URL and status-based backends do not
imply identical packet flows.

OAC and OIC associations bind optional channels to selected instances and
existing network inputs. OAC KMS/domain and OIC domain/token properties do not
create identity services. Log Analytics group-to-namespace is a namespace
configuration association, not log ingestion. Operations Insights selects
existing VCN/subnet/NSGs. No invented connector links independent APM,
Log Analytics or OPSI services. Namespace onboarding is marked tenancy-root.

The source hashes, endpoints, labels, directions and paths are recorded in the
[review contract](reviewed-connectors.json); the [audit](connection-review.json)
checks native-page IDs, reference integrity, source coverage and empty icon/text
crossing warnings. PNG overviews and declaration/input pages were inspected.

Current totals are **74 blueprint plus one conceptual overviews**, **622
connectors**, **273 native documents/PNGs**, and **12 explicit OCI/cloud
bridges**. Original conversion progress is **69/80**, with **11 pending**;
current coverage including five additional blueprints is **74/85**. All checks
are static diagram/source checks, not provisioning or runtime validation.

## VMware Hybrid And Generic Workload Review

The onprem/OCVS, AVS/OCVS and triangle overviews add 9, 11 and 17 relationships.
The existing OCVS overview adds three dashed proposed workload relationships.
Plain associations cover supplied cluster-network/license IDs, DRG VCN attachment,
AVS HCX parent, AVS-managed circuit and Global Reach peer/authorization bindings.
Solid circuit-intent arrows describe optional partner FastConnect and the linked
Oracle-facing Azure ExpressRoute circuit, not observed traffic.

Dashed HCX pairings are external workflows requiring enabled cloud components,
compatible versions/licensing, profiles, per-pair meshes and real path validation.
The triangle's separate onprem carrier ExpressRoute leg terminates at its own
AVS Global Reach attachment; it does not route onprem traffic across the Oracle
Interconnect. AVS-to-Oracle attachment eligibility remains a vendor-confirmation
gate, not an implication of a line. No implicit VNet gateway transit is drawn.
The generic guest application arrows are explicitly proposed HTTPS/TLS flows;
no guest VM, open rule, database connection or successful request is asserted.

Source coverage includes the source-pinned OCVS module and both Azure companion
files. PNGs were inspected for service glyphs and connection/label placement.
The [contract](reviewed-connectors.json) records these reviewed endpoints, styles,
labels, paths and source fingerprints. The [current audit](connection-review.json)
now covers **77 blueprint plus one conceptual overviews**, **662 connectors**,
**287 native documents and PNGs**, and **14 explicit OCI/cloud bridges**.
Original conversion progress remains **69/80**, with **11 pending**; current
coverage including eight additional projects is **77/88**. These are source,
geometry and document checks, not runtime acceptance.

## Triangle Customer ExpressRoute Clarification / October 28, 2026

The triangle overview now gives the existing customer/carrier ExpressRoute
circuit its own Azure glyph and boundary. The previous onprem-group-to-AVS
attachment line is replaced with two explicit relationships: customer edge to
carrier circuit (dashed external provisioning/path), and the optional AVS
Global Reach attachment to that circuit (plain `onpremCircuitId`/authorization
association). The attachment's AVS-managed-circuit association is unchanged.
The customer path connects directly to Azure/AVS and does not pass through OCI
or the separate Oracle-facing ExpressRoute circuit.

The triangle now has 18 overview relationships; the global total is 663 across
77 blueprint plus one conceptual overviews. There are still 287 native
files/PNGs and 14 source-defined multicloud overviews with explicit OCI/cloud
bridges. Resource declaration/input counts and cloud creation conditions are
unchanged. Geometry, PNG and native-page/source checks passed. This is a
source/diagram clarification, not provisioning or a connectivity test.

## Subsequent Streaming And Application Runtime Batch

The next five overviews add **24 reviewed connectors**: Streaming 3, WAF 3,
Container Instances 3, Functions 7 and Event-driven Platform 8. Streaming pool
bindings distinguish explicit existing IDs from created fallbacks. Its separate
compartment-scoped branch has no invented explicit pool attachment. WAF lines
associate a selected policy and existing Load Balancer; no protection rule or
policy-as-packet-hop is inferred.

Container lines represent nested configuration blocks. Its independent IAM
policy has no invented grant/application association. Function configuration
lines apply only to created Functions; API/FAAS arrows can select created keys
or independent existing Function IDs. OCIR-to-image linkage is dashed because
build/push/reference selection remains external. The created repository URL is
not automatically bound to a Function's image field.

Events actions distinguish FAAS, OSS and ONS target selections. Bucket-to-Events
is dashed and requires a matching supplied event condition. Service Connector
source selection shows the created-stream-key fallback; the default archive
path is conditional on objectStorage and no bucket/namespace override. Other
target identifiers are configuration choices, not automatically created services.
The archive name can be computed without creating its bucket; a deadletter name
is not retry/DLQ automation. No subscription, application or telemetry path is
invented to connect an independent resource.

The [review contract](reviewed-connectors.json) includes endpoint, label, style,
path and source fingerprints. Main PNGs and native declaration/input pages were
inspected. Current [audit](connection-review.json) totals are **82 blueprint plus
one conceptual overviews**, **687 connectors** and **302 native documents/PNGs**.
Fourteen source-defined multicloud overviews retain explicit OCI/cloud bridges.
Original conversion progress is **74/80**, with **6 pending**; current coverage
including eight additions is **82/88**. These are static source and diagram
checks, not provisioning, invocation, protection effectiveness or runtime proof.
