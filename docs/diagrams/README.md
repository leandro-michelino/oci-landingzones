# Architecture Diagram Sources

`oci-3tier-adb.drawio` is an editable conceptual three-tier architecture with web and app VMs, a public load balancer, and an Autonomous Database private endpoint. It is not a deployment-evidence diagram for a specific Terraform blueprint. The application reaches regional Oracle services through the Service Gateway; database sessions use the separate private endpoint path. Customer-specific NSGs, routes, ports, DNS, availability placement, and workload resources require separate configuration and validation. The XML was parsed successfully during the October 14, 2026 repository review; rendered layout and packet flows were not tested.


## Networking Draw.io Diagrams

The first fifteen Networking catalog entries have editable draw.io sources and PNG
previews beside their architecture documentation. The PNGs replace the previous
ASCII architecture blocks in those fifteen files. Later catalog entries retain their
existing diagrams until their batch is completed.

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

From the repository root, regenerate a batch and export its PNGs with:

```bash
python3 scripts/diagrams/networking-batch-01.py --render
python3 scripts/diagrams/networking-batch-02.py --render
python3 scripts/diagrams/networking-batch-03.py --render
```

Each generator runs the skill's layout checks and stops on warnings before
exporting. The output uses source-default CIDRs, marks unspecified deployment
placement, and distinguishes optional disabled services from the network
foundation. It does not discover live OCI resources.

On October 28, 2026, all fifteen sources passed the skill's layout checks; all fifteen
PNGs were exported through draw.io and visually reviewed. Repository contracts,
Markdown links and diff whitespace checks passed. This documentation-only work
performed no Terraform apply, provider revalidation, connectivity, failover or
cost test and does not change historical deployment validation dates.
