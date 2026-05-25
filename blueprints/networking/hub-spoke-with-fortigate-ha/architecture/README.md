# Hub-Spoke FortiGate HA Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This page is the deployment architecture for `blueprints/networking/hub-spoke-with-fortigate-ha`. It is intentionally Architecture-first so it
is easy to review in GitHub, terminals, pull requests, runbooks, and customer notes without a
diagramming tool.

## Deployment Purpose

Deploys a Fortinet FortiGate active-passive HA pair into a hub-spoke network for customer-managed inspection.

## Architecture At A Glance

| Item | Details |
| --- | --- |
| Boundary | `blueprints/networking/hub-spoke-with-fortigate-ha` owns this deployment folder and its Terraform + Ansible runners. |
| Purpose | Deploys a Fortinet FortiGate active-passive HA pair into a hub-spoke network for customer-managed inspection. |
| Terraform components | `network`, `oci_core_instance.fortigate`, `oci_core_vnic_attachment.fortigate_interface`, optional floating private IPs and IAM failover policy |
| Primary architecture view | The Architecture diagram below shows the OCI components, dependency order, and traffic flow for this exact deployment. |


## Architecture

```text
+----------------------------------------------------------------------------------------------------------+
| Hub-Spoke With FortiGate HA                                                                              |
+----------------------------------------------------------------------------------------------------------+
| Legend: [managed resource]  (supplied/external)  {trust boundary}  -> traffic/control flow               |
|                                                                                                          |
| [Operator / CI] -> [blueprint-local Ansible runner] -> [Terraform OCI provider]                          |
|         |                    |                         |                                                 |
|         | validates docs      | init/validate/plan      | OCI API calls                                  |
|         v                    v                         v                                                 |
| {Network compartment / selected region}                                                                  |
|         |                                                                                                |
|         v                                                                                                |
| [Hub VCN]                                                                                                |
|         |-- [dmz subnet]   -> FortiGate untrust VNICs, optional public edge, route target candidates     |
|         |-- [mgmt subnet]  -> FortiGate management VNICs and administrative access path                  |
|         |-- [trust subnet] -> FortiGate trust VNICs, spoke or DRG transit inspection path                |
|         |-- [ha subnet]    -> FortiGate HA sync VNICs                                                    |
|         `-- [gateway set]  -> IGW / NAT / SGW according to route design                                  |
|                  |                                                                                       |
|                  v                                                                                       |
| [DRG] <-> [hub attachment] <-> [spoke attachments]                                                       |
|   |             |                    |                                                                   |
|   |             |                    +--> [spoke VCN A] web -> app -> db                                 |
|   |             |                    +--> [spoke VCN B] web -> app -> db                                 |
|   |             |                    `--> [future spoke] same attachment contract                        |
|   |                                                                                                      |
|   `--> [FortiGate active node] <---- HA sync ----> [FortiGate standby node]                              |
|             |                                  |                                                         |
|             | optional instance-principal IAM | optional floating private IPs                            |
|             v                                  v                                                         |
|      [OCI private IP failover permissions] -> [stable route-table next-hop private IPs]                  |
|                                                                                                          |
| Pattern extension: route tables decide which north-south or east-west paths use FortiGate inspection.    |
| North-south: internet, FastConnect, VPN, or service traffic can enter the hub and pass through FortiGate.|
| East-west: spoke-to-spoke traffic can centralize through the DRG and trust-side FortiGate route targets. |
| Hand-off: VCN IDs, DRG IDs, subnet maps, FortiGate instance IDs, secondary VNICs, and floating IP IDs.   |
+----------------------------------------------------------------------------------------------------------+
```

## Terraform Components

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Module | `network` | `blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns @ v0.2.0` |
| Resource | `oci_core_instance.fortigate` | FortiGate active and standby compute nodes with management as the primary VNIC. |
| Resource | `oci_core_vnic_attachment.fortigate_interface` | Secondary untrust, trust, and HA sync VNICs attached to each FortiGate node. |
| Resource | `oci_core_private_ip.fortigate_floating` | Optional secondary or reserved private IPs used by failover automation and route-table next hops. |
| Resource | `oci_identity_dynamic_group.fortigate` | Optional instance-principal dynamic group matching the FortiGate nodes. |
| Resource | `oci_identity_policy.fortigate` | Optional tenancy policy for Fortinet-documented OCI SDN connector failover permissions. |

## Request And Deployment Flow

- Operator reviews FortiGate licensing, image source, interface placement, bootstrap method, and failover ownership.
- Terraform creates the hub-spoke network first, then creates the FortiGate compute nodes with management VNICs.
- Terraform attaches secondary untrust, trust, and HA sync VNICs after each node exists.
- Optional reserved private IPs are created for route-table next hops and FortiGate HA failover.
- Optional IAM resources allow the FortiGate nodes to use instance principals for private IP failover automation.
- Traffic follows the diagrammed route path only after the operator updates the relevant route tables and completes FortiGate policy configuration.

## Traffic And Trust Boundaries

- Control plane traffic is local operator or CI authentication into the OCI provider and the Ansible Terraform runner.
- FortiGate management traffic belongs on the management subnet and should be reachable only from approved administrative paths.
- Untrust traffic belongs on the DMZ or edge-facing subnet and should be limited by the customer security-list or NSG model.
- Trust traffic belongs on the transit or inspected-side subnet used by DRG and spoke routing decisions.
- HA sync traffic belongs on a dedicated private subnet or an equivalent isolated path approved by the network team.
- Secrets, OCIDs, customer CIDRs, endpoint URLs, and contact data belong in ignored local tfvars or a secure pipeline variable store, not in committed files.

## Detailed Architecture Notes

These notes expand the diagram with the design details that usually matter during review, plan, and hand-off.

- The FortiGate management interface is the primary VNIC because OCI Compute instances are created with one primary VNIC and then receive secondary interface attachments.
- Secondary VNICs use `skip_source_dest_check = true` by default so the appliance can forward inspected traffic.
- The default hub subnets separate `dmz`, `mgmt`, `trust`, and `ha` roles; customers can override the subnet map and interface subnet keys.
- Floating private IPs can be created as reserved private IPs or initially attached as secondary IPs on the active FortiGate VNIC; Terraform ignores `vnic_id` drift so FortiGate HA can move them during failover.
- The optional dynamic group matches the created FortiGate instance OCIDs and the optional policy follows the Fortinet-documented OCI SDN connector IAM role permissions for read access and IP/VNIC failover automation.
- The blueprint does not hard-code FortiOS firewall rules, SDN connector settings, FortiManager registration, license activation, or production route steering; those remain customer or security-team owned steps.
- Route symmetry must be reviewed carefully when steering spoke-to-spoke, internet, VPN, FastConnect, service gateway, or NAT paths through FortiGate.

## Operational Boundaries

- Keep customer-specific OCIDs, CIDRs, DNS names, endpoints, contacts, and secrets in ignored local tfvars or approved pipeline variables.
- Accept marketplace terms and confirm licensing outside Terraform before enabling FortiGate nodes.
- Run plan from this blueprint folder so provider files and local Ansible runners resolve predictably.
- Treat apply and destroy as approval-gated operations; use the guarded Ansible playbooks or a reviewed Terraform workflow.
- Re-check route exposure, IAM scope, compartment boundaries, tags, and output hand-offs whenever inputs change.
- Validate FortiGate HA failover in a non-production routing path before production traffic depends on the pair.

## Review Checklist

- Confirm the diagram matches `main.tf`: `network`, `oci_core_instance.fortigate`, `oci_core_vnic_attachment.fortigate_interface`, optional private IPs, and optional IAM resources.
- Confirm the described traffic path is the path you want in OCI before apply.
- Confirm public exposure, private endpoint access, DNS behavior, DRG routing, and inspection points are intentional where present.
- Confirm FortiGate image, license model, support ownership, bootstrap method, and FortiManager onboarding are approved.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.
