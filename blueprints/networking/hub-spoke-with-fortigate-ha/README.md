# Hub-Spoke With FortiGate HA

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this page as the operator guide for
`blueprints/networking/hub-spoke-with-fortigate-ha`. It tells you what the
blueprint builds, which inputs deserve a real review, how to run Terraform or the local
Ansible wrappers, and where to find the detailed Architecture design.

## At A Glance

| Item | Details |
| --- | --- |
| Folder | `blueprints/networking/hub-spoke-with-fortigate-ha` |
| Best fit | Deploys a Fortinet FortiGate active-passive HA pair into a hub-spoke network for customer-managed inspection. |
| Terraform shape | `network`, `oci_core_instance.fortigate`, `oci_core_vnic_attachment.fortigate_interface`, optional floating private IPs and IAM failover policy |
| Inputs to settle first | `compartment_ocid`, `fortigate_image_id`, `fortigate_nodes`, `fortigate_floating_ips`, `enable_fortigate_instance_principal_policy` |
| Outputs to hand off | `blueprint_name`, `name_prefix`, `resource_ids`, `hub_vcn_id`, `drg_id`, `hub_subnet_ids`, `fortigate_instance_ids`, plus 4 more |
| Local runner | `terraform plan` for quick iteration; `ansible/plan.yml` and guarded `ansible/apply.yml` for the repo-standard flow. |

## Deployment Purpose

Deploys a Fortinet FortiGate active-passive HA pair into a hub-spoke network for
customer-managed inspection.

## When To Use This Deployment

- FortiGate is the approved firewall or transit inspection appliance.
- The landing zone needs a repeatable HA pair with management, untrust, trust, and HA sync interfaces.
- Security teams want OCI private IP failover permissions managed alongside the network baseline.

## What This Deploys

This folder is self-contained at the deployment level: Terraform composes the OCI resource
graph, while the local Ansible files provide the same plan/apply/destroy rhythm everywhere
in the repo.

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Module | `network` | `blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns @ v0.2.0` |
| Resource | `oci_core_instance.fortigate` | FortiGate active and standby compute nodes. |
| Resource | `oci_core_vnic_attachment.fortigate_interface` | Secondary untrust, trust, and HA sync VNICs. |
| Resource | `oci_core_private_ip.fortigate_floating` | Optional reserved private IPs for failover and route targets. |
| Resource | `oci_identity_dynamic_group.fortigate` | Optional instance-principal dynamic group for FortiGate HA automation. |
| Resource | `oci_identity_policy.fortigate` | Optional OCI policy for Fortinet SDN connector failover automation. |

The exact OCI behavior is controlled by `variables.tf` and the values supplied in your local
ignored `terraform.tfvars` file.

## Folder Contract

```text
blueprints/networking/hub-spoke-with-fortigate-ha/
|-- README.md                  Operator guide for this deployment
|-- architecture/README.md     Detailed Architecture for this deployment
|-- main.tf                    Terraform modules, resources, and data sources
|-- variables.tf               Input contract
|-- outputs.tf                 Deployment hand-off values
|-- providers.tf               OCI provider configuration
|-- versions.tf                Terraform and provider constraints
|-- terraform.tfvars.example   Example input shape
`-- ansible/
    |-- plan.yml               Local init, validate, and plan
    |-- apply.yml              Guarded init, validate, plan, and apply
    `-- destroy.yml            Guarded destroy
```

## Inputs To Decide

Start with `terraform.tfvars.example`, then create a local ignored `terraform.tfvars` with
real OCIDs, CIDRs, names, recipients, and enable flags.

### Base Tenancy And Naming

| Input | What To Decide |
| --- | --- |
| `tenancy_ocid` | OCI tenancy OCID. |
| `current_user_ocid` | OCI user OCID used for local execution or bootstrap. |
| `region` | OCI region name. |
| `home_region` | OCI tenancy home region. |
| `oci_config_profile` | Optional OCI CLI config profile for local execution. |
| `org` | Short organization prefix used in names. |
| `environment` | Deployment environment name. |
| `region_key` | Short OCI region key used in resource names. |
| `defined_tags` | Defined tags applied to resources. |
| `freeform_tags` | Freeform tags applied to resources. |

### Deployment-Specific Decisions

| Input | What To Decide |
| --- | --- |
| `compartment_ocid` | Compartment OCID where networking resources are deployed. Defaults to tenancy_ocid for simple tests. |
| `hub_subnets` | Hub subnet map for management, untrust, trust, and HA sync interfaces. |
| `fortigate_image_id` | FortiGate marketplace or custom image OCID after subscription terms are accepted. |
| `fortigate_nodes` | Two FortiGate nodes with AD, shape, optional image override, bootstrap data, and interface settings. |
| `fortigate_interface_subnet_keys` | Default hub subnet keys used by management, untrust, trust, and HA sync interfaces. |
| `fortigate_floating_ips` | Secondary or reserved private IPs used by FortiGate HA failover and route-table next-hop designs. Set `active_node_key` and `interface_name` to attach the IP initially to an active FortiGate VNIC. |
| `additional_fortigate_policy_statements` | Extra OCI IAM statements if the customer failover design needs more than the Fortinet-documented SDN connector permissions. |

### Enable Flags And Switches

| Input | What To Decide |
| --- | --- |
| `enable_fortigate_ha` | Create the FortiGate active-passive HA pair. Disabled by default. |
| `enable_fortigate_floating_ips` | Create reserved private IPs for failover. Disabled by default. |
| `enable_fortigate_instance_principal_policy` | Create OCI dynamic group and policy for HA failover automation. Disabled by default. |

## Outputs And Hand-Off

These outputs are the deployment contract for downstream blueprints, runbooks, customer
notes, or manual hand-off. If an output name changes, update dependent docs and consumers in
the same change.

| Output | Hand-Off Meaning |
| --- | --- |
| `blueprint_name` | Blueprint identifier. |
| `name_prefix` | Standard OCI naming prefix for resources created by this blueprint. |
| `resource_ids` | Map of resource identifiers created by this blueprint. |
| `hub_vcn_id` | Hub VCN OCID. |
| `drg_id` | DRG OCID. |
| `hub_subnet_ids` | Hub subnet OCIDs keyed by role. |
| `spoke_vcn_ids` | Spoke VCN OCIDs keyed by spoke name. |
| `fortigate_instance_ids` | FortiGate compute instance OCIDs. |
| `fortigate_mgmt_private_ips` | FortiGate management private IPs keyed by node. |
| `fortigate_secondary_vnic_ids` | Secondary FortiGate VNIC OCIDs keyed by node-interface. |
| `fortigate_floating_private_ip_ids` | Reserved FortiGate floating private IP OCIDs. |

## Terraform And Ansible Workflow

Use direct Terraform when you are iterating locally:

```bash
cd blueprints/networking/hub-spoke-with-fortigate-ha
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform validate
terraform plan
```

Use the local Ansible wrapper when you want the same runner shape used across the repo:

```bash
cd blueprints/networking/hub-spoke-with-fortigate-ha
ansible-playbook -i localhost, ansible/plan.yml
CONFIRM_APPLY=true ansible-playbook -i localhost, ansible/apply.yml
CONFIRM_DESTROY=true ansible-playbook -i localhost, ansible/destroy.yml
```

`apply.yml` and `destroy.yml` are intentionally guarded. Keep that behavior for
customer-facing or shared environments.

## Deployment Order

1. Confirm FortiGate image, licensing, subscription terms, and support ownership.
2. Review CIDRs, hub subnets, spoke routes, and required inspection paths.
3. Populate `terraform.tfvars` with customer-specific FortiGate node, interface, and floating IP values.
4. Run plan and review network exposure, IAM statements, and route target outputs.
5. Apply, complete FortiGate bootstrap or FortiManager onboarding, then update route tables to the approved floating private IP targets.

## Architecture

The full detailed Architecture is local to this deployment:

```text
architecture/README.md
```

That file documents the ownership boundary, Terraform components, request flow, state and
output contract, operational boundaries, review checklist, and the expected Terraform +
Ansible output at the end of the deployment.

## Review Before Apply

- Confirm FortiGate marketplace terms and licensing are accepted before enabling the nodes.
- Confirm management access path, bootstrap ownership, and FortiManager onboarding if used.
- Confirm the FortiOS version supports IAM role based OCI SDN connector authentication before enabling the optional instance-principal policy.
- Confirm untrust, trust, and HA sync subnets are correct for the customer route design.
- Confirm same-AD or multi-AD/regional-subnet topology choices before relying on floating private IP failover.
- Confirm floating private IP ownership and failover behavior before steering production traffic; Terraform ignores post-deploy `vnic_id` drift so FortiGate HA can move secondary IPs after deployment.
- Confirm optional IAM statements are scoped to the intended compartment.
- Confirm no generated Terraform files, state files, plans, or local tfvars are committed.

## Validation

From the repository root:

```bash
./scripts/validate-all.sh
```

The validator checks Terraform formatting, required deployment README files, required
architecture README sections, `terraform init -backend=false`, `terraform validate`, root
Ansible syntax, blueprint-local Ansible syntax, optional scanners when installed, and
cleanup of generated Terraform artifacts.
