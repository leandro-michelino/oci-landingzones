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
