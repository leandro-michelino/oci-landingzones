# GCP Counterpart Batch: Implementation and Validation

Date: 2026-10-28. Scope: source implementation, local schema/mocked plans and architecture documentation. No live cloud provisioning or workload acceptance.

## Delivered Patterns

| Blueprint | OCI mocked plans | GCP mocked plans | Runtime boundary |
| --- | --- | --- | --- |
| [Hybrid backbone](../../blueprints/networking/gcp-oci-hybrid-network-backbone/README.md) | 3 | 6 | Partner activation, assigned endpoints, real BGP, routing preference and traffic/failure tests pending. |
| [Cross-cloud DR](../../blueprints/disaster-recovery/gcp-oci-cross-cloud-dr/README.md) | 2 | 3 | Source backup/export, authenticated transfer, image compatibility, restore and DNS cutover are external. |
| [GKE/OKE active/passive](../../blueprints/extensions/gke-oke-active-passive/README.md) | 2 | 3 | Manifests, images, data synchronization, ingress, runner reachability and application failover are external. |
| [MySQL recovery foundation](../../blueprints/data-platform/oci-gcp-mysql-heatwave-dr/README.md) | 2 | 3 | Independent databases until external source registration/import/replication, compatibility and promotion workflow. |
| [AI gateway](../../blueprints/ai/gcp-oci-ai-gateway/README.md) | 2 | 4 | Compatible adapter image, upstream services, Google/OCI request authentication and actual inference remain external. |

All ten roots passed `terraform init -backend=false`, `terraform validate` and a total of **30 mocked plans**. Providers are pinned to `oracle/oci 9.11.0` and `hashicorp/google 7.46.2`. The reusable [GCP private network module](../../modules/networking/gcp-private-network/README.md) passed schema validation and **four additional mocked plans** before publication. The OCI OKE/MySQL/API Gateway wrapper tests explicitly override their pinned child-module result; they verify wrapper controls, not a deployment of those services. Child sources are included in schema validation and diagram inventories.

The enabled GCP plan assertions check private VM NICs, backup public-access prevention, GKE private nodes/endpoint, Cloud SQL private IP/encrypted-only access, Cloud Run internal ingress and scoped invoker grants. Network tests also check a distinct VPN ASN, the staged gateway without configured tunnels, and four IKEv2/BGP tunnel definitions on each side. These tests do not contact cloud accounts or establish live sessions.

## Execution and Ownership

Each blueprint's root controls OCI with profile DEFAULT and an explicit compartment and region. Its `gcp/` directory contains an independently authenticated Terraform root, using `infrastructure.tf` rather than `main.tf`, a separate backend/deployment record, explicit Google project/region and safe example inputs. Terraform loads all `.tf` files in each working directory. Shared Ansible runners have distinct OCI and GCP working directories and retain apply/destroy confirmation.

Google project creation, billing, enabled APIs, organization policies and operator credentials are prerequisites. No broad project Owner grant or automatic API/billing activation is created. VM-target-tag firewall rules do not imply managed-service or Pod reachability. Provider-managed encryption is distinct from a customer-managed KMS key; none is invented in the diagrams.

New cloud creation defaults are false and require cost approval. Workloads have independent flags and prerequisite guards. GCP default Internet routes are deleted; optional Cloud NAT/default egress route is separately enabled. Private Google Access alone is not sufficient proof of API or artifact reachability. Existing/shared OCI service networks, private DNS and additional service-specific IAM/egress remain explicit handoffs.

## Dedicated and VPN Handoff

Create and inspect GCP Partner VLAN attachments before copying their pairing keys into OCI circuit inputs. Match assigned BGP addresses after partner provisioning, and import partner-created interfaces/peers instead of creating duplicates. Region-pair eligibility and provider service must be verified separately.

HA VPN uses a separate Google Cloud Router with a private ASN, distinct from the Partner Interconnect router's ASN 16550. Create its gateway first, then map its public interface addresses to the two OCI CPE inputs. After OCI creates the two IPSec connections, discover the four tunnel IDs/public endpoints and configure both roots' matching tunnel maps and protected pre-shared keys. Interface mapping and inside addresses must match actual assigned/approved values. Mock fixtures use documentation-only public addresses and non-real secrets. Google BGP priorities distinguish intended preferred/backup paths; OCI DRG routing preference, effective routes and failure behavior require separate acceptance.

## Recovery and Identity Limits

The DR buckets contain no source data or transfer job. A standby VM image is supplied explicitly; there is no OCI-to-GCE image conversion or restore orchestrator. Cloud SQL is an independent regional MySQL instance, not a configured replica. The source binlog/GTID/version/TLS requirements and external replication/import workflow need review before calling it operational DR. HeatWave analytics capacity does not transfer to Cloud SQL.

The AI pattern provides an internal Cloud Run adapter shell and explicit invoker roles. It does not build the adapter, mint Google ID tokens in OCI API Gateway, sign raw OCI inference requests, create a model endpoint or configure private cross-cloud name resolution. OCI adapter deployment is guarded by operator authentication attestation; attestations are not runtime proof.

Deletion protection and non-empty versioned bucket retention require deliberate reviewed handling during teardown. No environment was created here, so no cloud cleanup or live inventory verification is claimed.

## Architecture Checks

Both cloud sides, local metadata guards, transitive pinned modules and conditional resources are included in native detail maps. Separate GCP resource/input namespaces avoid collisions with OCI root guards. Companion discovery supports `infrastructure.tf`, so a Terraform entry does not require the filename `main.tf` to be inventoried. Six regression tests cover parsing, creation gates and companion coverage. Official native GCP service glyphs identify Cloud Run, Cloud SQL, GKE, HA VPN, Interconnect and other mapped resources. Unmapped IAM/configuration declarations remain named boxes.

## Primary References

- [Google HA VPN to peer gateways](https://docs.cloud.google.com/network-connectivity/docs/vpn/how-to/creating-ha-vpn): interface mappings and separate router/ASN requirements for Partner Interconnect.
- [OCI Site-to-Site VPN setup](https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/settingupIPsec.htm): CPE, IPSec, routing and peer-configuration ownership.
- [GKE network isolation](https://docs.cloud.google.com/kubernetes-engine/docs/how-to/latest/network-isolation): private cluster access considerations.
- [Cloud SQL external-source replication](https://docs.cloud.google.com/sql/docs/mysql/replication/external-server): compatibility and external source setup.
- [Cloud Run Direct VPC](https://docs.cloud.google.com/run/docs/configuring/vpc-direct-vpc): service/network/egress configuration.
- [Cloud Storage retention](https://docs.cloud.google.com/storage/docs/using-bucket-lock): separate retention and irreversible lock decisions; this batch does not lock a retention policy.

## Final Local Review Result

All 30 OCI/GCP Ansible playbooks passed syntax checks after using the shared runner through an explicit repository-relative role path. Repository contracts, naming, generated blueprint index and Markdown-link checks passed. The architecture catalog table includes all 93 entry points. Source inventories cover 34 OCI, 53 GCP and 17 local contract declarations for this batch, plus 30 reference inputs/collections. These are declaration counts, not deployed instances.

The five overviews and their 20 companion PNGs were inspected. The global audit covers 93 blueprint plus one conceptual overviews, 732 reviewed connectors and 348 native documents with paired PNGs. Twenty multicloud overviews have explicit OCI/cloud relationships, including dashed external-workflow links. Original diagram conversion is 80/80 complete.
