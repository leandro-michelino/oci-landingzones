# Hub-Spoke Transit Routing NVA HA Architecture

This is the deployment architecture for `blueprints/networking/hub-spoke-with-transit-routing-nva-ha`. The PNG provides a GitHub-readable preview; the draw.io source preserves editable shapes, official OCI icons and connectors.

## Deployment Purpose

Adds highly available network virtual appliances and route target private IPs to a hub-spoke transit network.

## Architecture At A Glance

| Item | Details |
| --- | --- |
| Boundary | `blueprints/networking/hub-spoke-with-transit-routing-nva-ha` owns this deployment folder and its Terraform + Ansible runners. |
| Purpose | Adds highly available network virtual appliances and route target private IPs to a hub-spoke transit network. |
| Terraform components | `network`, `nva_ha` |
| Primary architecture view | The diagram shows the default foundation and an explicit extension detail panel, with conditional resources and scope limits marked. |


## Architecture

![Hub-Spoke Transit Routing NVA HA Architecture](architecture.png)

[Editable draw.io source](architecture.drawio). Keep the PNG preview aligned with
the editable source after every diagram change.

Generated with the [oci-architecture-diagrams skill](https://github.com/leandro-michelino/oci-architecture-diagrams)
and Oracle OCI Architecture Diagram Toolkit v24.2. From the repository root,
regenerate with `python3 scripts/diagrams/networking-batch-03.py --render`.
Install the skill and its official toolkit first; the toolkit is not redistributed here.

The foundation view uses source-default CIDRs and leaves deployment region and
compartment as operator inputs. The extension detail panel distinguishes default
resources, disabled conditional resources, associations and missing prerequisites.
It does not assert verified packet flow, HA, failover or policy enforcement.

Diagram documentation reviewed on 2026-10-28 against the blueprint and referenced
modules. No OCI resources were provisioned and no Terraform/provider validation
date was changed for this documentation update.

## Resource Detail And Coverage

Reviewed against the updated diagram standard on October 28, 2026. The main
draw.io document contains the topology overview plus every resource-detail and
existing-resource-reference page below. Source declarations include disabled and
collection-based resources from root Terraform, recursively pinned modules and
companion cloud templates. Counts are declarations, not resolved instance counts.

OCI uses Oracle Toolkit icons; Azure and AWS use their respective draw.io icons.
Types without a specific mapped icon retain their exact name and type in a box.
No GCP declarations were found in this fixed 39-blueprint scope.

| Detail page | Declarations | PNG | Editable source |
| --- | --- | --- | --- |
| OCI resources | 18 | [PNG](oci-resources.png) | [draw.io](oci-resources.drawio) |
| OCI resources 2 | 2 | [PNG](oci-resources-02.png) | [draw.io](oci-resources-02.drawio) |

[Existing resources and override inputs](existing-resources.png) | [Editable reference page](existing-resources.drawio)

[Source inventory](resource-inventory.json) records exact declarations, full
creation expressions, module call-site gates/enablement inputs, pinned revisions,
source hashes and diagram node mappings. Identifier-input references are listed
separately from managed resources. Null/empty inputs do not prove an external
resource exists; collection schemas may contain additional resource identifiers.

The overview explains default enablement. Resource cards enumerate all declaration
branches and do not imply deployment, ownership adoption, packet flow, security
enforcement or recovery success. No historical Terraform validation date changed.

```bash
python3 scripts/diagrams/multicloud-resource-coverage.py --blueprint networking/hub-spoke-with-transit-routing-nva-ha --render
python3 scripts/diagrams/multicloud-resource-coverage.py --blueprint networking/hub-spoke-with-transit-routing-nva-ha --check
```

If regenerating the overview first, rebuild these detail pages afterward.
See [the fixed first-39 review](../../../../docs/diagrams/FIRST-39-REVIEW.md) and [provider icon sources](../../../../scripts/diagrams/assets/README.md).

## Terraform Components

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Module | `network` | `blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns @ d7938f4baef1aa512fc8dcee99a545ec17e0dab2` |
| Module | `nva_ha` | `modules/networking/net-appliance @ v0.2.0` |

## Request And Deployment Flow

- Operator reviews CIDRs, subnet maps, gateway flags, route targets, and inspection requirements.
- Terraform creates the network foundation first, then dependent attachments or network services declared in main.tf.
- Traffic follows the diagrammed route path, and outputs expose VCN, subnet, DRG, gateway, DNS, inspection, or policy IDs for the next deployment.

## Traffic And Trust Boundaries

- Control plane traffic is local operator or CI authentication into the OCI provider and the Ansible Terraform runner.
- Data plane traffic is the packet or service path shown in the Architecture diagram; if this deployment only creates identity or governance resources, the data plane is intentionally permission and signal flow instead of network packets.
- Trust boundaries are the tenancy, compartment, VCN, subnet, DRG, private endpoint, identity domain, or managed service edges shown in the diagram.
- Secrets, OCIDs, customer CIDRs, endpoint URLs, and contact data belong in ignored local tfvars or a secure pipeline variable store, not in committed files.

## Detailed Architecture Notes

- Current validation: The 2026-10-23 DEFAULT Sao Paulo plan includes only the hub/spoke network; NVA Compute and reserved route IPs are disabled by default, so HA remains untested. See [Networking review](../../../../docs/NETWORKING-REVIEW-20261023-61-70.md).

- Traffic arrows express intended topology. The default network contains one workload spoke and no application hosts. Routing, ingress permissions, DNS resolution, inspection, and failover need separate runtime acceptance tests.

- Preserve OCI provenance tags `Oracle-Tags.CreatedBy` and `Oracle-Tags.CreatedOn` in provider configuration; other defined tags remain managed.

- Deployment creates the declared network/service resources. DRG attachments alone do not prove hub-to-spoke reachability, centralized NAT, symmetric return routing, or inspected transit. Review VCN ingress routes, subnet routes, DRG route tables/distributions, and security rules before treating the diagram as an operational packet path.
- Multiple appliance instances and reserved route IPs do not configure an HA protocol, health-based failover, guest forwarding software, or route steering. Supply the appliance configuration and test failover separately.

These notes expand the diagram with the design details that usually matter during review, plan, and hand-off.

- The hub-spoke network is created first, then HA NVA instances and route target private IPs are created or referenced.
- Reserved route IPs provide stable next-hop targets that route tables can use during appliance failover.
- Traffic can be forced through NVAs for inspection or transit before returning to the DRG, hub, spoke, or edge destination.
- Appliance `licensing_configs` passes through OCI Compute license settings for eligible images, such as Windows BYOL. RHEL remains a bring-your-own-image/subscription workflow unless the selected marketplace image documents a different model.
- Review route symmetry, appliance HA behavior, health checks, and failover timing before steering production traffic.

## Operational Boundaries

- Keep customer-specific OCIDs, CIDRs, DNS names, endpoints, contacts, and secrets in ignored local tfvars or approved pipeline variables.
- Run plan from this blueprint folder so relative module paths, provider files, and local Ansible runners resolve predictably.
- Treat apply and destroy as approval-gated operations; use the guarded Ansible playbooks or a reviewed Terraform workflow.
- Re-check route exposure, IAM scope, compartment boundaries, tags, and output hand-offs whenever inputs change.

## Review Checklist

- Confirm the diagram matches `main.tf`: `network`, `nva_ha`.
- Confirm the described traffic path is the path you want in OCI before apply.
- Confirm public exposure, private endpoint access, DNS behavior, DRG routing, and inspection points are intentional where present.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.
