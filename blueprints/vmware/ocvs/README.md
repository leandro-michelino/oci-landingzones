# Oracle Cloud VMware Solution (OCVS)

Create an optional OCVS SDDC with one initial MANAGEMENT cluster and one or more
explicitly configured WORKLOAD clusters on an existing, prepared OCVS network. This version supports dense/vSAN host shapes only.

| Item | Details |
| --- | --- |
| Best fit | Dense/vSAN OCVS management and workload clusters on prepared private networks. |
| Default result | No OCI resources or network lookups; only a local validation guard. |
| Creates when enabled | One SDDC resource containing MANAGEMENT and explicit WORKLOAD clusters, 3-64 ESXi hosts per cluster and its managed VMware control plane. |
| Reuses | Existing VCN, private provisioning subnets, eight baseline VLANs per cluster and optional Replication-Net/HCX VLANs. |
| Explicit selections | Region, AD, VMware bundle, supported dense shape/OCPUs, RSA public SSH key, commitment and applicable BYOL allocation. |
| Validation | Local schema and mocked plans only; see [evidence](../../../docs/OCVS-20261028.md). |

See the [architecture and PNG](architecture/README.md) and the editable
[draw.io document](architecture/architecture.drawio).

## Scope

`enable_sddc=false`, `inspect_existing_network=false` and `costs_approved=false`
by default. A source/diagram review does not authorize a billed deployment.
This blueprint does not create VCNs, subnets, VLANs, NSGs, routes, gateways,
circuits, DNS records, IAM grants, license allocations or VMware guest workloads.
It does not modify or adopt the supplied existing network resources.

Every cluster in this variant requires 3-64 hosts and rejects
single-host and multi-AD configuration. Standard shapes with Block Volume
storage, clusters added after SDDC creation, later host expansion and migration automation
are outside this version. Existing VCF BYOL allocation can be passed through;
license applicability and entitlement must be reviewed separately.

## Existing Network Contract

All inspected resources must belong to the explicit workload compartment and
selected VCN. Every provisioning subnet must prohibit public IPs. AD-specific
subnet/VLAN resources must match the selected cluster AD; regional ones are
accepted. AD matching is enforced before SDDC creation; a network-only
inspection does not require an AD. Every cluster must use a dedicated provisioning subnet. All selected VLAN IDs
must be distinct across clusters.

| Input | Role |
| --- | --- |
| `vcn_id` | Prepared OCVS VCN. |
| `provisioning_subnet_id` | Private ESXi provisioning subnet. |
| `vsphere_vlan_id` | VMware management network. |
| `vmotion_vlan_id` | vMotion network. |
| `vsan_vlan_id` | Dense-host vSAN network. |
| `nsx_vtep_vlan_id` | NSX host VTEP network. |
| `nsx_edge_vtep_vlan_id` | NSX Edge VTEP network. |
| `nsx_edge_uplink1vlan_id` | First NSX Edge uplink. |
| `nsx_edge_uplink2vlan_id` | Second NSX Edge uplink. |
| `provisioning_vlan_id` | Provisioning-Net network. |
| `replication_vlan_id` | Supply when required by the selected bundle, including the VMware 7.x network model. |
| `hcx_vlan_id` | Required when `enable_hcx=true`. |

The lookups verify resource metadata only. They do not audit all security rules,
routing, CIDR overlap, MTU, DNS, service permissions or transport reachability.
Prepare these against Oracle's [SDDC VLAN guidance](https://docs.oracle.com/en-us/iaas/Content/VMware/Tasks/vlan-create.htm)
and [SDDC creation prerequisites](https://docs.oracle.com/en-us/iaas/Content/VMware/Tasks/ocvssettingupsddc.htm).
HCX also requires external routing, licensing and remote-site configuration.

## Configuration And Review

1. Copy `terraform.tfvars.example` to an ignored local configuration file.
2. Set the approved compartment and region; keep `oci_config_profile="DEFAULT"`.
3. Leave all creation/inspection flags false for a local configuration review.
4. For an explicitly authorized read-only inspection, supply all network IDs
   and set only `inspect_existing_network=true`; SDDC creation remains disabled.
5. Before any separately approved deployment, confirm regional shape/version
   availability, capacity, commercial commitment and licensing. Supply the exact
   AD, supported VMware bundle, dense shape, RSA public SSH key and commitment.
6. Review the complete plan with `enable_sddc=true` and `costs_approved=true`.
   The approval variable is an operator acknowledgement, not a cost estimate or
   authorization granted by this document. Use the guarded deployment runner.

Configure workload clusters explicitly through `workload_clusters`. Its required
network role keys are `vsphere`, `vmotion`, `vsan`, `nsx_vtep`,
`nsx_edge_vtep`, `nsx_edge_uplink1`, `nsx_edge_uplink2`, and `provisioning`,
plus optional `replication`. Global network inputs describe MANAGEMENT only.
Cluster AD, dense shape/OCPUs, VMware bundle and commitment are shared; a
workload cluster can override the VCF BYOL allocation and initial workload CIDR.
At least one WORKLOAD entry is required for SDDC creation; inspection can cover
only the management network before that entry is supplied.

Generated SDDC names use `org-environment-region_key-sddc` and must fit 16
characters. Cluster names must fit 22. Shorten the naming segments or supply
valid display-name overrides; names are never silently truncated.

## Local Validation

```bash
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
terraform test
ansible-playbook -i localhost, ansible/plan.yml --syntax-check
ansible-playbook -i localhost, ansible/apply.yml --syntax-check
ansible-playbook -i localhost, ansible/destroy.yml --syntax-check
```

Tests use a mocked OCI provider, fake network IDs, fake VMware bundle/shape and
fake commitment values. These are test fixtures, not deployable examples or
regional availability evidence. No SDDC was provisioned in this review.

## Operations And Credentials

Only resource IDs and management FQDNs are exposed as outputs. Password outputs
and credential-retrieval data sources are deliberately absent. The provider's
SDDC resource can retain initial credentials in deployment state even without
explicit password outputs. Protect deployment state and saved plans using an
encrypted access-controlled backend; never commit or share them.

vCenter/NSX administration, guest VMs, HCX pairing/service meshes, source-site
appliances, migration waves, workload DNS, backup, DR and monitoring integrations
are separate operational work. An uplink VLAN ID alone creates no private
connection to on-premises, another cloud or another VCN.

Before changing immutable SDDC properties, inspect replacement/destruction
carefully. Commitment and deletion implications must be reviewed before any
real lifecycle operation. No live lifecycle or cleanup claim is made here.

## Technical Reference

The implementation uses provider `oracle/oci = 9.11.0` and the nested
`initial_configuration.initial_cluster_configurations.network_configuration`
model verified against its locally installed schema. The
[Oracle SDDC resource reference](https://docs.oracle.com/en-us/iaas/tools/terraform-provider-oci/latest/docs/r/ocvp_sddc.html)
is a current upstream reference; the pinned schema controls this implementation.

## Generic Workload Proposals

A three-tier application on Linux VMs can place NGINX, a Spring Boot API and
PostgreSQL inside the OCVS WORKLOAD cluster. Other candidates include internal
portals, document services and licensed legacy application VMs. See the
[placement and acceptance guide](../../../docs/multicloud/VMWARE-WORKLOADS.md).
No guest/application is created or claimed tested by this blueprint. Size and
license each guest, separate NSX tiers, configure identity/TLS/secrets and prove
transactions, backups and restore before production use.

## Repository Location

This blueprint belongs to the VMware platform family under `blueprints/vmware/`.
The folder move preserves resource addresses, naming/tag values, provider
configuration and cost defaults. References pinned to older commits keep their
historical module source path intentionally; those commits predate this move.
Existing users must transfer their protected deployment state and private inputs
to the new working directory or keep using the old pinned checkout. Do not
apply from a fresh directory against an existing deployment without its state.
