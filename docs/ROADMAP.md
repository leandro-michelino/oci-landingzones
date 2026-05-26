# OCI Landing Zones Roadmap

This document tracks what is already available and what is next.
Available blueprints are summarized here, with full specs in each blueprint
folder. Detailed planning notes stay only for items that are not available yet.

Each planned blueprint follows the same folder contract as existing ones:

```text
blueprints/<family>/<deployment>/
|-- README.md                  Operator guide
|-- architecture/README.md     Detailed Architecture
|-- main.tf                    Terraform composition
|-- variables.tf               Input contract
|-- outputs.tf                 Hand-off values
|-- providers.tf               OCI provider configuration
|-- versions.tf                Terraform / provider constraints
|-- terraform.tfvars.example   Local input example
`-- ansible/
    |-- plan.yml
    |-- apply.yml
    `-- destroy.yml
```

Add a new deployable blueprint only when it represents a real customer outcome
with its own lifecycle, owner, approval path, state boundary, or architecture review.
Do not create a full deployment for every topic or subtopic. Supporting pieces
such as a single notification topic, event rule, alarm set, NSG choice, private
endpoint, API route group, or optional IAM policy should stay inside the owning
blueprint.

When planned work repeats Terraform behavior already needed by several
blueprints, extract that behavior into `modules/` and keep the blueprint as the
customer-facing wrapper. Curated full landing-zone bundles belong on the
roadmap only when they describe a common real journey, such as an industry,
compliance, or workload platform pattern.

---

## Current Blueprint Inventory

The repository currently contains 76 available blueprint
entry points. See [Architecture Index](architecture/README.md#blueprint-architecture-inventory)
for the complete folder-by-folder list with links to each local Architecture
file.

| Family | Available Entry Points |
| --- | ---: |
| `blueprints/ai/` | 9 |
| `blueprints/cis/` | 2 |
| `blueprints/compliance/` | 4 |
| `blueprints/core/` | 1 |
| `blueprints/data-platform/` | 8 |
| `blueprints/devops/` | 1 |
| `blueprints/disaster-recovery/` | 3 |
| `blueprints/extensions/` | 16 |
| `blueprints/identity/` | 3 |
| `blueprints/industry/` | 2 |
| `blueprints/networking/` | 22 |
| `blueprints/operating-entity/` | 3 |
| `blueprints/operations/` | 1 |

---

## Specialized (Complete)

The specialized queue is complete. New specialized candidates
should be added under the architecture backlog until they are ready to become a
roadmap commitment.

## AI / ML Platform

AI workloads beyond a single GenAI endpoint. AI Agents and MySQL HeatWave are
available; Data Science remains as the next ML lifecycle platform gap.

---

### OCI Data Science

| Attribute | Value |
| --- | --- |
| Folder | `blueprints/ai/data-science/` |
| Depends on | Core Landing Zone; VCN from any networking blueprint |

**Why this exists.**
The `genai-private` blueprint covers managed inference. Teams building and
training custom models need a separate landing zone: notebook sessions with GPU
shapes, a model catalog, a private model deployment endpoint, and scoped IAM so
data scientists and pipeline service accounts can operate independently.

**What it deploys.**

| Resource | Notes |
| --- | --- |
| OCI Data Science project | Scoped to compartment |
| Notebook session config | Shape options including GPU; private VCN subnet |
| Model catalog | Versioned model storage in the project |
| Model deployment | Private HTTP endpoint for online inference |
| Object Storage bucket | Training datasets and experiment artifacts |
| Vault secret | Optional API key or token for external data sources |
| IAM policies | Data science service, notebook sessions, model deploy |

**Architecture.**

```text
 Data Scientist (notebook session, private VCN)
       |
       v
 OCI Data Science Project
 |--- Notebook Sessions (GPU / CPU shapes)
 |--- Model Catalog (versioned artifacts)
 `--- Model Deployment (private endpoint)
       |
       `--- Object Storage (datasets / artifacts)
       `--- Vault (credentials for external sources)
```

**Inputs to decide.**

- Notebook session shape (CPU or GPU) and block volume size
- VCN subnet for notebook and model deployment
- Object Storage bucket for training data
- Whether to expose model deployment endpoint to a specific app subnet

**Outputs and hand-off.**

```text
data_science_project_id
model_deployment_endpoint
notebook_session_subnet_id
artifact_bucket_name
```

---

## Platform Services

Serverless and middleware services that round out the application platform.

---

### GoldenGate Replication Hub

| Attribute | Value |
| --- | --- |
| Folder | `blueprints/data-platform/goldengate/` |
| Depends on | Core Landing Zone; source database blueprint (Autonomous DB or MySQL) |

**Why this exists.**
Cross-region replication, real-time ETL, and hybrid-cloud data sync are common
enterprise requirements. GoldenGate needs a private VCN deployment, Vault for
source and target connection credentials, and IAM so pipeline operators can
manage trails and extracts without tenancy-admin access.

**What it deploys.**

| Resource | Notes |
| --- | --- |
| GoldenGate deployment | Private VCN attachment; tech type configurable |
| Vault secrets | Source DB credentials, target DB credentials |
| NSG | Allows GoldenGate console HTTPS; blocks all other ingress |
| IAM policies | GoldenGate operator group, service principal |
| Optional: Object Storage trail bucket | For cross-region trail file transfer |

**Architecture.**

```text
 Source Database (Autonomous DB / MySQL / on-prem)
       |
       v (extract trail)
 GoldenGate Deployment (private VCN)
 |--- Vault (source + target credentials)
 |--- NSG (HTTPS for admin console only)
 `--- Object Storage trail bucket (cross-region)
       |
       v (replicat trail)
 Target Database (any OCI or external endpoint)
```

**Inputs to decide.**

- GoldenGate technology type (Oracle, MySQL, PostgreSQL, BigData)
- Source and target connection OCIDs or hostnames
- OCPU count and auto-scaling
- Whether to enable cross-region Object Storage trail
- Admin group for GoldenGate console access

**Outputs and hand-off.**

```text
goldengate_deployment_id
goldengate_console_url
trail_bucket_name
vault_secret_ids
```

---

### Oracle Digital Assistant (ODA) (Available)

| Attribute | Value |
| --- | --- |
| Folder | `blueprints/extensions/digital-assistant/` |
| Depends on | Core Landing Zone; optional existing network IDs for extension-only mode |
| Status | Available in `blueprints/extensions/digital-assistant/` |

**Why this exists.**
ODA is the conversational AI layer for Oracle SaaS and custom app integrations.
The available blueprint covers ODA instance lifecycle, optional private
endpoint lifecycle, deploy-and-use network wiring, optional IAM policy
statements, and operational outputs for channel integration runbooks.

**What it deploys.**

| Resource | Notes |
| --- | --- |
| ODA instance | `oci_oda_oda_instance.this` with role-based access and identity-domain inputs |
| ODA private endpoint | `oci_oda_oda_private_endpoint.this` with subnet + NSG placement |
| ODA private endpoint attachment | `oci_oda_oda_private_endpoint_attachment.this` for instance/endpoint binding |
| ODA network foundation | Optional VCN, route table, security list, subnet, and NSG resources |
| IAM + alert operations | Optional `oci_identity_policy.access` and `oci_ons_notification_topic.alert` |

**Inputs to decide.**

- ODA shape and role-based access mode (`oda_shape_name`, `oda_is_role_based_access`)
- Whether to create instance, private endpoint, and attachment in one run
- Whether to create network resources or pass existing subnet and NSG IDs
- Ingress CIDR allowlist for endpoint HTTPS traffic

**Outputs and hand-off.**

```text
oda_instance_id
oda_instance_connector_url
oda_private_endpoint_id
oda_network_contract
oda_operational_contract
```

---

## Security & Governance Automation

Blueprints that extend the compliance baseline with automated detection,
response, and data governance.

---

### Data Catalog and Lineage

| Attribute | Value |
| --- | --- |
| Folder | `blueprints/data-platform/data-catalog/` |
| Depends on | Core Landing Zone; Autonomous Database or MySQL HeatWave |

**Why this exists.**
Data governance starts with knowing what data exists and where it flows.
OCI Data Catalog provides automated metadata harvesting from Autonomous DB,
Object Storage, and other sources - with a business glossary and lineage graph
that satisfies GDPR data-mapping requirements and internal data governance
programmes.

**What it deploys.**

| Resource | Notes |
| --- | --- |
| Data Catalog instance | Scoped to compartment |
| Data assets | Autonomous DB, Object Storage, and optionally MySQL |
| Harvest schedule | Automated metadata sync on configurable cadence |
| Business glossary | Seed categories and terms |
| IAM policies | Catalog admin, data steward, read-only consumer groups |

**Architecture.**

```text
 Data Sources
 |--- Autonomous DB
 |--- Object Storage buckets
 `--- MySQL HeatWave (optional)
       |
       v (harvest schedule)
 OCI Data Catalog
 |--- Data Assets and entities
 |--- Business Glossary
 |--- Lineage graph
 `--- IAM (admin / steward / read-only)
```

**Inputs to decide.**

- Data assets to register (Autonomous DB OCID, bucket names)
- Harvest frequency
- Business glossary seed terms
- Which groups get steward vs read-only access

**Outputs and hand-off.**

```text
data_catalog_id
data_asset_keys
glossary_key
```

---

### Vault Advanced / BYOK

| Attribute | Value |
| --- | --- |
| Folder | `blueprints/extensions/vault-advanced/` |
| Depends on | Core Landing Zone (Vault baseline) |

**Why this exists.**
Core Landing Zone creates a Vault and basic keys. Regulated industries need
HSM-backed (Virtual Private Vault) keys, customer-managed key import (BYOK),
key rotation policies with automated alarms, and a break-glass access model
with audit trail - none of which the baseline Vault wires by default.

**What it deploys.**

| Resource | Notes |
| --- | --- |
| Virtual Private Vault | HSM-backed; dedicated partition |
| Master encryption key | RSA or AES; customer-imported (BYOK) |
| Key rotation policy | Rotation schedule + alarm on approaching expiry |
| Break-glass IAM policy | Time-limited emergency access with mandatory logging |
| Monitoring alarm | Key expiry warning, failed decrypt events |
| Object Storage audit export | Key usage audit log archive |

**Inputs to decide.**

- Vault type: Virtual Private (HSM) vs software
- Key algorithm and length
- BYOK: whether to import existing key material or generate in OCI
- Key rotation interval
- Break-glass group and approval workflow

**Outputs and hand-off.**

```text
vault_id
master_key_id
key_version_id
rotation_alarm_id
audit_bucket_name
```

---

## Industry Verticals

Vertical-specific landing zones that combine Core + compliance + workload
patterns into a single deployable shape for a target industry.

---

### Financial Services Landing Zone

| Attribute | Value |
| --- | --- |
| Folder | `blueprints/industry/financial-services/` |
| Depends on | Core Landing Zone; extends `healthcare-pci` compliance controls |

**Why this exists.**
Financial services customers face PCI DSS, SOC 2, and often local regulatory
requirements simultaneously. This blueprint composes the Core baseline with
strict compartment isolation (front office / back office / DMZ), dedicated HSM
keys per data class, Data Safe integration for database activity monitoring, and
an audit trail pipeline that satisfies regulators.

**What it deploys.**

| Resource | Notes |
| --- | --- |
| Compartment hierarchy | Front office, back office, DMZ with strict IAM boundaries |
| Security Zone | Custom recipe: no public IPs, mandatory encryption |
| Data Safe target registration | Autonomous DB and MySQL activity monitoring |
| Dedicated HSM key per compartment | Vault Advanced integration |
| Audit pipeline | Audit log -> Logging Analytics -> Object Storage (7-year retention) |
| Network: Zero Trust micro-segmentation | ZPR policies layered on VCN subnets |

**Inputs to decide.**

- Regulatory targets: PCI DSS, SOC 2, or local (DORA, MAS TRM)
- Data classification: which compartment holds cardholder vs operational data
- Data Safe alert policies
- Audit log retention window

**Outputs and hand-off.**

```text
compartment_ids (front_office / back_office / dmz)
security_zone_id
data_safe_target_id
audit_bucket_name
```

---

### HPC / GPU Cluster

| Attribute | Value |
| --- | --- |
| Folder | `blueprints/industry/hpc-gpu/` |
| Depends on | Core Landing Zone; VCN from any networking blueprint |

**Why this exists.**
AI training, scientific simulation, and rendering workloads need RDMA cluster
networking, GPU or BM shapes, and high-throughput shared storage - a pattern
entirely different from the web/API tiers the other blueprints cover. No HPC
blueprint exists in the repo today.

**What it deploys.**

| Resource | Notes |
| --- | --- |
| Cluster Network | RDMA-connected BM.GPU or BM.HPC shapes |
| Instance Pool | Uniform GPU nodes managed as a group |
| Shared NFS mount target | Block Volume or File Storage for checkpoint storage |
| Bastion session | Private access to cluster nodes |
| IAM policies | HPC administrator, job submission, read-only monitor |
| Object Storage bucket | Job input / output archiving |

**Architecture.**

```text
 Researcher / Scheduler (bastion session)
       |
       v
 Cluster Network (RDMA)
 |--- GPU / HPC instances (Instance Pool)
 |--- Shared NFS (File Storage mount target)
 `--- Object Storage (job I/O archive)
       |
       `--- IAM (admin / job-submit / monitor)
```

**Inputs to decide.**

- Compute shape: BM.GPU4.8, BM.HPC2.36, or other
- Cluster node count and autoscale bounds
- Shared storage type: File Storage (NAS) vs Block Volume (iSCSI per node)
- Job scheduler: SLURM on Compute vs OCI Batch (future)
- Whether to expose cluster via dedicated VPN or FastConnect

**Outputs and hand-off.**

```text
cluster_network_id
instance_pool_id
nfs_mount_target_ip
bastion_session_endpoint
```

---

### Public Sector / FedRAMP Alignment

| Attribute | Value |
| --- | --- |
| Folder | `blueprints/compliance/public-sector/` |
| Depends on | Core Landing Zone; extends `scca-cloud-native` |

**Why this exists.**
Government and public sector customers need the SCCA architecture hardened
further: IL2-compatible network isolation, FedRAMP-aligned control mapping,
mandatory FIPS-140-2 key usage, and a break-glass access model with mandatory
SOC review. The `scca-cloud-native` blueprint provides the base; this one adds
the control-family overlay and audit pipeline.

**What it deploys.**

| Resource | Notes |
| --- | --- |
| FedRAMP control tag set | Defined tags mapping resources to NIST 800-53 controls |
| FIPS-compliant Vault keys | RSA-3072 / AES-256 only; no software keys |
| Enhanced audit pipeline | Audit + VCN Flow + OS logs -> Logging Analytics (2-year hot) |
| Cloud Guard enhanced recipe | IL2 network isolation checks + public exposure alerts |
| Break-glass access model | Emergency IAM policy + mandatory audit trail |
| Security assessment schedule | Quarterly Vulnerability Scanning across all compartments |

**Inputs to decide.**

- IL level: IL2, IL4, or IL5 (drives NSG strictness and encryption requirements)
- FedRAMP impact level: Low, Moderate, or High
- Audit log retention: hot (Logging Analytics) vs cold (Object Storage archive)
- Break-glass group and mandatory notification destination

**Outputs and hand-off.**

```text
fedram_tag_namespace_id
fips_vault_id
audit_log_group_id
cloud_guard_target_id
```

---

## Azure + OCI Multicloud Expansion

These patterns focus on enterprise Azure + OCI operating models where identity,
network, operations, and AI services span both clouds.

### Azure + OCI Idea Bullets

- Identity federation: Microsoft Entra ID as IdP for OCI IAM (SSO and centralized RBAC).
- Hybrid network hub: Azure vWAN/Hub + OCI DRG with site-to-site VPN or ExpressRoute/FastConnect partner path.
- Multi-cloud DR: OCI primary with Azure standby and DNS failover runbooks.
- Data replication: Azure SQL/Storage into OCI Object Storage + Autonomous DB for analytics split.
- AKS + OKE pattern: Active/active Kubernetes across clouds with GitOps and traffic steering.
- Security baseline: Unified policy mapping across Azure Policy and OCI Cloud Guard/Security Zones.
- Centralized observability: Azure Monitor + OCI Logging into one SIEM pipeline.
- FinOps dashboard: Cross-cloud tagging standards and anomaly detection for both providers.
- AI gateway: Azure OpenAI + OCI Generative AI routing by region, cost, or data residency.
- Golden landing zone: Single Terraform framework with provider modules for Azure + OCI foundations.
- Oracle Database@Azure app split: `blueprints/data-platform/oracle-database-at-azure-app-split/` with app tier in Azure and OCI-aligned Oracle data controls.
- Available: Dual connectivity hardening in `blueprints/networking/azure-oci-dual-connectivity/` with Interconnect as default when present, IPSec/BGP backup, health probes, failback workflow, and low-cost test mode without Interconnect.
- Available: vWAN transit backbone in `blueprints/networking/azure-vwan-oci-drg-transit/` with OCI-primary DRG transit, route segmentation, and inspection path controls.
- DR drill automation: `blueprints/disaster-recovery/azure-oci-dr-drill-automation/` with rehearsal evidence capture, RTO/RPO scoring, and operator approval gates.
- Arc-enabled OKE governance: `blueprints/extensions/azure-arc-oke-governance/` for central fleet policy and inventory visibility while keeping OCI OKE as primary runtime.
- OpenTelemetry observability hub: `blueprints/extensions/azure-oci-observability-otel-hub/` to normalize traces/metrics/logs across Azure and OCI.
- Workload identity federation: `blueprints/identity/entra-oci-workload-identity/` for non-human identity trust, token exchange rules, and audit-friendly least privilege.
- Commitment-aware FinOps: `blueprints/operations/azure-oci-finops-commitment-aware/` for commitment tracking, allocation dimensions, and anomaly policy by operating entity.
- Secrets broker baseline: `blueprints/security/azure-keyvault-oci-vault-secrets-broker/` for controlled secret flow between Azure Key Vault and OCI Vault.
- Enterprise AI gateway controls: `blueprints/ai/azure-oci-ai-gateway-enterprise/` with policy engine, residency controls, fallback contracts, and usage governance.
- Data Factory ingestion lane: `blueprints/data-platform/azure-data-factory-to-oci-adb/` for governed ingestion from Azure data pipelines into OCI Object Storage and Autonomous Database.
- IPSec stability profile: `blueprints/networking/azure-oci-ipsec-hardening/` with IKE/IPSec profile baselines, MTU guidance, and troubleshooting runbook hand-off.

---

### Identity Federation (Microsoft Entra ID -> OCI IAM)

| Attribute | Value |
| --- | --- |
| Folder | `blueprints/identity/azure-entra-federation/` |
| Depends on | Core Landing Zone; OCI identity domain and Entra tenant readiness |

**Why this exists.**
Enterprise teams want single sign-on and centralized role lifecycle in Entra
while retaining OCI-native policy control. This blueprint standardizes SSO and
group-based RBAC mapping with auditable least-privilege boundaries.

**Scope highlights.**

- Entra IdP federation into OCI IAM.
- Group claim mapping to OCI groups.
- Centralized RBAC with OCI policy enforcement.
- Break-glass local OCI admin path.

---

### Hybrid Network Hub (Azure vWAN/Hub + OCI DRG)

| Attribute | Value |
| --- | --- |
| Folder | `blueprints/networking/azure-vwan-oci-drg-transit/` |
| Depends on | Core Landing Zone; hub-spoke networking on OCI; Azure hub or vWAN |
| Status | Available with OCI-primary DRG transit posture, Interconnect default path when present, and IPSec/BGP backup contract with `without-interconnect` test mode. |

**Why this exists.**
Multicloud workloads need deterministic private connectivity and controlled
failover. This blueprint codifies Azure hub-to-OCI DRG connectivity over
partner interconnect and/or IPSec backup.

**Scope highlights.**

- Azure vWAN/Hub to OCI DRG connectivity.
- Site-to-site VPN option.
- ExpressRoute + FastConnect partner path.
- Route, DNS, and inspection governance.

---

### Dual Connectivity Hardening (Interconnect Primary + IPSec/BGP Fallback) (Available)

| Attribute | Value |
| --- | --- |
| Folder | `blueprints/networking/azure-oci-dual-connectivity/` |
| Depends on | Core Landing Zone; OCI DRG-ready network posture; Azure networking subscription with ExpressRoute and VPN ownership |
| Status | Available with OCI-primary routing posture, Interconnect default path contract when present, and IPSec/BGP backup contract. |

**Why this exists.**
Teams running OCI + Azure need deterministic behavior when private circuits
degrade. This blueprint captures primary-path, fallback-path, and failback
controls in one deployable package with explicit contracts for operations.

**Scope highlights.**

- OCI DRG primary connectivity control plane.
- Interconnect path contract (`ExpressRoute + FastConnect`) for steady-state traffic.
- Optional IPSec/BGP fallback resources and route-policy contract.
- DNS/probe and runbook contracts for controlled failover and failback.

---

### Multi-Cloud DR (Azure <-> OCI) (Available)

| Attribute | Value |
| --- | --- |
| Folder | `blueprints/disaster-recovery/azure-oci-cross-cloud-dr/` |
| Depends on | Core Landing Zone; hybrid networking; workload baseline in at least one cloud |
| Status | Available with OCI-primary variant, DNS failover runbook contracts, and connectivity mode support (`interconnect` or `without-interconnect`). |

**Why this exists.**
Application resilience often requires cloud-to-cloud recovery. This blueprint
formalizes primary/standby patterns in either direction with DNS cutover and
runbook-driven failover/failback.

**Scope highlights.**

- OCI primary with Azure standby in the available variant.
- DNS failover controls and runbooks.
- RTO/RPO measurement and rehearsal workflow.
- Recovery evidence capture for audit.

---

### Data Replication (Azure SQL/Storage -> OCI Analytics)

| Attribute | Value |
| --- | --- |
| Folder | `blueprints/data-platform/azure-oci-data-replication/` |
| Depends on | Core Landing Zone; Autonomous Database blueprint; hybrid networking |

**Why this exists.**
Customers frequently keep operational workloads in Azure while running analytics
and data products in OCI. This blueprint defines repeatable ingestion and
replication lanes from Azure SQL/Storage into OCI Object Storage + Autonomous DB.

**Scope highlights.**

- Azure SQL export/replication feeds.
- Azure Storage ingestion to OCI Object Storage.
- Load paths into Autonomous Database.
- Split operational vs analytics ownership model.

---

### AKS + OKE Active/Active Kubernetes (Available)

| Attribute | Value |
| --- | --- |
| Folder | `blueprints/extensions/aks-oke-active-passive/` |
| Depends on | Core Landing Zone; `blueprints/extensions/oke/`; Azure AKS baseline; hybrid networking |
| Status | Available with OCI-primary, interconnect-only contract and no IPSec backup path. |

**Why this exists.**
Platform teams running Kubernetes in both clouds need one pattern for traffic,
release orchestration, and day-2 operations. This blueprint defines
active/passive AKS + OKE with GitOps and controlled steering.

**Scope highlights.**

- AKS and OKE dual-cluster topology.
- GitOps delivery model across clouds.
- Traffic steering and failover posture.
- Shared platform SRE runbook contract.

---

### Security Baseline (Unified Azure Policy + OCI Controls)

| Attribute | Value |
| --- | --- |
| Folder | `blueprints/compliance/azure-oci-security-baseline/` |
| Depends on | Core Landing Zone; Cloud Guard; Security Zones; Azure Policy baseline |

**Why this exists.**
Security teams need one controls language across clouds. This blueprint maps
Azure Policy and OCI Cloud Guard/Security Zones to a shared controls matrix.

**Scope highlights.**

- Unified control mapping matrix.
- Guardrails for public exposure, encryption, and IAM.
- Cross-cloud drift and exception workflow.
- Audit-ready compliance evidence outputs.

---

### Centralized Observability (Azure Monitor + OCI Logging -> SIEM)

| Attribute | Value |
| --- | --- |
| Folder | `blueprints/extensions/azure-oci-observability-hub/` |
| Depends on | Core Landing Zone; `blueprints/extensions/observability/`; SIEM destination |

**Why this exists.**
Distributed telemetry fragments incident response. This blueprint standardizes
log and signal forwarding from Azure Monitor and OCI Logging into one SIEM.

**Scope highlights.**

- Azure Monitor pipeline integration.
- OCI Logging and service telemetry export.
- Sentinel or Splunk destination patterns.
- Alert routing and correlation conventions.

---

### FinOps Dashboard (Cross-Cloud Cost Governance)

| Attribute | Value |
| --- | --- |
| Folder | `blueprints/operations/azure-oci-finops/` |
| Depends on | Core Landing Zone; `blueprints/operations/cost-optimization/`; Azure cost exports |

**Why this exists.**
Cost governance needs one view across providers. This blueprint defines tagging
standards, normalized cost datasets, and anomaly detection across Azure and OCI.

**Scope highlights.**

- Cross-cloud tagging taxonomy.
- Azure and OCI cost ingestion model.
- Unified anomaly detection and budget alerts.
- FinOps hand-off dataset and dashboard contract.

---

### AI Gateway (Azure OpenAI + OCI Generative AI Routing) - Available

| Attribute | Value |
| --- | --- |
| Folder | `blueprints/ai/azure-oci-ai-gateway/` |
| Depends on | Core Landing Zone; `blueprints/ai/genai-gateway/`; `blueprints/ai/genai-private/`; Azure OpenAI access |

**Why this exists.**
Enterprises need model routing based on latency, cost, sovereignty, or policy.
This blueprint defines a multi-provider AI gateway across Azure OpenAI and OCI
Generative AI.

Current status: available in
`blueprints/ai/azure-oci-ai-gateway/` with full OCI + Azure session wiring.

**Scope highlights.**

- Region-aware routing between model providers.
- Cost-based model selection policies.
- Data residency policy enforcement paths.
- Usage logging and quota governance.

---

### Golden Landing Zone (Single Terraform Framework for Azure + OCI)

| Attribute | Value |
| --- | --- |
| Folder | `blueprints/core/azure-oci-golden-landing-zone/` |
| Depends on | Core Landing Zone patterns; provider module standardization for Azure and OCI |

**Why this exists.**
Large enterprises want one IaC framework that composes shared controls across
both clouds while allowing cloud-specific modules. This blueprint provides the
foundation contract for that operating model.

**Scope highlights.**

- Shared Terraform structure for Azure + OCI.
- Provider-specific modules under one governance contract.
- Standard outputs for identity, network, security, and operations.
- Baseline hand-off model for downstream multicloud blueprints.

---

## AWS + OCI Multicloud Expansion

These patterns focus on AWS + OCI operating models for shared identity,
networking, resilience, operations, and AI platform workflows across both
clouds.

### AWS + OCI Idea Bullets

- Available: Hybrid network backbone (OCI DRG primary) with AWS Transit Gateway pairing contracts, optional site-to-site VPN resources, and optional Direct Connect/FastConnect interconnect mode in `blueprints/networking/aws-oci-hybrid-network-backbone/`.
- Available: Multi-cloud DR (OCI primary, AWS standby) with DNS failover runbook metadata, RTO/RPO contracts, and drill evidence hooks in `blueprints/disaster-recovery/aws-oci-cross-cloud-dr/`.
- Available: EKS + OKE active/passive with OCI-primary OKE, AWS EKS secondary contract, failover traffic steering, and GitOps hand-off in `blueprints/extensions/eks-oke-active-passive/`.
- Identity federation baseline: Central IdP and AWS IAM Identity Center with OCI IAM federation for SSO and centralized RBAC mapping.
- Data replication and analytics split: AWS RDS/S3 ingestion into OCI Object Storage + Autonomous Database (or reverse path) for analytics domains.
- Unified security baseline: AWS Config/Security Hub/GuardDuty mapping to OCI Cloud Guard/Security Zones with shared controls matrix.
- Centralized observability: CloudWatch/CloudTrail + OCI Logging/Audit into unified SIEM pipelines and correlated alerting.
- FinOps governance: Cross-cloud tagging taxonomy, allocation dimensions, and anomaly detection across AWS and OCI.
- AI gateway routing: Amazon Bedrock + OCI Generative AI routing by region, cost, latency, and residency policy.
- Preview only: AWS Interconnect - multicloud with OCI / Oracle Interconnect for AWS managed private connectivity, tracked in `docs/multicloud/AWS-INTERCONNECT-MULTICLOUD-OCI-PREVIEW.md`; do not promote until OCI support is GA or an approved preview exception is documented.
- Golden landing zone framework: Shared Terraform pattern with OCI and AWS provider modules and consistent output contracts.

---

## Next Architecture Backlog

These are good next candidates after the current specialized and multicloud queues. They fit the
repo because they can reuse the existing contracts: Core for governance,
networking blueprints for traffic paths, extension blueprints for managed
services, and local Architecture for design review.

| Priority | Blueprint | Folder | Why It Fits |
| --- | --- | --- | --- |
| 1 | Public Edge and Ingress Zone | `blueprints/networking/public-edge-ingress/` | Completes the north-south story with DNS, WAF, public/private load balancing, certificates, and route-to-app hand-off. |
| 2 | Event-Driven Application Platform | `blueprints/extensions/event-driven-platform/` | Available. Composes Events, Service Connector Hub, Streaming, Functions, Notifications, and Object Storage into one reusable async pattern. |
| 3 | Batch and Queue Workers | `blueprints/extensions/batch-workers/` | Covers scheduled and burst compute patterns that do not fit OKE, Functions, or Container Instances. |
| 4 | Object Storage Data Lakehouse | `blueprints/data-platform/object-storage-lakehouse/` | Adds the missing data lake foundation: buckets, KMS, private endpoints, lifecycle, logs, and optional query/processing hooks. |
| 5 | OpenSearch Search and Vector Platform | `blueprints/data-platform/opensearch/` | Available. Useful as a standalone search, logging, and vector index platform, not only as an AI Agents dependency. |
| 6 | Redis Cache Landing Zone | `blueprints/extensions/redis-cache/` | Available. Adds the common low-latency cache/session layer expected by app teams. |
| 7 | Ransomware-Resilient Backup | `blueprints/operations/backup-resilience/` | Adds backup policies, immutable archive buckets, monitoring, and restore evidence for regulated tenancies. |
| 8 | WebLogic / Java App Platform | `blueprints/industry/weblogic-platform/` | Gives enterprise Java workloads a migration-ready pattern with LB, app tier, database, logs, and operations hooks. |
| 9 | VMware / Hybrid Migration Zone | `blueprints/industry/vmware-hybrid-migration/` | Covers brownfield migration where customers need private connectivity, DNS, backup, and landing-zone guardrails around VMware workloads. |

### Public Edge and Ingress Zone

| Attribute | Value |
| --- | --- |
| Folder | `blueprints/networking/public-edge-ingress/` |
| Depends on | Core Landing Zone; VCN from any networking blueprint; optional WAF blueprint |

**Why this exists.**
The repo has WAF, API Gateway, hub-spoke, and standalone VCNs, but not one
opinionated public ingress pattern that shows how Internet traffic enters OCI,
passes edge controls, reaches a load balancer, and hands off to private app
subnets. This is usually the first diagram an application owner asks for.

**What it deploys.**

| Resource | Notes |
| --- | --- |
| Public DNS zone or DNS records | Optional, depending on customer DNS ownership |
| WAF policy and attachment | Reuses WAF rules where possible |
| Public Load Balancer | HTTPS listener and certificate wiring |
| Private backend set | Targets private app subnets or API Gateway |
| NSGs | Edge-to-app traffic only; no admin ingress |
| Monitoring alarms | 5xx, unhealthy backend, certificate expiry |

**Architecture.**

```text
Internet Client
      |
      v
DNS -> WAF Policy
      |
      v
Public Load Balancer (HTTPS)
      |
      v
Private Backend Set
 |--- App subnet targets
 |--- API Gateway route (optional)
 `--- Monitoring alarms and access logs
```

**Inputs to decide.**

- DNS ownership: OCI DNS zone vs external DNS records
- Public vs private load balancer hand-off
- Certificate source and rotation model
- WAF policy mode: detect-only, block, or custom managed rules
- Backend target type: app subnet, API Gateway, or private service endpoint

**Outputs and hand-off.**

```text
public_load_balancer_id
listener_names
backend_set_name
waf_policy_id
dns_record_fqdn
```

---

### Event-Driven Application Platform

| Attribute | Value |
| --- | --- |
| Folder | `blueprints/extensions/event-driven-platform/` |
| Depends on | Core Landing Zone; optional Streaming and Functions blueprints |

**Why this exists.**
Many OCI workloads are glue: Object Storage events, audit events, stream
messages, webhook notifications, and small Functions handlers. This blueprint
would give teams a clean async foundation without hand-wiring each service.

**What it deploys.**

| Resource | Notes |
| --- | --- |
| OCI Events rules | Object Storage, Audit, resource lifecycle, or custom event patterns |
| Service Connector Hub | Moves events to Streaming, Logging, Functions, or Notifications |
| Streaming stream pool | Optional durable event backbone |
| Functions application | Optional event handler runtime |
| Notifications topic | Email, webhook, or integration target |
| IAM policies | Event producer, connector, function, and consumer groups |

**Architecture.**

```text
OCI Event Sources
 |--- Object Storage
 |--- Audit / resource changes
 `--- Custom application events
       |
       v
Events Rule -> Service Connector Hub
       |
       |--- Streaming (durable queue)
       |--- Functions (handler)
       `--- Notifications (email / webhook)
```

**Inputs to decide.**

- Event source types and matching rules
- Connector targets: stream, function, notification, log, or bucket
- Message retention and retry behavior
- Function runtime and image source when handlers are enabled
- Notification destinations and escalation ownership

**Outputs and hand-off.**

```text
event_rule_ids
service_connector_ids
stream_ids
function_app_id
notification_topic_id
```

---

### Batch and Queue Workers

| Attribute | Value |
| --- | --- |
| Folder | `blueprints/extensions/batch-workers/` |
| Depends on | Core Landing Zone; VCN from any networking blueprint |

**Why this exists.**
Some workloads are periodic or bursty: ETL jobs, file processing, report
generation, model batch scoring, and maintenance tasks. They need private
workers, queue semantics, logs, and a clean retry model rather than a permanent
application tier.

**What it deploys.**

| Resource | Notes |
| --- | --- |
| Worker instance pool or container instances | Configurable runtime pattern |
| Queue or Streaming topic | Work dispatch and retry path |
| Object Storage bucket | Input/output files and job artifacts |
| Vault secret | Worker credentials and API tokens |
| Monitoring alarms | Dead-letter, failed jobs, worker saturation |
| IAM policies | Job submitter, worker service, operator groups |

**Architecture.**

```text
Job Producer
      |
      v
Queue / Stream
      |
      v
Worker Runtime
 |--- Container Instance or Instance Pool
 |--- Vault secrets
 |--- Object Storage input/output
 `--- Monitoring alarms
```

**Inputs to decide.**

- Worker runtime: container instance, compute instance pool, or OCI Batch
- Queue or stream retention and dead-letter behavior
- Worker subnet and outbound access requirements
- Artifact bucket layout and lifecycle policy
- Scaling rules, schedule, and maximum concurrency

**Outputs and hand-off.**

```text
queue_id
worker_pool_id
artifact_bucket_name
dead_letter_alarm_id
```

---

### Object Storage Data Lakehouse

| Attribute | Value |
| --- | --- |
| Folder | `blueprints/data-platform/object-storage-lakehouse/` |
| Depends on | Core Landing Zone; Private Data Platform optional |

**Why this exists.**
The repo has a private data platform and Autonomous DB, but not a fuller lake
foundation with bronze/silver/gold zones, KMS, retention, private access,
catalog hooks, and processing hooks for analytics teams.

**What it deploys.**

| Resource | Notes |
| --- | --- |
| Object Storage buckets | Bronze, silver, gold, quarantine, logs |
| KMS keys | Separate keys per data zone when required |
| Private endpoint | Private access to Object Storage |
| Lifecycle policies | Retention, archive, delete, quarantine handling |
| Service Connector Hub | Bucket events to logs, stream, or functions |
| Optional catalog registration | Hand-off to Data Catalog blueprint |

**Architecture.**

```text
Data Producers
      |
      v
Object Storage Lake
 |--- bronze
 |--- silver
 |--- gold
 |--- quarantine
 `--- logs
      |
      |--- KMS keys
      |--- Lifecycle policies
      `--- Service Connector events
```

**Inputs to decide.**

- Zone model: bronze/silver/gold, quarantine, logs, and archive
- KMS key separation by data classification
- Private endpoint and producer subnet access
- Lifecycle retention and archive rules per bucket
- Catalog and processing hooks to enable immediately vs later

**Outputs and hand-off.**

```text
bucket_names
kms_key_ids
private_endpoint_id
service_connector_ids
```

---

### OpenSearch Search and Vector Platform

| Attribute | Value |
| --- | --- |
| Folder | `blueprints/data-platform/opensearch/` |
| Depends on | Core Landing Zone; VCN from any networking blueprint |

**Why this exists.**
AI Agents may need OpenSearch for vectors, but many customers also need a
standalone private search and log analytics pattern. This blueprint can serve
application search, operational search, and vector indexes with one reusable
network and IAM model.

**What it deploys.**

| Resource | Notes |
| --- | --- |
| OpenSearch cluster | Private endpoint, shape and node count configurable |
| NSG | Client subnet access only |
| Vault secret | Admin or integration credentials |
| Object Storage bucket | Snapshot repository |
| IAM policies | Search admins, index writers, read-only consumers |
| Monitoring alarms | Cluster health, storage pressure, rejected writes |

**Architecture.**

```text
App / Analytics Subnet
      |
      v
OpenSearch Cluster (private endpoint)
 |--- Indexes / vector indexes
 |--- Snapshot bucket
 |--- Vault credentials
 `--- Monitoring alarms
```

**Inputs to decide.**

- Cluster shape, node count, storage size, and availability domain layout
- Access model for index writers, readers, and admins
- Snapshot bucket retention and restore workflow
- Whether vector indexes are required from day one
- Client subnet and NSG allowlist

**Outputs and hand-off.**

```text
opensearch_cluster_id
opensearch_endpoint
snapshot_bucket_name
nsg_id
```

---

### Ransomware-Resilient Backup

| Attribute | Value |
| --- | --- |
| Folder | `blueprints/operations/backup-resilience/` |
| Depends on | Core Landing Zone; Observability optional |

**Why this exists.**
Backup configuration is often scattered across compute, databases, buckets, and
manual runbooks. This blueprint creates a tenancy-level resilience pattern:
backup policies, immutable archive buckets, restore evidence, alarms, and
operator hand-off.

**What it deploys.**

| Resource | Notes |
| --- | --- |
| Backup policies | Compute, block volume, and database policy shapes |
| Immutable archive bucket | Restore evidence and backup reports |
| Lifecycle rules | Long retention and archive tiering |
| Monitoring alarms | Failed backup, missing backup, restore test overdue |
| Events rules | Backup failure to Notifications or Functions |
| IAM policies | Backup operators and audit readers |

**Architecture.**

```text
Protected Resources
 |--- Compute / Block Volumes
 |--- Databases
 `--- Object Storage
      |
      v
Backup Policies and Events
      |
      |--- Immutable archive bucket
      |--- Monitoring alarms
      `--- Restore evidence reports
```

**Inputs to decide.**

- Resource scope: tenancy, compartment, or workload-specific backup domains
- Backup schedule, retention, and restore testing cadence
- Immutable archive bucket policy and retention lock expectations
- Notification path for failed or missing backups
- Evidence format required by auditors or service owners

**Outputs and hand-off.**

```text
backup_policy_ids
archive_bucket_name
backup_alarm_ids
restore_evidence_bucket_name
```

---

### WebLogic / Java App Platform

| Attribute | Value |
| --- | --- |
| Folder | `blueprints/industry/weblogic-platform/` |
| Depends on | Core Landing Zone; VCN from any networking blueprint; database blueprint optional |

**Why this exists.**
Enterprise Java migrations usually need the same OCI shape: private app
subnets, load balancer, database endpoint, certificates, logs, alarms, and
controlled admin access. This pattern would make WebLogic-style migrations
reviewable and repeatable.

**What it deploys.**

| Resource | Notes |
| --- | --- |
| Private app tier | Compute instances or instance pool |
| Load balancer | Public or private depending on ingress model |
| Admin access | Bastion session or private admin subnet |
| Database hand-off | Autonomous DB, PostgreSQL, MySQL, or Exadata output |
| Logging and alarms | JVM logs, load balancer health, instance metrics |
| Vault secrets | Admin passwords, datasource credentials, certs |

**Architecture.**

```text
User / Edge Ingress
      |
      v
Load Balancer
      |
      v
WebLogic / Java App Tier (private subnets)
 |--- Bastion admin path
 |--- Vault secrets
 |--- Logs and alarms
 `--- Database endpoint
```

**Inputs to decide.**

- Runtime model: compute instances, instance pool, or marketplace image
- Public vs private ingress and certificate source
- Admin access pattern through Bastion or private operations subnet
- Database target and datasource secret model
- Log locations, JVM metrics, and alarm thresholds

**Outputs and hand-off.**

```text
load_balancer_id
app_instance_ids
admin_bastion_id
database_endpoint
```

---

### VMware / Hybrid Migration Zone

| Attribute | Value |
| --- | --- |
| Folder | `blueprints/industry/vmware-hybrid-migration/` |
| Depends on | Core Landing Zone; FastConnect or IPSec VPN blueprint |

**Why this exists.**
Some customers land in OCI through migration before modernization. A VMware or
hybrid migration zone should combine private connectivity, DNS, segmented
networks, backup, logging, and governance so brownfield workloads enter a clean
landing zone instead of becoming an exception forever.

**What it deploys.**

| Resource | Notes |
| --- | --- |
| Hybrid connectivity hand-off | FastConnect or IPSec VPN outputs |
| Migration network segments | Management, vMotion, workload, backup |
| Private DNS resolver rules | On-premises and OCI name resolution |
| Backup and archive hooks | Backup Resilience blueprint hand-off |
| Logging and monitoring | Network, migration, and workload signals |
| IAM policies | Migration operators and read-only auditors |

**Architecture.**

```text
On-Premises / Existing VMware
      |
      v
FastConnect or IPSec VPN
      |
      v
OCI Hybrid Migration Zone
 |--- management network
 |--- workload network
 |--- backup network
 |--- private DNS
 `--- logging and monitoring
```

**Inputs to decide.**

- Connectivity path: FastConnect, IPSec VPN, or both
- Network segment mapping for management, workload, backup, and migration flows
- DNS forwarding rules between OCI and on-premises domains
- Backup hand-off and restore validation model
- Migration operator groups and audit requirements

**Outputs and hand-off.**

```text
migration_network_ids
dns_resolver_rule_ids
connectivity_attachment_ids
backup_handoff_outputs
```

---

## OCI Service Gaps

Service gap watchlist based on customer demand. Entries marked `Available`
already have deployable blueprint folders; the rest remain backlog candidates
that can reuse existing Core, networking, and IAM contracts.

| Priority | Blueprint | Folder | Why It Fits |
| --- | --- | --- | --- |
| 1 | OCI NoSQL Database | `blueprints/data-platform/nosql/` | Available. Key-value and document store with table capacity contract, optional index, optional cross-region replica, optional app network, and optional IAM/alerts. |
| 2 | OCI Data Safe | `blueprints/compliance/data-safe/` | Database activity monitoring, auditing, and data masking. Comes up in every regulated engagement alongside Autonomous DB, MySQL, or PostgreSQL. |
| 3 | OCI Secure Desktops | `blueprints/industry/secure-desktops/` | Available. Managed VDI pattern with private network, session policies, BYOL-aware Windows 10/11 guardrail, and image management wiring. |
| 4 | OCI Data Flow | `blueprints/data-platform/data-flow/` | Managed Apache Spark for batch analytics and ETL. Fills the analytics gap between Autonomous DB and a full Lakehouse. |
| 5 | OCI Data Integration | `blueprints/data-platform/data-integration/` | Managed ELT/ETL workspace. Complements GoldenGate for non-CDC integration patterns and connects to Autonomous DB and Object Storage. |
| 6 | OCI Certificates Service | `blueprints/extensions/certificates/` | Managed PKI and certificate authority. TLS lifecycle is always a gap in first-deployment reviews and works across LB, API Gateway, and OKE. |
| 7 | OCI AI Services | `blueprints/ai/ai-services/` | Available. Pre-trained Vision, Language, Speech, Document Understanding, and Anomaly Detection. Distinct from GenAI; pairs well with ODA and OIC integration patterns. |
| 8 | Oracle Cloud VMware Solution (OCVS) | `blueprints/industry/ocvs/` | Native VMware baremetal on OCI. Different from the hybrid migration zone; covers customers running VMware on OCI long-term rather than transitioning off it. |
| 9 | OCI Process Automation | `blueprints/extensions/process-automation/` | Low-code workflow automation connecting Oracle SaaS, OCI services, and custom REST APIs. Common in ERP and CX integration projects. |
| 10 | OCI Network Load Balancer | `blueprints/networking/network-load-balancer/` | Available. Layer 4 TCP/UDP load balancing with private backend sets, listeners, and health checks. |
| 11 | OCI Email Delivery | `blueprints/extensions/email-delivery/` | SMTP relay and approved sender service. App teams always need it; requires IAM, NSG, and SPF/DKIM configuration. |
| 12 | OCI Threat Intelligence | `blueprints/compliance/threat-intelligence/` | Indicator-of-compromise feeds integrated with Cloud Guard custom detector recipes and event rules. Natural companion to security-posture blueprint. |

---

### OCI NoSQL Database (Available)

| Attribute | Value |
| --- | --- |
| Folder | `blueprints/data-platform/nosql/` |
| Depends on | Core Landing Zone; optional existing network IDs for extension-only mode |
| Status | Available in `blueprints/data-platform/nosql/` |

**Why this exists.**
Many application teams need a low-latency key-value or document store that
does not require a relational schema. The available blueprint provides the
NoSQL table contract with explicit capacity settings, plus optional index,
optional cross-region replica, optional deploy-and-use app network resources,
and optional IAM/alert operations wiring.

**What it deploys.**

| Resource | Notes |
| --- | --- |
| NoSQL table | `oci_nosql_table.this` with explicit read/write/storage limits |
| NoSQL secondary index | Optional `oci_nosql_index.secondary` |
| NoSQL table replica | Optional `oci_nosql_table_replica.this` for cross-region resilience |
| App network foundation | Optional VCN, route table, security list, and subnet resources |
| IAM + alert operations | Optional `oci_identity_policy.access` and `oci_ons_notification_topic.alert` |

**Architecture.**

```text
App Tier (optional app subnet)
      |
      | OCI SDK/API calls
      v
OCI NoSQL Table
 |--- capacity mode + read/write/storage limits
 |--- optional secondary index
 `--- optional cross-region replica
```

**Inputs to decide.**

- Table DDL schema and key design (`table_ddl_statement`)
- Capacity mode and limits (`table_capacity_mode`, read/write/storage)
- Whether to create secondary index and table replica
- Whether to create app network resources or use existing app networking

**Outputs and hand-off.**

```text
nosql_table_id
nosql_table_name
nosql_capacity_contract
app_network_contract
nosql_replica_region
```

---

### OCI Data Safe

| Attribute | Value |
| --- | --- |
| Folder | `blueprints/compliance/data-safe/` |
| Depends on | Core Landing Zone; Autonomous Database, MySQL, or PostgreSQL blueprint |

**Why this exists.**
Every regulated OCI engagement eventually asks how database activity is
monitored and how sensitive data is discovered. Data Safe provides security
assessment, user risk assessment, activity auditing, data masking, and alert
policies - but it requires explicit target registration and IAM scoping that
does not come from the database blueprints themselves.

**What it deploys.**

| Resource | Notes |
| --- | --- |
| Data Safe private endpoint | VCN attachment for on-premises or private database targets |
| Target database registration | Autonomous DB, MySQL HeatWave, or PostgreSQL target |
| Security assessment schedule | Automated periodic assessment with alert on findings |
| User risk assessment | Privileged user and entitlement review |
| Activity audit policy | Default audit policies enabled on target |
| Data discovery run | Identifies sensitive columns by data type and pattern |
| Data masking policy | Masks PII and sensitive data in non-production targets |
| IAM policies | Data Safe admin, security reviewer, audit reader groups |

**Architecture.**

```text
Target Database (Autonomous DB / MySQL / PostgreSQL)
      |
      v (private endpoint)
OCI Data Safe
 |--- Security Assessment (scheduled)
 |--- User Risk Assessment
 |--- Activity Auditing (audit trail)
 |--- Data Discovery (sensitive column scan)
 `--- Data Masking (non-production targets)
      |
      `--- IAM: admin / reviewer / auditor
```

**Inputs to decide.**

- Target database type and OCID
- Assessment schedule frequency
- Sensitive data categories to discover and mask
- Audit policy scope: default vs custom
- Which environments get masking vs discovery-only

**Outputs and hand-off.**

```text
data_safe_target_id
private_endpoint_id
security_assessment_id
masking_policy_id
audit_trail_id
```

---

### OCI Data Flow

| Attribute | Value |
| --- | --- |
| Folder | `blueprints/data-platform/data-flow/` |
| Depends on | Core Landing Zone; Object Storage Lakehouse optional |

**Why this exists.**
Analytics and data engineering teams need a managed Spark environment that does
not require cluster management. OCI Data Flow runs Spark jobs against Object
Storage and other sources with private subnet execution, IAM scoping, and
logging - but there is no landing zone pattern for the networking, IAM, and
storage hand-off today.

**What it deploys.**

| Resource | Notes |
| --- | --- |
| Data Flow application | Spark application definition; runtime configurable |
| Private subnet execution | Data Flow runs inside private VCN subnet |
| Object Storage buckets | Input data, output data, Spark logs |
| Vault secret | Optional credentials for external data sources |
| IAM policies | Data Flow service, job submitter, log reader groups |
| Monitoring alarm | Failed runs, long-running jobs |

**Architecture.**

```text
Job Submitter (IAM group)
      |
      v
Data Flow Application (Spark)
 |--- Private subnet execution
 |--- Input bucket (Object Storage)
 |--- Output bucket (Object Storage)
 |--- Spark logs bucket
 `--- Vault (external source credentials)
```

**Inputs to decide.**

- Spark runtime version and driver / executor shapes
- Input and output bucket naming and lifecycle
- Private subnet and NAT gateway or service gateway requirements
- Log retention and archival policy
- Max concurrent runs and timeout

**Outputs and hand-off.**

```text
data_flow_application_id
input_bucket_name
output_bucket_name
log_bucket_name
execution_subnet_id
```

---

### OCI Data Integration

| Attribute | Value |
| --- | --- |
| Folder | `blueprints/data-platform/data-integration/` |
| Depends on | Core Landing Zone; Autonomous Database or MySQL HeatWave |

**Why this exists.**
GoldenGate covers CDC replication. Data Integration covers batch ELT: visual
pipeline design, data validation, transformation, and scheduled loads between
databases, Object Storage, and external sources. The workspace, private endpoint,
and IAM model are distinct from GoldenGate and need their own blueprint.

**What it deploys.**

| Resource | Notes |
| --- | --- |
| Data Integration workspace | Project container for pipelines and data assets |
| Private endpoint | VCN attachment for workspace access |
| Data assets | Autonomous DB, Object Storage, and optionally MySQL |
| Vault secret | Source and target connection credentials |
| IAM policies | Workspace admin, pipeline developer, read-only reviewer |

**Architecture.**

```text
Data Sources
 |--- Autonomous DB
 |--- Object Storage
 `--- MySQL (optional)
      |
      v (private endpoint)
Data Integration Workspace
 |--- Data Assets and connections
 |--- Pipeline projects
 `--- IAM: admin / developer / reviewer
```

**Inputs to decide.**

- Source and target data asset types and OCIDs
- VCN and subnet for the workspace private endpoint
- Pipeline schedule and retry behavior
- Vault secret rotation and access model

**Outputs and hand-off.**

```text
workspace_id
private_endpoint_id
data_asset_keys
vault_secret_ids
```

---

### OCI Certificates Service

| Attribute | Value |
| --- | --- |
| Folder | `blueprints/extensions/certificates/` |
| Depends on | Core Landing Zone |

**Why this exists.**
TLS certificate management is consistently a gap in first-deployment reviews.
Certificates expire silently, private CAs are configured manually, and rotation
is not monitored. The Certificates Service provides a managed private CA, public
certificate import, automatic rotation hooks, and Vault integration - but the
IAM, alarm, and rotation wiring need explicit landing zone treatment.

**What it deploys.**

| Resource | Notes |
| --- | --- |
| Certificate authority | Private CA for internal TLS (optional) |
| Certificate | Imported or CA-issued; associated to LB, API GW, or OKE |
| Vault integration | Certificate versions stored as Vault secrets |
| Monitoring alarm | Certificate expiry warning at 30 and 7 days |
| IAM policies | Certificate admin, issuer, and reader groups |

**Architecture.**

```text
OCI Certificates Service
 |--- Private CA (internal TLS)
 |--- Imported public certificate
 |--- Vault (certificate versions)
 `--- Monitoring alarm (expiry 30d / 7d)
      |
      `--- LB / API Gateway / OKE consumer
```

**Inputs to decide.**

- CA type: private internal CA vs external public certificate import
- Rotation model: manual vs automated hook
- Certificate consumers: Load Balancer, API Gateway, OKE, or custom
- Expiry alarm notification destination

**Outputs and hand-off.**

```text
certificate_authority_id
certificate_id
vault_secret_id
expiry_alarm_id
```

---

### OCI AI Services

| Attribute | Value |
| --- | --- |
| Folder | `blueprints/ai/ai-services/` |
| Depends on | Core Landing Zone; Object Storage for input/output |

**Why this exists.**
OCI provides a set of pre-trained AI models - Vision, Language, Speech,
Document Understanding, and Anomaly Detection - that are API-driven and do not
need a model server. They come up in ODA, OIC, and custom app integrations but
the IAM, VCN endpoint, Object Storage pipeline, and audit model are never
explicitly wired. This blueprint gives that a consistent landing zone shape.

**What it deploys.**

| Resource | Notes |
| --- | --- |
| Object Storage buckets | Input documents, images, audio; processed output |
| Private endpoint | VCN-attached access to AI service APIs where supported |
| IAM policies | AI service caller group, pipeline service account |
| Vault secret | API credentials for external callers if needed |
| Monitoring alarm | Failed inference, error rate, latency |
| Service selection flags | Enable Vision, Language, Speech, Document Understanding, Anomaly Detection independently |

**Architecture.**

```text
Input bucket (Object Storage)
      |
      v
OCI AI Services (pre-trained models)
 |--- Vision (image classification, object detection)
 |--- Language (sentiment, NER, key phrases)
 |--- Speech (transcription)
 |--- Document Understanding (extraction, classification)
 `--- Anomaly Detection (time-series)
      |
      v
Output bucket (Object Storage)
      |
      `--- App / ODA / OIC consumer
```

**Inputs to decide.**

- Which AI service capabilities to enable
- Input and output bucket naming
- Caller group and service account IAM model
- Whether private VCN endpoint is required (Language, Vision support it)

**Outputs and hand-off.**

```text
input_bucket_name
output_bucket_name
ai_service_endpoint_urls
caller_group_id
vault_secret_id
```

---

## GenAI Platform Patterns

Advanced GenAI patterns that build on the `genai-private` and `ai/agents`
blueprints. These address the operational, governance, and architectural gaps
that appear once a team moves from a single GenAI endpoint to a production AI
platform.

These GenAI platform patterns are now available as blueprint folders.
The details below remain as architecture intent notes; the folder-level README
and `architecture/README.md` files are the source of truth for operators.

| Priority | Blueprint | Folder | Why It Fits |
| --- | --- | --- | --- |
| 1 | GenAI multi-model gateway | `blueprints/ai/genai-gateway/` | Available. Routes prompts to the right OCI GenAI model based on rules; adds rate limiting, cost tagging, and per-team IAM. |
| 2 | Fine-tuning and dedicated AI cluster | `blueprints/ai/genai-fine-tuning/` | Available. Customer-managed fine-tuning using OCI GenAI with a dedicated AI cluster, training data bucket, and endpoint hand-off. |
| 3 | GenAI guardrails and observability | `blueprints/ai/genai-guardrails/` | Available. Prompt logging, PII-aware audit flow, token alarms, and Cloud Guard hook points. |
| 4 | Document intelligence pipeline | `blueprints/ai/document-intelligence/` | Available. Document Understanding + GenAI-oriented intake, extraction, and structured output foundation. |
| 5 | Embedding and vector ingestion pipeline | `blueprints/ai/embedding-pipeline/` | Available. Functions-based chunk/embed/index foundation for OpenSearch or another vector target. |
| 6 | Multi-agent orchestration | `blueprints/ai/multi-agent/` | Available. Orchestrator and specialist agents, Streaming task hand-off, tool registry, and session audit. |

---

### GenAI Multi-Model Gateway

| Attribute | Value |
| --- | --- |
| Folder | `blueprints/ai/genai-gateway/` |
| Depends on | Core Landing Zone; `genai-private` (one or more model endpoints) |

**Why this exists.**
Production AI platforms need to route prompts to the right model based on
latency, cost, capability, or workload type - and each team or application
should have scoped access, rate limits, and cost attribution. The current
`genai-private` blueprint exposes a single endpoint. This blueprint adds the
routing, policy, and governance layer in front of one or more GenAI endpoints.

**What it deploys.**

| Resource | Notes |
| --- | --- |
| API Gateway | Private or public; routes to GenAI endpoint by path or header |
| Functions router | Optional: dynamic routing logic when rules exceed API GW capabilities |
| Usage plans | Per-team rate limits and quota on the API Gateway |
| Cost tags | Per-call compartment and team tagging for chargeback |
| Object Storage log bucket | Full prompt and response logging for audit |
| Monitoring alarms | Token usage, error rate, latency, quota exhaustion |
| IAM policies | Per-team caller groups scoped to usage plans |

**Architecture.**

```text
App Team A / App Team B (IAM-scoped)
      |
      v
API Gateway (private endpoint)
 |--- Usage plan: Team A quota
 |--- Usage plan: Team B quota
      |
      v (route by model / task)
OCI GenAI Endpoints
 |--- Llama (long-context tasks)
 |--- Cohere Command R (structured output)
 `--- Cohere Embed (embedding calls)
      |
      v
Object Storage (prompt + response audit log)
Monitoring alarms (token budget, error rate)
```

**Inputs to decide.**

- Which GenAI model endpoints to route to
- Routing rules: by path, header, or Functions logic
- Per-team quota and rate limit values
- Prompt logging: full vs metadata-only
- Cost tag keys and team identifiers

**Outputs and hand-off.**

```text
api_gateway_id
gateway_endpoint_url
usage_plan_ids
log_bucket_name
cost_tag_namespace
```

---

### Fine-Tuning and Dedicated AI Cluster

| Attribute | Value |
| --- | --- |
| Folder | `blueprints/ai/genai-fine-tuning/` |
| Depends on | Core Landing Zone; `genai-private` (base model endpoint) |

**Why this exists.**
Teams building domain-specific models need customer-managed fine-tuning: a
training dataset in Object Storage, a dedicated AI cluster for the fine-tuning
job, experiment tracking, and a private inference endpoint for the resulting
custom model. The OCI GenAI fine-tuning API covers this but the landing zone
wiring does not exist yet.

**What it deploys.**

| Resource | Notes |
| --- | --- |
| Dedicated AI cluster | GPU-backed cluster for fine-tuning jobs |
| Training data bucket | Object Storage with versioned dataset path |
| Fine-tuning job | OCI GenAI fine-tuning job using base model OCID |
| Custom model endpoint | Private inference endpoint for the fine-tuned model |
| Vault secret | Dataset credentials and any external source tokens |
| IAM policies | ML engineer, fine-tuning service, inference caller groups |
| Monitoring alarm | Job failure, cluster health, inference latency |

**Architecture.**

```text
Training Dataset (Object Storage)
      |
      v
OCI GenAI Fine-Tuning Job
 |--- Dedicated AI Cluster (GPU)
 |--- Base model (OCID from genai-private)
 `--- Custom Model (fine-tuned version)
      |
      v
Custom Model Endpoint (private)
      |
      `--- App / GenAI Gateway consumer
```

**Inputs to decide.**

- Base model OCID to fine-tune
- Training dataset bucket path and format
- Dedicated AI cluster shape and node count
- Hyperparameters: epochs, learning rate, batch size
- Whether fine-tuned model gets its own private endpoint or routes through the gateway

**Outputs and hand-off.**

```text
dedicated_cluster_id
fine_tuning_job_id
custom_model_id
custom_model_endpoint_url
training_bucket_name
```

---

### GenAI Guardrails and Observability

| Attribute | Value |
| --- | --- |
| Folder | `blueprints/ai/genai-guardrails/` |
| Depends on | Core Landing Zone; `genai-private` or `genai-gateway` |

**Why this exists.**
Production GenAI deployments need responsible-AI controls that no single
endpoint blueprint provides: prompt injection detection, PII redaction before
logging, output filtering, token budget monitoring, and a full audit trail that
satisfies regulators and internal risk teams. This blueprint is a governance
overlay on any existing GenAI endpoint.

**What it deploys.**

| Resource | Notes |
| --- | --- |
| Service Connector Hub | Routes GenAI log stream to Logging Analytics and Object Storage |
| AI Language PII detection | Scans prompts and responses before archiving |
| Object Storage audit bucket | Redacted prompt/response archive with lifecycle policy |
| Token usage alarm | Budget alarm on cumulative token spend per team |
| Cloud Guard custom detector | Unusual prompt volume or off-hours GenAI access |
| IAM policies | Guardrail service, audit reader, security reviewer groups |

**Architecture.**

```text
GenAI Endpoint (genai-private or genai-gateway)
      |
      v (log stream)
Service Connector Hub
 |--- AI Language (PII detection + redaction)
 |--- Logging Analytics (real-time query)
 `--- Object Storage (redacted audit archive)
      |
      v
Monitoring alarms (token budget, anomaly)
Cloud Guard detector (unusual volume / access)
```

**Inputs to decide.**

- PII categories to detect and redact (names, emails, financial data)
- Token budget per team or compartment
- Audit log retention and archive tiering
- Cloud Guard rule sensitivity and escalation path

**Outputs and hand-off.**

```text
service_connector_id
audit_bucket_name
token_alarm_id
cloud_guard_detector_id
logging_analytics_group_id
```

---

### Document Intelligence Pipeline

| Attribute | Value |
| --- | --- |
| Folder | `blueprints/ai/document-intelligence/` |
| Depends on | Core Landing Zone; `genai-private` (reasoning/summarization endpoint) |

**Why this exists.**
Enterprise document processing - contracts, invoices, claims, reports - follows
a consistent pipeline shape: intake, extract, reason, output. OCI Document
Understanding handles extraction; OCI GenAI handles summarization, classification,
and Q&A over the extracted content. No blueprint wires this end-to-end today.

**What it deploys.**

| Resource | Notes |
| --- | --- |
| Intake Object Storage bucket | Drop zone for incoming documents |
| Document Understanding processor | Extracts text, tables, key-value pairs from PDFs and images |
| Functions handler | Orchestrates extraction -> GenAI call -> structured output |
| GenAI call | Summarization, classification, or entity extraction prompt |
| Output Object Storage bucket | Structured JSON results and extracted text |
| Events rule | Triggers pipeline on new object in intake bucket |
| Monitoring alarm | Failed extraction, pipeline errors, queue depth |

**Architecture.**

```text
Intake bucket (Object Storage)
      |
      v (Events rule on new object)
Functions handler
 |--- Document Understanding (extract text / tables / KV)
 |--- OCI GenAI (summarize / classify / extract entities)
 `--- Output bucket (structured JSON + extracted text)
      |
      `--- Downstream app / Data Catalog / analytics
```

**Inputs to decide.**

- Document types to process (PDF, TIFF, PNG, DOCX)
- Document Understanding processor type: general, invoice, receipt, or custom
- GenAI prompt template for summarization or classification
- Output format: JSON schema for downstream consumers
- Error handling: dead-letter bucket for failed documents

**Outputs and hand-off.**

```text
intake_bucket_name
output_bucket_name
document_processor_id
functions_app_id
events_rule_id
```

---

### Embedding and Vector Ingestion Pipeline

| Attribute | Value |
| --- | --- |
| Folder | `blueprints/ai/embedding-pipeline/` |
| Depends on | Core Landing Zone; `genai-private` (embedding model); OpenSearch or `ai/agents` |

**Why this exists.**
The `ai/agents` blueprint includes an OpenSearch vector index as part of the
RAG stack. Teams that want a standalone embedding pipeline - to feed multiple
knowledge bases, power semantic search, or pre-compute embeddings for batch
inference - need a separate, reusable ingestion shape. This blueprint covers
that case: chunk, embed, index.

**What it deploys.**

| Resource | Notes |
| --- | --- |
| Source Object Storage bucket | Documents to be embedded |
| Chunking Function | Splits documents into configurable-size chunks |
| Embedding Function | Calls OCI GenAI embedding endpoint per chunk |
| Vector index target | OpenSearch cluster (reuses OpenSearch blueprint output) |
| Events rule | Triggers pipeline on new or modified objects |
| Object Storage state bucket | Checkpoints for incremental re-embedding |
| Monitoring alarm | Failed embeddings, index lag, pipeline errors |

**Architecture.**

```text
Source bucket (Object Storage)
      |
      v (Events rule)
Chunking Function
      |
      v
Embedding Function
 |--- OCI GenAI embedding model
 `--- Vectors
      |
      v
OpenSearch vector index
      |
      `--- Knowledge base / semantic search consumer
```

**Inputs to decide.**

- Chunk size and overlap strategy
- Embedding model OCID from `genai-private`
- Target vector index (OpenSearch cluster endpoint)
- Incremental vs full re-index behavior
- File types to process and exclusion patterns

**Outputs and hand-off.**

```text
source_bucket_name
embedding_function_id
vector_index_name
opensearch_endpoint
pipeline_alarm_id
```

---

### Multi-Agent Orchestration

| Attribute | Value |
| --- | --- |
| Folder | `blueprints/ai/multi-agent/` |
| Depends on | Core Landing Zone; `genai-private`; `ai/agents` (knowledge base); optionally `embedding-pipeline` |

**Why this exists.**
Single-agent RAG covers one knowledge base and one task. Production agentic
systems orchestrate multiple specialist agents: a planner, a search agent, a
code agent, a data agent. This blueprint provides the orchestration layer,
shared tool registry, inter-agent Streaming topic, session audit trail, and
IAM that keeps each agent scoped to its permitted resources.

**What it deploys.**

| Resource | Notes |
| --- | --- |
| Orchestrator GenAI Agent | Top-level planner agent |
| Specialist agents | Search, code, data - each with its own knowledge base and tool set |
| Streaming topic | Inter-agent message passing and task hand-off |
| Tool registry (Object Storage) | JSON definitions of available tools per agent |
| Session audit log | Full agent reasoning chain per session |
| IAM policies | Per-agent service principal; orchestrator-to-specialist trust |
| Monitoring alarm | Agent timeout, failed tool calls, session errors |

**Architecture.**

```text
User / App caller
      |
      v
Orchestrator Agent (GenAI)
 |--- Streaming topic (task dispatch)
 |   |
 |   |-- Search Agent (knowledge base + OpenSearch)
 |   |-- Code Agent (sandboxed Functions)
 |   `-- Data Agent (Autonomous DB / NoSQL)
 |
 `--- Session audit log (Object Storage)
      |
      `--- IAM: per-agent service principal
```

**Inputs to decide.**

- Which specialist agents to activate
- Tool definitions and permission boundaries per agent
- Streaming topic retention and partition count
- Session log retention and PII handling
- Escalation model when orchestrator cannot resolve a task

**Outputs and hand-off.**

```text
orchestrator_agent_id
specialist_agent_ids
streaming_topic_id
tool_registry_bucket_name
session_log_bucket_name
```

---

## Delivery Order Summary

```text
Core Landing Zone (available)
  |
  |-- Current Blueprint Inventory ---------------------------------
  |   |--- blueprints/data-platform/autonomous-database/
  |   |--- blueprints/ai/genai-private/
  |   |--- blueprints/devops/oci-devops-pipeline/
  |   |--- blueprints/extensions/observability/
  |   |--- blueprints/extensions/oic/
  |   |--- blueprints/extensions/oac/
  |   |--- blueprints/extensions/container-instances/
  |   |--- blueprints/data-platform/postgresql/
  |   |--- blueprints/compliance/healthcare-pci/
  |   |--- blueprints/extensions/oke-service-mesh/
  |   |--- blueprints/operations/cost-optimization/
  |   |--- blueprints/data-platform/apex-adw/
  |   |--- blueprints/extensions/functions/
  |   |--- blueprints/extensions/event-driven-platform/
  |   |--- blueprints/data-platform/opensearch/
  |   |--- blueprints/ai/ai-services/
  |   |--- blueprints/ai/genai-gateway/
  |   |--- blueprints/ai/genai-fine-tuning/
  |   |--- blueprints/ai/genai-guardrails/
  |   |--- blueprints/ai/document-intelligence/
  |   |--- blueprints/ai/embedding-pipeline/
  |   `--- blueprints/ai/multi-agent/
  |
  |-- AI/ML Platform -----------------------------------------------
  |   |--- blueprints/ai/data-science/
  |   |--- blueprints/ai/agents/
  |   `--- blueprints/data-platform/mysql-heatwave/
  |
  |-- Platform Services --------------------------------------------
  |   |--- blueprints/data-platform/goldengate/
  |   `--- blueprints/extensions/digital-assistant/
  |
  |-- Security and Governance --------------------------------------
  |   |--- blueprints/compliance/security-posture/
  |   |--- blueprints/data-platform/data-catalog/
  |   `--- blueprints/extensions/vault-advanced/
  |
  |-- Industry Verticals -------------------------------------------
  |   |--- blueprints/industry/financial-services/
  |   |--- blueprints/industry/hpc-gpu/
  |   `--- blueprints/compliance/public-sector/
  |
  |-- Next Architecture Backlog ------------------------------------
  |   |--- blueprints/networking/public-edge-ingress/
  |   |--- blueprints/extensions/batch-workers/
  |   |--- blueprints/data-platform/object-storage-lakehouse/
  |   |--- blueprints/extensions/redis-cache/
  |   |--- blueprints/operations/backup-resilience/
  |   |--- blueprints/industry/weblogic-platform/
  |   `--- blueprints/industry/vmware-hybrid-migration/
  |
  |-- OCI Service Gaps ---------------------------------------------
  |   |--- blueprints/data-platform/nosql/
  |   |--- blueprints/compliance/data-safe/
  |   |--- blueprints/industry/secure-desktops/
  |   |--- blueprints/data-platform/data-flow/
  |   |--- blueprints/data-platform/data-integration/
  |   |--- blueprints/extensions/certificates/
  |   |--- blueprints/industry/ocvs/
  |   |--- blueprints/extensions/process-automation/
  |   |--- blueprints/networking/network-load-balancer/
  |   |--- blueprints/extensions/email-delivery/
  |   `--- blueprints/compliance/threat-intelligence/
  |
  `-- GenAI Platform Patterns --------------------------------------
      `--- available; see Current Blueprint Inventory above
```

## Updating the Deployment Menu

When each blueprint is available, add it to:

1. `README.md` - Deployment Menu table under the appropriate section
2. `docs/DEPLOYMENT-PATTERN-CATALOG.md` - full pattern catalog
3. `docs/DEPLOYMENT-GUIDE.md` - deployment sequence and ordering notes
4. `VARIABLES.md` - shared variable reference when new operator inputs matter
5. `RELEASE-NOTES.md` - unreleased change summary
6. Extension README and architecture notes - both extension-only and
   base-plus-extension usage where relevant
7. `blueprints/<new-family>/README.md` - create if the family is new

New families introduced by this roadmap:

| New Family | First Blueprint | Status |
| --- | --- | --- |
| `blueprints/ai/` | `genai-private/` | Available |
| `blueprints/devops/` | `oci-devops-pipeline/` | Available |
| `blueprints/operations/` | `cost-optimization/` | Available |
