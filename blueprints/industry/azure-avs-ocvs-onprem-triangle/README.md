# Azure AVS, OCVS and On-Premises Triangle

Three independent private connectivity legs for staged VMware migration.

| Item | Details |
| --- | --- |
| Best fit | Three independent private connectivity legs for staged VMware migration. |
| Default result | Local guards/contracts only; no cloud creation or network lookup. |
| OCI creation | Optional OCVS SDDC, DRG, VCN attachment and partner FastConnect circuits. |
| Existing OCI inputs | Prepared VCN, dedicated per-cluster private subnet/VLAN sets and applicable BYOL references. |
| External VMware | vCenter, ESXi, NSX, guest VMs, HCX Connector, edge/firewall, DNS/NTP and activation egress. |
| Validation | Schema and mocked wrapper plans; no cloud or application test. See [evidence](../../../docs/VMWARE-HYBRID-20261028.md). |

[Architecture / PNG](architecture/README.md) · [Editable draw.io](architecture/architecture.drawio)

## Resource Ownership

The OCI composition pins the existing [OCVS blueprint](../ocvs/README.md) to
commit `94ad89026bbf2ddbda531976a500e6d2ee084c7f`. It retains dense/vSAN shapes,
one MANAGEMENT and one or more explicit WORKLOAD clusters, 3-64 hosts per
cluster, dedicated prepared network IDs and no guessed VMware version or term.
No guest VM, network segment, firewall rule, DNS record, IAM grant or HCX
site pairing is created. Existing networks are inspected only when requested;
transport enables those metadata checks before its DRG/attachment is useful.

`enable_sddc`, `enable_hcx`, `enable_transport`, `enable_circuits`,
`inspect_existing_network`, `costs_approved` and `connectivity_verified` default
false. Creating an SDDC in this HCX pattern requires HCX enabled, its existing
VLAN and the inherited OCVS inputs. Existing SDDCs can be used as externally
managed sites by keeping creation disabled and supplying their prepared networks.
The map `circuits` requires exactly `azure` and `onprem` when circuits are enabled.
Each entry supplies a real partner service OCID, service key, bandwidth and
applicable BGP inputs. Azure requires two distinct /30 BGP networks; no customer
cross-connect or redundant physical hardware is invented. Partner provisioning
and bandwidth matching remain operator steps.

## Generic Workload Examples

See [workloads](../../../docs/multicloud/VMWARE-WORKLOADS.md) and the local
[placement example](workloads.example.json). The main example is NGINX, a
Spring Boot API and PostgreSQL on guest VMs. It has no industry dependency.
These are design proposals: no guest, package, database, identity integration,
load balancer, backup agent or replication job is installed by this blueprint.
See the guide for placement, connection policy, migration waves, tests and
rollback. No active-active database or guaranteed RPO/RTO is assumed.

## Deployment Sequence

1. Select an eligible offering, region, quota, license/commitment and approved cost scope.
2. Prepare and review the OCVS VCN, per-cluster subnets/VLANs, routing, scoped firewall rules, DNS/NTP and activation/update egress.
3. Review the OCVS plan; optionally create its SDDC and HCX cloud-side component.
4. Enable the isolated DRG/attachment only after inspecting the existing networks.
5. Complete partner circuit provisioning, copy service keys through a secure local channel and enable the required circuit entries.
6. Verify BGP, learned/imported/exported routes, MTU, forward/return paths and every HCX management/uplink flow.
7. Configure source HCX Connector, site pairing, compute/network profiles and a separate service mesh per approved pair.
8. Deploy or migrate guest workloads; run application/database and restore/rollback acceptance before cutover.

Use the local `ansible/plan.yml`, `apply.yml` and `destroy.yml` with the shared
runner. Review the plan before apply. No apply, destroy or cloud discovery was
run to create this blueprint. The example tfvars are disabled and contain only
placeholders. Keep keys, credentials, deployment state and saved plans outside Git.

## Operational Boundaries

DRG system route tables/distributions are not customized here. Audit imported
and exported prefixes before enabling circuits, especially in the triangle.
Create or adjust NSX, VLAN/subnet route tables and firewalls in the separately
owned network configuration; this root deliberately does not adopt existing
route/security resources. A FastConnect attachment is not a complete packet path.
HCX network extension is optional per workload and does not configure routing,
database replication, application failover or consistent backups by itself.

## References

- [OCVS service and HCX prerequisites](https://docs.oracle.com/en-us/iaas/Content/VMware/Concepts/ocvsoverview.htm)
- [Oracle Interconnect for Azure, support boundaries and setup](https://docs.oracle.com/en-us/iaas/Content/multicloud/interconnect-azure.htm)
- [AVS networking and circuit transit](https://learn.microsoft.com/en-us/azure/azure-vmware/architecture-networking)
- [VMware hybrid setup and acceptance runbook](../../../docs/multicloud/VMWARE-HYBRID.md)

## Azure Companion

[Azure template and workflow](azure/README.md) creates optional AVS private cloud,
HCX add-on, Oracle-facing ExpressRoute circuit, authorization and AVS Global
Reach attachment. The triangle also includes an AVS attachment to an existing,
separate on-premises carrier ExpressRoute circuit. Azure deploys separately.
The AVS managed ExpressRoute circuit belongs to AVS, not a second customer-
provisioned circuit. No VNet/gateway is needed or created for this chosen Global
Reach variant; adding two circuits to a VNet gateway would not provide transit.

The AVS-to-Oracle Global Reach use is a proposed integration gated by
`avsTransitVerified`. The cited product documents establish the component
capabilities but do not certify this exact AVS/Oracle circuit pairing. Obtain
vendor confirmation for the selected offering and region before enabling it.
This is not an assertion of supported or working AVS-to-OCVS transit.

The three legs are independent: on-premises–OCI partner FastConnect;
OCI–Azure Oracle Interconnect (FastConnect/ExpressRoute plus approved AVS
attachment); on-premises–AVS through its own carrier ExpressRoute and Global
Reach. Oracle Interconnect does not permit using one cloud to transit an
on-premises connection into the other cloud. Do not configure that shortcut.
Pair HCX per supported site pair; a service mesh is not a three-site object.
