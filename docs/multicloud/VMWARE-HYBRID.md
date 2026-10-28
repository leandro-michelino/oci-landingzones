# VMware Hybrid Blueprint Runbook

The three new patterns use the pinned [OCVS foundation](../../blueprints/industry/ocvs/)
and explicitly separate OCI creation, Azure creation and externally managed
VMware components. See [generic workloads](VMWARE-WORKLOADS.md) for guest-level
examples and acceptance. No live resources or credentials are needed for the
local schema/mock/compiler checks.

## Topologies And Ownership

| Pattern | OCI-created when enabled | Azure-created when enabled | Existing/external |
| --- | --- | --- | --- |
| [On-premises + OCVS](../../blueprints/industry/ocvs-onprem-hcx/) | Optional SDDC, DRG, VCN attachment and onprem partner VC | None | Prepared OCVS networks, onprem VMware/HCX/edge, carrier transport |
| [AVS + OCVS](../../blueprints/industry/azure-avs-ocvs-interconnect/) | Optional SDDC, DRG, attachment and azure partner VC | Optional AVS private cloud, HCX add-on, Oracle-facing ER, authorization and AVS Global Reach attachment | Prepared OCI network, AVS managed circuit, confirmed AVS/Oracle transit eligibility |
| [Triangle](../../blueprints/industry/azure-avs-ocvs-onprem-triangle/) | Optional SDDC, DRG, attachment and separate azure/onprem partner VCs | Same Azure resources plus a separate AVS Global Reach attachment for onprem | Onprem carrier ER circuit/authorization, independent OCI carrier link, prepared network and VMware/HCX components |

All creation flags default false. Resource declaration pages retain conditional
resources even when disabled. Service-managed VMware components and AVS's
managed ExpressRoute circuit are not duplicated as customer-owned resources.
Onprem vCenter/ESXi/NSX, HCX Connector, IX/NE/optional optimization appliances,
edge/firewall, DNS/NTP, guest workloads and backup tooling are external.

## Connectivity Limits

Microsoft documents that an ExpressRoute VNet gateway cannot transit traffic
between two connected circuits; AVS uses its own managed circuit and requires
an appropriate [circuit connectivity design](https://learn.microsoft.com/en-us/azure/azure-vmware/architecture-networking).
The Azure companions model a conditional AVS Global Reach resource attached to
the Oracle-facing circuit. This exact product pairing is a proposal, not a
vendor-certified design. Keep `avsTransitVerified=false` until Microsoft and
Oracle confirm the chosen circuit/provider/region eligibility. Do not replace
that missing confirmation with a diagram line or a successful compiler result.

Oracle [documents](https://docs.oracle.com/en-us/iaas/Content/multicloud/interconnect-azure.htm)
that its Interconnect does not support onprem traffic transiting a VCN to a
VNet or a VNet to a VCN. The triangle therefore has independent onprem–OCI and
onprem–AVS connections. Do not use Oracle Interconnect as an onprem transit
shortcut, and audit DRG/NSX/ExpressRoute prefix propagation before enabling it.
Regions, quotas, physical redundancy, bandwidth, billing and eligible circuit
features are operator decisions; the project does not select a real region pair.

## Ordered Setup

1. Obtain written support confirmation for the proposed AVS/Oracle attachment; review regional Global Reach availability and required entitlements.
2. Prepare an address plan covering management, workloads, NSX/HCX, provisioning and all BGP networks; remove routed overlap before proceeding.
3. Prepare dedicated OCVS subnets/VLANs and explicit AD, shape, bundle, commitment, BYOL and public SSH key choices.
4. Enable optional OCVS creation with HCX only after the approved plan; preserve existing site ownership when using existing SDDCs.
5. Deploy the Azure AVS/circuit foundation separately into a dedicated resource group. Retrieve service keys privately rather than committing or logging them.
6. Supply OCI `circuits.azure` with its partner service key and two reviewed /30 BGP pairs; match bandwidth and complete Oracle partner provisioning/private peering.
7. For onprem, complete the independent carrier FastConnect leg and provide the carrier's approved service/BGP configuration under `circuits.onprem`.
8. In the triangle, obtain the separate onprem carrier ExpressRoute ID and authorization; enable its AVS Global Reach attachment independently.
9. Verify circuit status, every BGP session, learned routes, import/export filters, NSX/gateway routes, scoped rules, DNS/NTP, MTU and forward/return traffic.
10. Install/register HCX Connector, activate cloud HCX, create per-site profiles and one service mesh per supported pair; verify appliances/tunnels.
11. Deploy or migrate the generic VM stack, test transactions, backup/restore and rollback, then conduct a controlled application cutover.

No circuit source key, authorization key, private key or administrator password
is committed or emitted through the new outputs. Provider resources and saved
plans may retain credentials internally; protect deployment state and avoid
publishing saved plans or verbose logs.

## HCX Readiness And Workload Acceptance

Follow the chosen vendor version's [OCVS HCX prerequisites](https://docs.oracle.com/en-us/iaas/Content/VMware/Concepts/ocvsoverview.htm)
and [AVS HCX workflow](https://learn.microsoft.com/en-us/azure/azure-vmware/configure-vmware-hcx).
Review all management, uplink, vMotion, replication and optional network-extension
flows against the current port matrix instead of assuming a universal port list.
Ensure activation/update egress is available through an explicitly configured
path; this blueprint creates no NAT gateway or default Internet route.
Pairwise HCX capabilities, licensing and interoperability need separate review.

Connectivity, appliance health, application behavior and database consistency
are distinct acceptance gates. No HCX migration, live session, failover,
application request, backup or restore has been performed in this work.

## Teardown

Remove test workloads and migration/Global Reach dependencies before destroying
circuits or SDDCs. Never delete shared prepared networks through these roots.
The shared Azure destroy runner deletes the entire selected resource group;
use it only for a dedicated, inventoried deployment group. Existing carrier
circuits, external HCX configuration and license allocations retain separate
ownership and teardown procedures. No real cloud deployment occurred here,
so no cloud cleanup was required or claimed.
