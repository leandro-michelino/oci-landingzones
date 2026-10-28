# Hub-Spoke Private DNS Split Horizon Architecture

This is the deployment architecture for `blueprints/networking/hub-spoke-with-private-dns-split-horizon`. The PNG provides a GitHub-readable preview; the draw.io source preserves editable shapes, official OCI icons and connectors.

## Deployment Purpose

Adds private DNS zones, a private view, and resolver attachments across the hub and spoke VCNs.

## Architecture At A Glance

| Item | Details |
| --- | --- |
| Boundary | `blueprints/networking/hub-spoke-with-private-dns-split-horizon` owns this deployment folder and its Terraform + Ansible runners. |
| Purpose | Adds private DNS zones, a private view, and resolver attachments across the hub and spoke VCNs. |
| Terraform components | `network`, `private_dns` |
| Primary architecture view | The diagram shows the default foundation and an explicit extension detail panel, with conditional resources and scope limits marked. |


## Architecture

![Hub-Spoke Private DNS Split Horizon Architecture](architecture.png)

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
| OCI resources 2 | 4 | [PNG](oci-resources-02.png) | [draw.io](oci-resources-02.drawio) |

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
python3 scripts/diagrams/multicloud-resource-coverage.py --blueprint networking/hub-spoke-with-private-dns-split-horizon --render
python3 scripts/diagrams/multicloud-resource-coverage.py --blueprint networking/hub-spoke-with-private-dns-split-horizon --check
```

If regenerating the overview first, rebuild these detail pages afterward.
See [the fixed first-39 review](../../../../docs/diagrams/FIRST-39-REVIEW.md) and [provider icon sources](../../../../scripts/diagrams/assets/README.md).

## Terraform Components

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Module | `network` | `blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns @ d7938f4baef1aa512fc8dcee99a545ec17e0dab2` |
| Module | `private_dns` | `modules/networking/dns @ v0.2.0` |

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

- Current validation: The 2026-10-23 DEFAULT Sao Paulo plan includes private DNS by default. The earlier lifecycle used reduced network-only scope; resolver and zone behavior still need a separate runtime test. See [Networking review](../../../../docs/NETWORKING-REVIEW-20261023-61-70.md).

- Traffic arrows express intended topology. The default network contains one workload spoke and no application hosts. Routing, ingress permissions, DNS resolution, inspection, and failover need separate runtime acceptance tests.

- Preserve OCI provenance tags `Oracle-Tags.CreatedBy` and `Oracle-Tags.CreatedOn` in provider configuration; other defined tags remain managed.

These notes expand the diagram with the design details that usually matter during review, plan, and hand-off.

- The hub-spoke network creates VCN resolvers first, then private DNS creates zones and a private view.
- attach_private_view_to_vcn_resolvers controls whether the view is associated with hub and spoke resolvers.
- Workloads resolve private names through their VCN resolver and receive answers from the attached private view.
- Review split-horizon records, zone ownership, resolver attachments, and any on-premises forwarding design before apply.

## Operational Boundaries

- Keep customer-specific OCIDs, CIDRs, DNS names, endpoints, contacts, and secrets in ignored local tfvars or approved pipeline variables.
- Run plan from this blueprint folder so relative module paths, provider files, and local Ansible runners resolve predictably.
- Treat apply and destroy as approval-gated operations; use the guarded Ansible playbooks or a reviewed Terraform workflow.
- Re-check route exposure, IAM scope, compartment boundaries, tags, and output hand-offs whenever inputs change.

## Review Checklist

- Confirm the diagram matches `main.tf`: `network`, `private_dns`.
- Confirm the described traffic path is the path you want in OCI before apply.
- Confirm public exposure, private endpoint access, DNS behavior, DRG routing, and inspection points are intentional where present.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.
