# GCP and OCI Hybrid Network Backbone Architecture

## Deployment Purpose

Private dedicated connectivity plus an independently routed HA VPN backup.
Source-bounded configuration, not observed cloud topology.

## Architecture At A Glance

| Scope | Description |
| --- | --- |
| OCI | Root module/resource declarations in the explicit workload compartment. |
| GCP | Separately executed companion and pinned private-network module. |
| Defaults | All cloud creation and workload flags disabled. |
| Existing | Project APIs, cloud identities, shared networks and external workflows remain labelled. |

## Architecture

![OCI and GCP architecture](architecture.png)

[Editable overview and native detail pages](architecture.drawio) · [Resource inventory](resource-inventory.json)

## Terraform Components

OCI creates a private VCN/subnet, scoped security list, DRG/VCN attachment and optional primary/secondary partner FastConnect VCs. The separate GCP root creates VPC/subnet flow logs, Cloud Router and two Partner VLAN attachments. Optional HA VPN uses its own Cloud Router ASN, two Google public interfaces, two OCI CPE/IPSec connections and four IKEv2 tunnels/BGP peers.

Every conditional resource, including transitive pinned modules and the GCP companion,
is enumerated on native detail pages. Counts mean declarations, not resolved instances.
The GCP network module is pinned to its validated publication revision.
No container, service-managed host or model API is invented as an independent resource.

## Request And Deployment Flow

1. Review explicit account, cost, API, quota and address-plan prerequisites.
2. Inspect each independent root's disabled default plan.
3. Enable only the separately approved foundation and service flags.
4. Perform explicit endpoint, key, DNS, route and identity handoffs.
5. Test intended flows and denied flows separately before any migration or cutover.

## Traffic And Trust Boundaries

- OCI and Google Cloud are distinct administrative and credential boundaries.
- Plain connectors represent IDs/configuration; solid arrows show configured intent.
- Dashed arrows show external transfer, replication, authentication or cutover workflows.
- A cross-cloud diagram connector does not install a circuit, route or IAM trust.
- Cloud Router is BGP control plane, not a packet-forwarding VM.
- GCP private subnet flow logs are declared; monitoring alerts and retention policy are not inferred.
- Encryption at rest uses service defaults unless a source-declared customer key is added.

## Detailed Architecture Notes

Interconnect pairing keys and assigned BGP addresses require staged handoff. Create GCP foundations first; transfer pairing keys privately to OCI and complete partner provisioning. Enable BGP only after assigned values are reconciled, importing any partner-created interfaces instead of duplicating them. For VPN, create the GCP gateway, pass its two public IPs as primary/secondary OCI CPE inputs, discover the four OCI tunnel IDs/public endpoints, then configure both tunnel maps and matching protected PSKs. The provided VPN BGP priority is 200 versus Interconnect 100 on Google; OCI DRG propagation/import policies and end-to-end preference need separate review. No automatic HA or failover outcome is established.

Only source-declared native glyphs are used; unmapped resources remain named boxes.
Existing APIs, billing, keys and project ownership are prerequisites, not created resources.
Default routes are deleted by the GCP network module; optional NAT/route is explicitly gated.
Firewall rules apply to matching VM tags and scoped prefixes/ports, not every managed service.

## Operational Boundaries

- No runtime activation, workload deployment, application traffic or failover test was run.
- Data backup/transfer/replication and promotion remain distinct from infrastructure provisioning.
- Operator attestations must not be treated as successful automated discovery or acceptance.
- Keep protected inputs and independent deployment backends outside version control.
- Review scoped IAM, region/service support, effective routes and return paths before enabling.
- Rehearse cleanup and restore without deleting existing shared dependencies.

## Review Checklist

- Compare every resource and creation condition with the inventory and companion sources.
- Confirm no unexpected cloud resources in disabled plans.
- Verify private endpoints, caller identities and negative/denied request behavior.
- Verify route preference and failover only where actual transport is configured.
- Measure workload recovery and data consistency against approved objectives.
- Review permissions, costs, backups and explicit cleanup ownership.

## References

[Primary service reference](https://docs.cloud.google.com/network-connectivity/docs/vpn/how-to/creating-ha-vpn).
[Validation record](../../../../docs/multicloud/GCP-COUNTERPARTS-20261028.md).
