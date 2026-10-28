# GCP and OCI Cross-Cloud DR Architecture

## Deployment Purpose

Private OCI source backup foundation and a GCP recovery target.
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

OCI creates a private source network and versioned private Object Storage bucket. GCP creates a private network, versioned non-public Cloud Storage bucket and optional private Compute Engine standby VM with a dedicated service account, OS Login and Shielded VM controls.

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

The VM boots from an explicitly supplied compatible image. No OCI image conversion, incremental transfer, database replication, recovery orchestration, DNS cutover or restore is configured. Deploy backup agents/export jobs separately, transfer through approved scoped identities/TLS, verify backup hashes and restore in a rehearsal. Dedicated identities have no implicit data-access grants. GCP bucket force_destroy=false and VM deletion protection are deliberate.

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

[Primary service reference](https://docs.cloud.google.com/storage/docs/using-bucket-lock).
[Validation record](../../../../docs/multicloud/GCP-COUNTERPARTS-20261028.md).
