# OCI Landing Zones - Implementation Roadmap

Author: Leandro Michelino | ACE | <leandro.michelino@oracle.com>

This document defines roadmap blueprint families and deployments, organized by
implementation priority and dependency order. The first eight recommendations
are now implemented as deployable blueprint folders:

```text
blueprints/data-platform/autonomous-database/
blueprints/ai/genai-private/
blueprints/devops/oci-devops-pipeline/
blueprints/extensions/observability/
blueprints/extensions/oic/
blueprints/extensions/oac/
blueprints/compliance/healthcare-pci/
blueprints/extensions/oke-service-mesh/
```

Each planned blueprint will follow the same folder contract as existing blueprints:

```text
blueprints/<family>/<deployment>/
|-- README.md                  Human-friendly deployment notes
|-- architecture/README.md     Detailed ASCII architecture
|-- main.tf                    Terraform composition
|-- variables.tf               Input contract
|-- outputs.tf                 Named hand-off values
|-- providers.tf               OCI provider configuration
|-- versions.tf                Terraform / provider constraints
|-- terraform.tfvars.example   Local input example
`-- ansible/
    |-- plan.yml
    |-- apply.yml
    `-- destroy.yml
```

---

## Phase 1 - High Demand, Clear Pattern

Both blueprints have an obvious OCI resource shape, fill the most-requested gaps in the repo,
and need only the Core Landing Zone as a prerequisite. Build these first.

---

### Autonomous Database (ATP / ADW)

| Attribute | Value |
| --- | --- |
| Folder | `blueprints/data-platform/autonomous-database/` |
| Depends on | Core Landing Zone (compartment, IAM, Vault/KMS) |
| Terraform modules | `modules/autonomous-database`, `modules/networking` (existing) |

**Why this exists.**
No database blueprint is in the repo today. Autonomous Database is the most common OCI
database pattern by volume, and every data or application landing zone eventually needs one.

**What it deploys.**

| Resource | Notes |
| --- | --- |
| Autonomous Database instance | ATP (OLTP) or ADW (analytics), shared or dedicated, ECPU shape |
| Private endpoint | No public IP; accessible only from within the VCN |
| Network Security Group | Allows 1521 / 1522 from app subnets only |
| Customer-managed encryption key | Vault/KMS integration, key rotation policy |
| IAM policies | DBA group (full), read-only group (query), app group (connect) |
| Optional: scheduled backup | Configurable retention and backup destination |
| Optional: auto-scaling | ECPU-based auto-scaling flag |

**ASCII Architecture.**

```text
 App Subnet (VCN)
       |
       | private endpoint (port 1521/1522, NSG-controlled)
       v
 +-----------------------------------------+
 | Autonomous Database                     |
 | |--- Vault/KMS (customer-managed key)   |
 | |--- NSG (ingress from app subnet only) |
 | `--- IAM (DBA / read-only / app)        |
 +-----------------------------------------+
       |
       v
 Object Storage (automated backups, private)
```

**Inputs to decide.**

- ATP (OLTP) vs ADW (analytics / data warehouse)
- Shared (serverless) vs dedicated infrastructure
- ECPU count and auto-scaling upper bound
- Backup retention window and destination bucket
- Whether to expose ORDS for APEX use (links to Phase 4 `apex-adw` blueprint)

**Outputs and hand-off.**

```text
autonomous_database_id
autonomous_database_connection_string
private_endpoint_ip
nsg_id
kms_key_id
```

---

### OCI Generative AI Landing Zone

| Attribute | Value |
| --- | --- |
| Folder | `blueprints/ai/genai-private/` |
| New family | `blueprints/ai/` - introduce this folder |
| Depends on | Core Landing Zone (compartment, IAM, Vault/KMS) |
| Terraform modules | `modules/networking` (existing), new `modules/genai` |

**Why this exists.**
OCI Generative AI is the highest-demand OCI service in 2025. Customers need private endpoint
access, scoped IAM (who can call which model), audit logging, and Object Storage for prompt
and response archiving - from day one, not retrofitted later.

**What it deploys.**

| Resource | Notes |
| --- | --- |
| OCI Generative AI private endpoint | No public access; VCN-routed only |
| IAM policies | Per-group model access: read-only inference vs full (fine-tuning) |
| Vault/KMS | Optional customer-managed key for stored embeddings or fine-tune data |
| Object Storage bucket | Private bucket for prompt logs, response archives, and fine-tune datasets |
| VCN Service Gateway | Routes OCI service traffic without internet |
| Logging | Audit logging for all inference calls |

**ASCII Architecture.**

```text
 App / Notebook Subnet (VCN)
       |
       | private endpoint (service gateway route)
       v
 +---------------------------------------------+
 | OCI Generative AI                           |
 | |--- IAM (inference group / fine-tune group) |
 | |--- Audit logging (all calls)              |
 | `--- Vault/KMS (optional embedding key)     |
 +---------------------------------------------+
       |
       v
 Object Storage (private)
 |--- prompt-response-archive/
 `--- fine-tune-datasets/
```

**Inputs to decide.**

- Which model families to expose (Cohere, Meta Llama, etc.)
- Inference-only vs fine-tuning access per group
- Whether to enable dedicated AI cluster or use shared capacity
- Log retention and Object Storage lifecycle policy
- Whether to attach to an OKE cluster or standalone app subnet

**Outputs and hand-off.**

```text
genai_endpoint_url
private_endpoint_id
iam_inference_policy_id
log_bucket_name
```

---

## Phase 2 - Foundation Tooling

These two blueprints fill tooling gaps that every serious enterprise deployment eventually
hits. They depend on Core and optionally connect to Phase 1 outputs.

---

### OCI DevOps Pipeline

| Attribute | Value |
| --- | --- |
| Folder | `blueprints/devops/oci-devops-pipeline/` |
| New family | `blueprints/devops/` - introduce this folder |
| Depends on | Core Landing Zone; optionally OKE (extensions) |
| Terraform modules | New `modules/devops` |

**Why this exists.**
CI/CD is foundational. Every team deploying to OKE, Functions, or Compute needs a repeatable
pipeline. OCI DevOps is native, IAM-integrated, and avoids the complexity of bringing an
external CI/CD tool into a new tenancy.

**What it deploys.**

| Resource | Notes |
| --- | --- |
| OCI Code Repository | Git repository hosted in the tenancy |
| Build Pipeline | Multi-stage build with managed build runner |
| Artifact Registry | Container image or generic artifact storage |
| Deployment Pipeline | Rolling or blue/green deployment to OKE or Compute |
| Notification topic | ONS topic for build/deploy success and failure alerts |
| IAM policies | DevOps service, build runner, and deployment runner policies |
| Optional: trigger | GitHub mirror trigger or OCI Events trigger |

**ASCII Architecture.**

```text
 Developer Push
       |
       v
 OCI Code Repository
       |
       v (trigger)
 Build Pipeline
 |--- Stage 1: Managed Build (compile, test, scan)
 |--- Stage 2: Push to Artifact Registry
 `--- Stage 3: Trigger Deployment Pipeline
                    |
                    v
           Deployment Pipeline
           |--- OKE (rolling / blue-green)
           `--- Compute / Functions
                    |
                    v
           ONS Notification (success / failure)
```

**Inputs to decide.**

- Build runner shape (managed vs custom)
- Target: OKE cluster ID, Compute instance group, or Function
- Deployment strategy: rolling, canary, or blue/green
- Whether to enable GitHub or GitLab mirror as the upstream remote
- Artifact Registry compartment and retention policy

**Outputs and hand-off.**

```text
devops_project_id
code_repository_ssh_url
artifact_registry_url
build_pipeline_id
deployment_pipeline_id
```

---

### Observability Platform

| Attribute | Value |
| --- | --- |
| Folder | `blueprints/extensions/observability/` |
| Depends on | Core Landing Zone (logging and monitoring baseline) |
| Terraform modules | New `modules/observability` |

**Why this exists.**
Core Landing Zone enables basic logging, monitoring alarms, and Cloud Guard. Enterprises
need a deeper layer: log analytics with query capability, application performance
monitoring, and database/infrastructure insight - all in one scoped deployment.

**What it deploys.**

| Resource | Notes |
| --- | --- |
| Logging Analytics log group | Scoped to tenancy or compartment |
| Log Analytics log source mappings | Maps OCI Audit, VCN Flow Logs, and OS syslog |
| APM domain | Application Performance Monitoring for app instrumentation |
| Ops Insights | Database and host capacity and performance analysis |
| Monitoring alarm composite rules | CPU, memory, disk, and error-rate thresholds |
| ONS topic and subscriptions | Email or PagerDuty integration |

**ASCII Architecture.**

```text
 OCI Resources (VCN Flow Logs, Audit, OS Agent)
       |
       v
 Logging Analytics
 |--- Log Groups (audit / vcn-flow / app)
 |--- Dashboards (security / network / app)
 `--- Scheduled saved searches (anomaly detection)

 Application (instrumented with APM agent)
       |
       v
 APM Domain
 |--- Trace explorer
 `--- Synthetic monitors

 Databases / Compute
       |
       v
 Ops Insights
 |--- SQL analysis
 |--- Capacity planning
 `--- News reports

 Alarms -> ONS -> Email / PagerDuty
```

**Inputs to decide.**

- Log retention window for each log group
- APM agent deployment method (OKE DaemonSet vs Compute cloud-init)
- Ops Insights target: Autonomous DB, DB System, or host
- Alarm notification destinations

**Outputs and hand-off.**

```text
log_analytics_namespace
apm_domain_id
apm_data_upload_endpoint
ops_insights_warehouse_id
monitoring_alarm_ids
```

---

## Phase 3 - Enterprise Patterns

These blueprints target common enterprise service layers and regulated-industry compliance
shapes. They build on Core and Phase 1-2 outputs.

---

### Oracle Integration Cloud (OIC)

| Attribute | Value |
| --- | --- |
| Folder | `blueprints/extensions/oic/` |
| Depends on | Core Landing Zone; VCN from any networking blueprint |

**Why this exists.**
OIC is the integration backbone for most Oracle ERP and SaaS customers. It needs a private
VCN attachment, scoped IAM, Vault for connection credentials, and a clear output for other
teams to consume the integration endpoint.

**What it deploys.**

| Resource | Notes |
| --- | --- |
| OIC instance | Standard or Enterprise edition, private endpoint |
| Private endpoint | Accessible from VCN only |
| Vault secret | OIC admin credentials or OAuth client secret |
| NSG | Allows HTTPS from app subnets; blocks all other ingress |
| IAM policies | Integration admin, monitoring read, connector access |

**Inputs to decide.**

- OIC edition (Standard vs Enterprise) and message pack count
- Disaster recovery replica region (optional)
- Whether to enable File Server (embedded FTP) feature
- VPN or FastConnect requirement for on-premises adapter connectivity

**Outputs and hand-off.**

```text
oic_instance_id
oic_endpoint_url
private_endpoint_ip
vault_secret_id (admin credentials)
```

---

### Oracle Analytics Cloud (OAC)

| Attribute | Value |
| --- | --- |
| Folder | `blueprints/extensions/oac/` |
| Depends on | Core Landing Zone; Autonomous DB (Phase 1) for data source |

**What it deploys.**
Private OAC instance with VLAN attachment, private endpoint, Vault for connection
credentials, NSG allowing HTTPS from analytics subnet, and IAM for analytics admin and
consumer groups.

**Inputs to decide.**

- OAC edition and OCPU count
- Private access channel vs public with IP allowlist
- Autonomous DB connection (from Phase 1 outputs)
- Whether to enable Embedded ML and AI features

**Outputs and hand-off.**

```text
oac_instance_id
oac_endpoint_url
private_endpoint_ip
```

---

### Healthcare / PCI Compliance

| Attribute | Value |
| --- | --- |
| Folder | `blueprints/compliance/healthcare-pci/` |
| Depends on | Core Landing Zone; extends SCCA and Zero Trust patterns |

**What it deploys.**
Core Landing Zone baseline tightened for regulated environments: mandatory defined tags for
data classification, stricter IAM (no wildcards), dedicated Vault keys per data class, OCI
Security Zones with custom recipes, Logging Analytics retention enforcement, and a review
checklist tuned for HIPAA and PCI DSS control families.

**Inputs to decide.**

- Compliance target: HIPAA, PCI DSS, or both
- Data classification tag taxonomy
- Log retention window (HIPAA: 6 years, PCI DSS: 1 year minimum)
- Break-glass access model and audit trail destination

---

### Service Mesh on OKE

| Attribute | Value |
| --- | --- |
| Folder | `blueprints/extensions/oke-service-mesh/` |
| Depends on | Core Landing Zone; OKE (extensions) |

**What it deploys.**
OCI Service Mesh or Istio deployed into the existing OKE cluster: mesh control plane,
sidecar injection namespace configuration, mTLS peer authentication policy, APM integration
for distributed tracing, and Grafana/Prometheus if self-managed observability is preferred.

**Inputs to decide.**

- OCI Service Mesh (managed) vs self-managed Istio
- mTLS mode: strict or permissive
- Whether APM domain comes from Phase 2 Observability outputs or a new instance
- Ingress gateway: OCI Load Balancer or NGINX

---

## Phase 4 - Specialized

These blueprints serve specific runtime or operational needs. They are lower urgency but
complete the catalog meaningfully.

---

### OCI Container Instances

| Attribute | Value |
| --- | --- |
| Folder | `blueprints/extensions/container-instances/` |
| Depends on | Core Landing Zone; VCN from any networking blueprint |

**Why this exists.**
Not every workload needs an OKE cluster. Container Instances gives serverless container
runtime on OCI with private VCN attachment, OCIR image pull, Vault secret injection, and
IAM - without the cluster control plane overhead.

**What it deploys.**
Container Instance with private VCN subnet, OCIR pull secret from Vault, NSG for workload
ingress and egress, and IAM policies for the Container Instances service principal.

---

### Cost Optimization Blueprint

| Attribute | Value |
| --- | --- |
| Folder | `blueprints/operations/cost-optimization/` |
| New family | `blueprints/operations/` - introduce this folder |
| Depends on | Core Landing Zone (tagging, budgets baseline) |

**Why this exists.**
Multi-team tenancies without explicit cost attribution drift into uncontrolled spend. This
blueprint formalizes tagging policy enforcement, per-compartment budgets, OCI Optimizer
recommendations review, and alert thresholds with ONS - turning cost governance from a
manual review into an automated control.

**What it deploys.**
Defined tag namespace with cost-centre and owner tags enforced by tag defaults, per-
compartment budgets with alert thresholds, OCI Optimizer recommendation subscriptions,
and a Monitoring composite alarm for budget overrun.

---

### Oracle APEX on Autonomous Database

| Attribute | Value |
| --- | --- |
| Folder | `blueprints/data-platform/apex-adw/` |
| Depends on | Core Landing Zone; Autonomous DB (Phase 1) |

**Why this exists.**
APEX on ADW is the dominant pattern for internal OCI low-code applications. It extends the
Phase 1 Autonomous DB blueprint by enabling APEX workspace provisioning, ORDS (Oracle REST
Data Services) endpoint configuration, private load balancer for ORDS, and Vault for admin
credentials - producing a deployable APEX platform from a single `terraform apply`.

**What it deploys.**
ORDS endpoint on the existing ADW instance, private Load Balancer with HTTPS listener,
NSG allowing HTTPS from app subnet, APEX workspace bootstrap, and Vault secret for the
APEX admin account.

---

## Implementation Order Summary

```text
Core Landing Zone (already implemented)
  |
  |-- Phase 1 ------------------------------------------------------
  |   |--- blueprints/data-platform/autonomous-database/
  |   `--- blueprints/ai/genai-private/
  |
  |-- Phase 2 ------------------------------------------------------
  |   |--- blueprints/devops/oci-devops-pipeline/
  |   `--- blueprints/extensions/observability/
  |
  |-- Phase 3 ------------------------------------------------------
  |   |--- blueprints/extensions/oic/
  |   |--- blueprints/extensions/oac/
  |   |--- blueprints/compliance/healthcare-pci/
  |   `--- blueprints/extensions/oke-service-mesh/
  |
  `-- Phase 4 ------------------------------------------------------
      |--- blueprints/extensions/container-instances/
      |--- blueprints/operations/cost-optimization/
      `--- blueprints/data-platform/apex-adw/
```

Each phase can begin as soon as Core is stable. Phases 3 and 4 benefit from Phase 1-2
outputs (Autonomous DB ID, APM domain ID, OKE cluster ID) but can be started independently
with externally supplied input values.

## New Folder Families

This roadmap introduces three new top-level blueprint families not yet in the repo:

| New Family | First Blueprint |
| --- | --- |
| `blueprints/ai/` | `genai-private/` |
| `blueprints/devops/` | `oci-devops-pipeline/` |
| `blueprints/operations/` | `cost-optimization/` |

Each new family follows the same catalogue pattern as existing ones: a family-level
`README.md` that explains when to choose blueprints in that family, and individual
deployment folders underneath.

## Updating The Deployment Menu

When each blueprint is implemented, add it to:

1. `README.md` - Deployment Menu table under the appropriate section
2. `docs/DEPLOYMENT-PATTERN-CATALOG.md` - full pattern catalog
3. `blueprints/<new-family>/README.md` - create if family is new

For new families (`ai/`, `devops/`, `operations/`), also add a row to the
Deployment Categories table in `README.md`.
