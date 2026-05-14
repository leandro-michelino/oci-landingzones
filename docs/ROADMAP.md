# OCI Landing Zones - Implementation Roadmap

Author: Leandro Michelino | ACE | <leandro.michelino@oracle.com>

This document tracks planned blueprint work. Implemented blueprints are listed
briefly - their full specs live in the individual blueprint folders. Only
blueprints without a folder yet carry detailed planning notes here.

Each planned blueprint follows the same folder contract as existing ones:

```text
blueprints/<family>/<deployment>/
|-- README.md                  Operator guide
|-- architecture/README.md     Detailed ASCII architecture
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

---

## Already Implemented

The following blueprints are fully implemented and deployable. See each folder for
operator guide, architecture diagram, and Terraform / Ansible workflow.

| Blueprint | Folder |
| --- | --- |
| Autonomous Database (ATP / ADW) | `blueprints/data-platform/autonomous-database/` |
| OCI Generative AI private landing zone | `blueprints/ai/genai-private/` |
| OCI DevOps Pipeline | `blueprints/devops/oci-devops-pipeline/` |
| Observability platform | `blueprints/extensions/observability/` |
| Oracle Integration Cloud | `blueprints/extensions/oic/` |
| Oracle Analytics Cloud | `blueprints/extensions/oac/` |
| OCI Container Instances | `blueprints/extensions/container-instances/` |
| PostgreSQL landing zone | `blueprints/data-platform/postgresql/` |
| Healthcare / PCI compliance | `blueprints/compliance/healthcare-pci/` |
| OKE service mesh | `blueprints/extensions/oke-service-mesh/` |

---

## Phase 4 - Specialized (Next Up)

Remaining blueprints that complete the current specialized catalog.

---

### Cost Optimization

| Attribute | Value |
| --- | --- |
| Folder | `blueprints/operations/cost-optimization/` |
| New family | `blueprints/operations/` |
| Depends on | Core Landing Zone (tagging, budgets baseline) |

**Why this exists.**
Multi-team tenancies without explicit cost attribution drift into uncontrolled
spend. This blueprint turns cost governance from a manual review into an
automated control loop.

**What it deploys.**

| Resource | Notes |
| --- | --- |
| Defined tag namespace | cost-centre and owner tags with tag defaults |
| Per-compartment budgets | Configurable thresholds per compartment |
| OCI Optimizer subscriptions | Recommendation categories and actions |
| Monitoring composite alarm | Budget overrun alert |
| ONS topic | Email or webhook notification on threshold breach |

**ASCII Architecture.**

```text
 Tag defaults (cost-centre / owner)
       |
       v (enforced on new resources)
 Compartment budgets
       |
       v (threshold crossed)
 Monitoring composite alarm
       |
       v
 ONS topic -> Email / Webhook
       |
       v
 OCI Optimizer (recommendations feed)
```

**Inputs to decide.**

- Tag taxonomy: which cost-centre values are valid
- Budget amounts and alert thresholds per compartment
- Notification destinations (email, PagerDuty, Slack webhook)
- Optimizer recommendation categories to subscribe to

**Outputs and hand-off.**

```text
tag_namespace_id
budget_ids
alarm_id
ons_topic_id
```

---

### Oracle APEX on Autonomous Database

| Attribute | Value |
| --- | --- |
| Folder | `blueprints/data-platform/apex-adw/` |
| Depends on | Core Landing Zone; Autonomous Database (existing) |

**Why this exists.**
APEX on ADW is the dominant OCI low-code pattern. It extends an existing
Autonomous DB instance by enabling APEX workspace provisioning and exposing ORDS
(Oracle REST Data Services) through a private load balancer - producing a
deployable APEX platform from a single `terraform apply`.

**What it deploys.**

| Resource | Notes |
| --- | --- |
| ORDS endpoint | Configured on the existing ADW instance |
| Private Load Balancer | HTTPS listener; no public exposure |
| NSG | HTTPS from app subnet only |
| APEX workspace bootstrap | Script-driven workspace and admin account creation |
| Vault secret | APEX admin credentials |

**ASCII Architecture.**

```text
 App Subnet (VCN)
       |
       | HTTPS (NSG-controlled)
       v
 Private Load Balancer
       |
       v
 ORDS endpoint (on Autonomous DB)
       |
       v
 APEX workspace
       |
       `--- Vault (admin credentials)
```

**Inputs to decide.**

- Existing Autonomous DB OCID (from `autonomous-database` blueprint outputs)
- APEX workspace name and admin username
- Load balancer shape and bandwidth
- NSG source CIDR for HTTPS access

**Outputs and hand-off.**

```text
apex_url
ords_endpoint
load_balancer_id
vault_secret_id
```

---

## Phase 5 - AI / ML Platform

AI workloads beyond a single GenAI endpoint. These three blueprints cover the
ML development lifecycle (Data Science), agentic RAG patterns (AI Agents), and
purpose-built in-memory analytics (MySQL HeatWave).

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

**ASCII Architecture.**

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

### AI Agents (RAG Landing Zone)

| Attribute | Value |
| --- | --- |
| Folder | `blueprints/ai/agents/` |
| Depends on | Core Landing Zone; `genai-private` (inference endpoint) |

**Why this exists.**
Agentic RAG patterns need more infrastructure than a plain GenAI endpoint:
a knowledge base backed by vector search, Document Understanding for ingestion,
and an Object Storage pipeline for source documents. This blueprint provisions
the full private data path from documents to agent response.

**What it deploys.**

| Resource | Notes |
| --- | --- |
| OCI Generative AI Agent | Private endpoint; connects to knowledge base |
| Knowledge base | Backed by OCI OpenSearch or Object Storage index |
| OCI OpenSearch cluster | Private VCN cluster for vector search (optional) |
| Document Understanding | Extracts text from PDFs, images for ingestion |
| Object Storage buckets | Source documents bucket; processed chunks bucket |
| IAM policies | Agent service, ingestion pipeline, caller group |
| Logging | Audit log of all agent sessions and tool calls |

**ASCII Architecture.**

```text
 Source Documents (Object Storage)
       |
       v (Document Understanding)
 Processed Chunks (Object Storage)
       |
       v (indexing pipeline)
 OCI OpenSearch (vector index, private VCN)
       |
       v
 Knowledge Base
       |
       v
 OCI Generative AI Agent (private endpoint)
       |
       v
 App / API caller (VCN-routed)
```

**Inputs to decide.**

- Document types to ingest (PDF, HTML, plain text)
- Vector search backend: OCI OpenSearch vs Object Storage index
- Chunking strategy and embedding model
- Which GenAI model the agent uses for reasoning
- Source document bucket lifecycle policy

**Outputs and hand-off.**

```text
agent_id
agent_endpoint_url
knowledge_base_id
opensearch_cluster_id
source_bucket_name
```

---

### MySQL HeatWave

| Attribute | Value |
| --- | --- |
| Folder | `blueprints/data-platform/mysql-heatwave/` |
| Depends on | Core Landing Zone; VCN from any networking blueprint |

**Why this exists.**
The repo has Autonomous Database but no MySQL pattern. MySQL HeatWave is the
most common OCI MySQL deployment - adding in-memory analytics and optional
HeatWave ML or Lakehouse features without a separate analytics engine.

**What it deploys.**

| Resource | Notes |
| --- | --- |
| MySQL HeatWave DB System | Private endpoint; HA with standby option |
| HeatWave cluster | In-memory analytics nodes; size configurable |
| NSG | Port 3306 from app subnets only |
| Vault secret | DB admin credentials |
| IAM policies | DBA group, read-only group, app group |
| Optional: Lakehouse | Object Storage external tables for HeatWave Lakehouse |

**ASCII Architecture.**

```text
 App Subnet (VCN)
       |
       | port 3306, NSG-controlled
       v
 MySQL HeatWave DB System (private endpoint)
 |--- HeatWave cluster (in-memory analytics)
 |--- Vault (admin credentials)
 `--- Optional: Lakehouse (Object Storage tables)
```

**Inputs to decide.**

- MySQL version and shape
- HeatWave cluster node count and shape
- HA: standalone vs HA pair with standby
- Whether to enable HeatWave Lakehouse and Object Storage bucket
- Backup window and retention

**Outputs and hand-off.**

```text
mysql_db_system_id
heatwave_cluster_id
mysql_endpoint_ip
vault_secret_id
```

---

## Phase 6 - Platform Services

Serverless and middleware services that round out the application platform.

---

### Oracle Functions

| Attribute | Value |
| --- | --- |
| Folder | `blueprints/extensions/functions/` |
| Depends on | Core Landing Zone; VCN from any networking blueprint |

**Why this exists.**
Not all compute is containerised. Functions is the OCI-native serverless
runtime. Teams need a private VCN subnet, OCIR-backed function image repository,
IAM for invokers and the Functions service, and optionally an API Gateway
front-end - all wired together from day one.

**What it deploys.**

| Resource | Notes |
| --- | --- |
| Functions application | Scoped to compartment and VCN subnet |
| OCIR repository | Container image storage for function code |
| IAM policies | Functions service principal, invoker group, deploy group |
| NSG | Egress from function subnet to target services |
| Optional: API Gateway route | Routes external HTTPS calls to the function |
| Optional: Events trigger | OCI Events rule -> function invocation |

**ASCII Architecture.**

```text
 OCIR (function image)
       |
       v
 Functions Application (private VCN subnet)
 |--- IAM (service principal / invoker / deploy)
 |--- NSG (egress to target services)
 |--- Optional: API Gateway (HTTPS front-end)
 `--- Optional: Events Rule (event-driven trigger)
```

**Inputs to decide.**

- VCN subnet for function execution
- OCIR repository name and image tag convention
- Invoker group: human operators vs service account vs API Gateway
- Whether to wire an Events trigger for automation (e.g. Object Storage PUT)

**Outputs and hand-off.**

```text
functions_app_id
ocir_repository_url
function_invoke_endpoint
api_gateway_route_url (if enabled)
```

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

**ASCII Architecture.**

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

### Oracle Digital Assistant (ODA)

| Attribute | Value |
| --- | --- |
| Folder | `blueprints/extensions/digital-assistant/` |
| Depends on | Core Landing Zone; optionally `genai-private` for LLM integration |

**Why this exists.**
ODA is the conversational AI layer for Oracle SaaS and custom app integrations.
It requires a private VCN-attached instance, Vault for OAuth client secrets,
IAM for bot operators and channel webhook callers, and optionally a GenAI
backend for LLM-powered intent handling.

**What it deploys.**

| Resource | Notes |
| --- | --- |
| ODA instance | Enterprise edition; private endpoint |
| Vault secret | OAuth client secret for channel webhooks |
| IAM policies | ODA administrator, bot developer, channel caller |
| NSG | HTTPS from app subnet and webhook callback sources |
| Optional: GenAI integration | Wires ODA LLM service to the `genai-private` endpoint |

**Inputs to decide.**

- ODA edition (development vs enterprise)
- Channel type: Web, MS Teams, Slack, or custom webhook
- Whether to enable LLM backend via GenAI private endpoint
- Webhook callback CIDR allowlist

**Outputs and hand-off.**

```text
oda_instance_id
oda_endpoint_url
vault_secret_id
```

---

## Phase 7 - Security & Governance Automation

Blueprints that extend the compliance baseline with automated detection,
response, and data governance.

---

### Security Posture Automation

| Attribute | Value |
| --- | --- |
| Folder | `blueprints/compliance/security-posture/` |
| Depends on | Core Landing Zone (Cloud Guard and logging baseline) |

**Why this exists.**
Core Landing Zone enables Cloud Guard and basic alarms. Enterprises need
custom detector recipes, Vulnerability Scanning scheduled targets, and
event-driven auto-remediation via OCI Functions - closing the loop from
detection to fix without human intervention.

**What it deploys.**

| Resource | Notes |
| --- | --- |
| Cloud Guard custom detector recipe | Customer-managed rules layered on Oracle-managed |
| Cloud Guard custom responder recipe | Automated remediation actions |
| Vulnerability Scanning targets | Compute, container images, host scans |
| Event rule -> Functions trigger | Cloud Guard problem -> auto-remediation function |
| Object Storage report bucket | Scheduled scan and problem exports |
| IAM policies | Security admin group, responder service principal |

**ASCII Architecture.**

```text
 OCI Resources (Compute / Containers / Config)
       |
       v
 Cloud Guard (custom detector + responder recipes)
 |--- Problem detected
 |         |
 |         v
 |    OCI Events Rule
 |         |
 |         v
 |    Functions (auto-remediation)
 `--- Problem report -> Object Storage bucket

 Vulnerability Scanning (scheduled)
 `--- Report -> Object Storage bucket
```

**Inputs to decide.**

- Which detector rule categories to enable (config, activity, threat intel)
- Auto-remediation actions: notify-only vs enforce (stop instance, revoke key)
- Scan schedule and target compartments
- Report retention and bucket lifecycle

**Outputs and hand-off.**

```text
cloud_guard_target_id
detector_recipe_id
responder_recipe_id
vulnerability_scanning_target_id
report_bucket_name
```

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

**ASCII Architecture.**

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

## Phase 8 - Industry Verticals

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

**ASCII Architecture.**

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

## Phase 9 - Next Architecture Backlog

These are good next candidates after the current Phase 4-8 queue. They fit the
repo because they can reuse the existing contracts: Core for governance,
networking blueprints for traffic paths, extension blueprints for managed
services, and local ASCII architecture for design review.

| Priority | Blueprint | Folder | Why It Fits |
| --- | --- | --- | --- |
| 1 | Public Edge and Ingress Zone | `blueprints/networking/public-edge-ingress/` | Completes the north-south story with DNS, WAF, public/private load balancing, certificates, and route-to-app hand-off. |
| 2 | Event-Driven Application Platform | `blueprints/extensions/event-driven-platform/` | Composes Events, Service Connector Hub, Streaming, Functions, Notifications, and Object Storage into one reusable async pattern. |
| 3 | Batch and Queue Workers | `blueprints/extensions/batch-workers/` | Covers scheduled and burst compute patterns that do not fit OKE, Functions, or Container Instances. |
| 4 | Object Storage Data Lakehouse | `blueprints/data-platform/object-storage-lakehouse/` | Adds the missing data lake foundation: buckets, KMS, private endpoints, lifecycle, logs, and optional query/processing hooks. |
| 5 | OpenSearch Search and Vector Platform | `blueprints/data-platform/opensearch/` | Useful as a standalone search, logging, and vector index platform, not only as an AI Agents dependency. |
| 6 | Redis Cache Landing Zone | `blueprints/extensions/redis-cache/` | Adds the common low-latency cache/session layer expected by app teams. |
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

**ASCII Architecture.**

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

**ASCII Architecture.**

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

**ASCII Architecture.**

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

**ASCII Architecture.**

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

**ASCII Architecture.**

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

### Redis Cache Landing Zone

| Attribute | Value |
| --- | --- |
| Folder | `blueprints/extensions/redis-cache/` |
| Depends on | Core Landing Zone; VCN from any networking blueprint |

**Why this exists.**
Most real application stacks eventually need a cache or session store. This
blueprint gives app teams a private Redis-compatible cache with subnet, NSG,
secrets, alarms, and ownership boundaries already handled.

**What it deploys.**

| Resource | Notes |
| --- | --- |
| Redis cache cluster | Private endpoint and configurable capacity |
| NSG | App subnet access only |
| Vault secret | Auth token or integration secret where used |
| IAM policies | Cache admins and app readers/writers |
| Monitoring alarms | Memory pressure, evictions, connection saturation |

**ASCII Architecture.**

```text
Application Tier
      |
      v
Redis Cache (private endpoint)
 |--- NSG app-only access
 |--- Vault secret
 `--- Monitoring alarms
```

**Inputs to decide.**

- Cache capacity, shard/replica model, and maintenance window
- Auth secret handling and rotation owner
- App subnet allowlist and NSG rules
- Eviction policy and memory alarm thresholds
- Whether this is session state, app cache, or queue-adjacent cache

**Outputs and hand-off.**

```text
redis_cache_id
redis_endpoint
nsg_id
vault_secret_id
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

**ASCII Architecture.**

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

**ASCII Architecture.**

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

**ASCII Architecture.**

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

## Implementation Order Summary

```text
Core Landing Zone (implemented)
  |
  |-- Already Implemented --------------------------------------------
  |   |--- blueprints/data-platform/autonomous-database/
  |   |--- blueprints/ai/genai-private/
  |   |--- blueprints/devops/oci-devops-pipeline/
  |   |--- blueprints/extensions/observability/
  |   |--- blueprints/extensions/oic/
  |   |--- blueprints/extensions/oac/
  |   |--- blueprints/extensions/container-instances/
  |   |--- blueprints/data-platform/postgresql/
  |   |--- blueprints/compliance/healthcare-pci/
  |   `--- blueprints/extensions/oke-service-mesh/
  |
  |-- Phase 4 (next up) ----------------------------------------------
  |   |--- blueprints/operations/cost-optimization/
  |   `--- blueprints/data-platform/apex-adw/
  |
  |-- Phase 5 (AI/ML Platform) ---------------------------------------
  |   |--- blueprints/ai/data-science/
  |   |--- blueprints/ai/agents/
  |   `--- blueprints/data-platform/mysql-heatwave/
  |
  |-- Phase 6 (Platform Services) ------------------------------------
  |   |--- blueprints/extensions/functions/
  |   |--- blueprints/data-platform/goldengate/
  |   `--- blueprints/extensions/digital-assistant/
  |
  |-- Phase 7 (Security and Governance) ------------------------------
  |   |--- blueprints/compliance/security-posture/
  |   |--- blueprints/data-platform/data-catalog/
  |   `--- blueprints/extensions/vault-advanced/
  |
  |-- Phase 8 (Industry Verticals) -----------------------------------
  |   |--- blueprints/industry/financial-services/
  |   |--- blueprints/industry/hpc-gpu/
  |   `--- blueprints/compliance/public-sector/
  |
  `-- Phase 9 (Next Architecture Backlog) ----------------------------
      |--- blueprints/networking/public-edge-ingress/
      |--- blueprints/extensions/event-driven-platform/
      |--- blueprints/extensions/batch-workers/
      |--- blueprints/data-platform/object-storage-lakehouse/
      |--- blueprints/data-platform/opensearch/
      |--- blueprints/extensions/redis-cache/
      |--- blueprints/operations/backup-resilience/
      |--- blueprints/industry/weblogic-platform/
      `--- blueprints/industry/vmware-hybrid-migration/
```

## Updating the Deployment Menu

When each blueprint is implemented, add it to:

1. `README.md` - Deployment Menu table under the appropriate section
2. `docs/DEPLOYMENT-PATTERN-CATALOG.md` - full pattern catalog
3. `blueprints/<new-family>/README.md` - create if the family is new

New families introduced by this roadmap:

| New Family | First Blueprint | Status |
| --- | --- | --- |
| `blueprints/ai/` | `genai-private/` | Implemented |
| `blueprints/devops/` | `oci-devops-pipeline/` | Implemented |
| `blueprints/operations/` | `cost-optimization/` | Planned (Phase 4) |
