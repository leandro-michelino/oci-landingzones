# OCI Object Storage — Product Proposals

> Proposals for client-facing solutions built on top of OCI Object Storage.
> Each section covers architecture, components, implementation steps, sizing, and commercialization guidance.

---

## Table of Contents

1. [Data Lake / Lakehouse](#1-data-lake-lakehouse)
2. [Event-Driven Processing](#2-event-driven-processing)
3. [Backup & DR Cross-Region](#3-backup-dr-cross-region)
4. [WORM Compliance Vault](#4-worm-compliance-vault)
5. [CDN + Static Asset Distribution](#5-cdn-static-asset-distribution)
6. [Sizing Reference](#6-sizing-reference)
7. [Commercialization Cheat Sheet](#7-commercialization-cheat-sheet)

---

## 1. Data Lake / Lakehouse

### Problem Statement

Clients accumulate data across on-premises databases, SaaS platforms, and IoT streams but lack a unified, cost-effective storage layer for analytics. Traditional data warehouses are expensive and rigid for raw/unstructured data.

### Proposed Architecture

```
Fontes de Dados
  ├── DB On-Premises        → GoldenGate CDC
  ├── Aplicações SaaS       → OCI Data Integration
  ├── Streams / IoT         → OCI Streaming (Kafka-compatible)
  └── Arquivos / FTP        → OCI Data Integration

Object Storage (Data Lake)
  ├── Bucket: raw/          ← Landing Zone (dados brutos, sem transformação)
  ├── Bucket: curated/      ← Processado e validado (Parquet / ORC)
  └── Bucket: analytics/    ← Pronto para consumo (tabelas Iceberg/Delta)

Processamento
  ├── OCI Data Flow (Spark) ← Transformações batch e near-real-time
  └── OCI Data Catalog      ← Catalogação, linhagem, metadados

Governança
  ├── Oracle Data Safe      ← Mascaramento e classificação de dados sensíveis
  └── OCI Audit + Events    ← Trilha de auditoria de acesso

Consumo
  ├── Autonomous Database   ← External Tables sobre Object Storage
  ├── OCI Analytics Cloud   ← Dashboards e exploração self-service
  └── Power BI / Tableau    ← Conectores JDBC/ODBC
```

### Key OCI Services

| Serviço | Papel |
|---|---|
| OCI Object Storage | Armazenamento centralizado, custo baixo por GB |
| OCI Data Integration | ETL/ELT visual, conectores nativos |
| OCI Streaming | Ingestão de eventos em tempo real |
| GoldenGate | CDC para bancos Oracle e não-Oracle |
| OCI Data Flow | Jobs Spark gerenciados (sem cluster para gerenciar) |
| OCI Data Catalog | Inventário, linhagem e tags de metadados |
| Autonomous Database | Consultas SQL direto sobre Object Storage (External Tables) |
| OCI Analytics Cloud | BI embarcado, dashboards operacionais |

### Implementation Steps

#### Phase 1 — Foundation (Weeks 1–3)
1. Provision tenancy structure: compartments `data-lake-dev`, `data-lake-prod`.
2. Create three Object Storage buckets with lifecycle policies:
   - `raw/` → Standard tier, lifecycle to Infrequent Access after 30 days.
   - `curated/` → Standard tier, no auto-tiering.
   - `analytics/` → Standard tier, versioning enabled.
3. Define IAM policies: separation between ingest role, transform role, and read-only consumer role.
4. Enable Object Storage server-side encryption with customer-managed keys (OCI Vault).

#### Phase 2 — Ingestion (Weeks 3–6)
5. Deploy OCI Data Integration workspace; create pipelines for each source system.
6. Configure GoldenGate extract/replicate for Oracle DB sources.
7. Create OCI Streaming topics for IoT/event sources; implement Kafka producers on client side.
8. Land all data into `raw/` using prefix structure: `raw/{source}/{year}/{month}/{day}/`.

#### Phase 3 — Processing (Weeks 6–9)
9. Write Spark jobs in OCI Data Flow:
   - Cleansing / deduplication job: `raw/` → `curated/`.
   - Aggregation / feature engineering job: `curated/` → `analytics/`.
10. Schedule jobs via OCI Data Flow Application scheduling or OCI Resource Scheduler.
11. Register datasets in OCI Data Catalog with business glossary tags.

#### Phase 4 — Consumption (Weeks 9–12)
12. Create External Tables in Autonomous Database pointing to `analytics/` bucket.
13. Connect OCI Analytics Cloud to Autonomous Database.
14. Deliver Power BI / Tableau connectors with pre-built report templates.

#### Phase 5 — Governance & Hardening
15. Enable Oracle Data Safe on Autonomous Database; classify sensitive columns.
16. Configure OCI Audit log export to a dedicated `audit-logs/` bucket with retention lock.
17. Set up OCI Monitoring dashboards for pipeline SLAs (job success rate, latency p99).

### Terraform Snippet — Bucket Structure

```hcl
resource "oci_objectstorage_bucket" "raw" {
  compartment_id = var.compartment_id
  namespace      = data.oci_objectstorage_namespace.ns.namespace
  name           = "${var.prefix}-raw"
  access_type    = "NoPublicAccess"
  versioning     = "Disabled"

  defined_tags = var.defined_tags
}

resource "oci_objectstorage_object_lifecycle_policy" "raw_lifecycle" {
  bucket    = oci_objectstorage_bucket.raw.name
  namespace = data.oci_objectstorage_namespace.ns.namespace

  rules {
    name        = "tier-to-infrequent"
    action      = "INFREQUENT_ACCESS"
    is_enabled  = true
    object_name_filter { inclusion_prefixes = ["/"] }
    time_amount = 30
    time_unit   = "DAYS"
  }

  rules {
    name        = "archive-old-data"
    action      = "ARCHIVE"
    is_enabled  = true
    object_name_filter { inclusion_prefixes = ["/"] }
    time_amount = 365
    time_unit   = "DAYS"
  }
}

resource "oci_objectstorage_bucket" "curated" {
  compartment_id = var.compartment_id
  namespace      = data.oci_objectstorage_namespace.ns.namespace
  name           = "${var.prefix}-curated"
  access_type    = "NoPublicAccess"
  versioning     = "Disabled"
}

resource "oci_objectstorage_bucket" "analytics" {
  compartment_id = var.compartment_id
  namespace      = data.oci_objectstorage_namespace.ns.namespace
  name           = "${var.prefix}-analytics"
  access_type    = "NoPublicAccess"
  versioning     = "Enabled"
}
```

### Risks & Mitigations

| Risk | Mitigation |
|---|---|
| Schema drift from source systems | OCI Data Catalog schema versioning; fail-fast validation in Data Flow |
| Cost overrun on Data Flow compute | Right-size Data Flow drivers/executors and benchmark job duration; do not assume Compute preemptible capacity is a Data Flow option |
| PII exposure in raw bucket | Oracle Data Safe masking before landing to curated; strict IAM on raw/ |
| Cross-region data residency requirements | Keep all buckets in client home region; use VCN Service Gateway |

---

## 2. Event-Driven Processing

### Problem Statement

Clients receive files asynchronously (invoices, contracts, medical images, sensor exports) and need near-real-time processing without managing a persistent compute layer. Traditional polling-based approaches introduce latency and wasted compute.

### Proposed Architecture

```
Origem
  ├── Sistema Externo  ─┐
  └── Usuário / App    ─┴→ Object Storage (Bucket: input/)
                              │
                              ▼ ObjectCreated event
                         OCI Events
                              │
                              ▼ Trigger
                         OCI Functions (processing logic)
                              │
                   ┌──────────┼──────────┐
                   ▼          ▼          ▼
           AI Services   Object Storage  Downstream
           ├─ Document   (Bucket:        ├─ Autonomous DB
           │  Understanding output/)     ├─ OCI Notifications
           └─ Language /                 └─ OCI Streaming
              Vision
                              │
                   ┌──────────┴──────────┐
                   ▼                     ▼
             OCI Logging           OCI Monitoring
                                    + Alarms
```

### Use Case Examples

| Vertical | Input File | Processing | Output |
|---|---|---|---|
| Financeiro | XML NF-e | Parse + validate CNPJ | Insert into ERP DB |
| Saúde | PDF laudo médico | OCR + entity extraction | Structured JSON in DB |
| RH | PDF currículo | AI Language NLP | Candidate profile in ATS |
| Logística | CSV manifesto | Validate + enrich | Route planner API call |
| Seguros | Imagem sinistro | Vision damage detection | Claims score in DB |

### Key OCI Services

| Serviço | Papel |
|---|---|
| OCI Object Storage | Recebimento e saída de arquivos |
| OCI Events | Detecção de novos objetos (zero polling) |
| OCI Functions | Lógica de processamento serverless (Python / Java / Node) |
| OCI AI Document Understanding | OCR, extração de tabelas, classificação de documentos |
| OCI Language | Extração de entidades, análise de sentimento, detecção de idioma |
| OCI Vision | Análise de imagens, detecção de objetos |
| Autonomous Database | Persistência de dados estruturados resultantes |
| OCI Notifications | Alertas por e-mail / SMS / PagerDuty |
| OCI Streaming | Publicação de eventos para downstream consumers |
| OCI Logging | Logs estruturados das execuções de Functions |
| OCI Monitoring + Alarms | Alertas sobre falhas, latência e throughput |

### Implementation Steps

#### Phase 1 — Infrastructure (Weeks 1–2)
1. Create two buckets: `{prefix}-input` and `{prefix}-output`.
2. Create OCI Functions Application in a private subnet (VCN with Service Gateway).
3. Configure IAM Dynamic Group for the Functions application with policies to:
   - Read from `input` bucket.
   - Write to `output` bucket.
   - Call AI Services.
   - Write to target Autonomous Database (if applicable).

#### Phase 2 — Function Development (Weeks 2–4)
4. Implement function handler (Python example):

```python
import io, json, oci
from fdk import response

def handler(ctx, data: io.BytesIO = None):
    body = json.loads(data.getvalue())
    bucket = body["data"]["additionalDetails"]["bucketName"]
    object_name = body["data"]["resourceName"]

    signer = oci.auth.signers.get_resource_principals_signer()
    object_storage = oci.object_storage.ObjectStorageClient(config={}, signer=signer)
    namespace = object_storage.get_namespace().data
    obj = object_storage.get_object(namespace, bucket, object_name)
    content = obj.data.content

    # Call AI Document Understanding, Language, Vision, etc.
    result = process(content)

    object_storage.put_object(
        namespace,
        f"{bucket}-output",
        f"processed/{object_name}.json",
        json.dumps(result)
    )
    return response.Response(ctx, response_data=json.dumps({"status": "ok"}))
```

5. Write unit tests; deploy via OCI DevOps Pipeline or `fn deploy`.

#### Phase 3 — Event Wiring (Week 4)
6. Create OCI Events rule on `input` bucket:
   - Event type: `com.oraclecloud.objectstorage.createobject`
   - Optional prefix filter (e.g., only `invoices/` triggers function A).
   - Action: invoke OCI Function.
7. Test end-to-end with a sample file upload.

#### Phase 4 — Observability (Week 5)
8. Enable structured logging in OCI Functions; ship to OCI Logging.
9. Create OCI Monitoring alarms:
   - `FunctionsErrors > 0` → OCI Notification → email/PagerDuty.
   - `FunctionsDuration p99 > 30s` → performance regression alert.
10. Build OCI Logging Analytics dashboard for processing volume and error rates.

#### Phase 5 — Hardening (Week 6)
11. Dead-letter pattern: on function failure, move failed file to `{prefix}-dlq/` bucket.
12. Add idempotency key per object (use object ETag or custom metadata) to prevent double-processing.
13. Set Pre-Authenticated Request (PAR) TTL for external uploads — avoid credential sharing.

### Terraform Snippet — Events Rule

```hcl
resource "oci_events_rule" "object_created" {
  compartment_id = var.compartment_id
  display_name   = "${var.prefix}-object-created-trigger"
  is_enabled     = true

  condition = jsonencode({
    eventType = ["com.oraclecloud.objectstorage.createobject"],
    data = {
      additionalDetails = {
        bucketName = [oci_objectstorage_bucket.input.name]
      }
    }
  })

  actions {
    actions {
      action_type = "FAAS"
      is_enabled  = true
      function_id = oci_functions_function.processor.id
    }
  }
}
```

### Risks & Mitigations

| Risk | Mitigation |
|---|---|
| Function cold start latency | Use provisioned concurrency for latency-sensitive flows |
| Large files exceeding Function memory | Split at upload time; use multipart upload + chunked processing |
| Event delivery failure | OCI Events retries up to 60 min; implement DLQ bucket for missed events |
| Cost spike on high volume | Set OCI Quotas on Function invocations; rate-limit uploads at API layer |
| AI Service throttling | Exponential backoff; cache results for duplicate files by SHA-256 |

---

## 3. Backup & DR Cross-Region

### Problem Statement

Clients need documented RPO/RTO for compliance (ISO 27001, BACEN, SOC 2) but lack a cost-effective strategy beyond expensive active-active setups.

### Architecture Overview

```
Primary Region                    Secondary Region (DR)
────────────────                  ──────────────────────
Object Storage                    Object Storage
  ├── app-data/   ──replication──▶   ├── app-data/
  ├── db-backups/ ──replication──▶   ├── db-backups/
  └── logs/                          └── logs/

OCI Vault (keys)  ──cross-region──▶ OCI Vault replica

OCI Autonomous DB ──Data Guard────▶ Autonomous DB Standby
```

### Implementation Steps

1. Enable **Object Storage Cross-Region Replication** on target buckets (asynchronous; measure replication lag and define an application-specific RPO).
2. Configure the supported **Autonomous Data Guard** deployment for the selected database edition and regions. Cross-region protection is asynchronous; validate its documented and measured RPO/RTO rather than assuming RPO = 0.
3. Create **OCI Vault** cross-region key replication for customer-managed encryption keys.
4. Define runbook for failover: DNS update, application reconfiguration, validation checklist.
5. Schedule monthly **DR drills** through an approved orchestrator or CI workflow. Resource Scheduler can support selected resource scheduling operations; it is not a general deployment/teardown orchestrator.

### Lifecycle Policy for Backup Tiering

| Window | Tier | Rationale |
|---|---|---|
| Day 0–30 | Standard | Hot backups, fast restore |
| Day 30–90 | Infrequent Access | Monthly restore tests |
| Day 90–365 | Archive | Annual compliance retention |
| Day 365+ | Delete or extend | Per regulatory policy |

---

## 4. WORM Compliance Vault

### Problem Statement

Regulated clients (BACEN, ANS, LGPD, SOX) must retain documents in immutable storage with audit trails. On-premises WORM solutions are expensive and hard to scale.

### Architecture Overview

```
Document Sources
  ├── ERP (contracts, invoices)
  ├── Core Banking (statements)
  └── HR Systems (employee records)
         │
         ▼ via OCI Data Integration or API upload
  Object Storage — WORM Bucket
  (Retention Rules: Definite or Indefinite lock)
         │
         ├── OCI Audit → audit-logs/ bucket (immutable)
         ├── OCI Vault → encryption at rest (HSM-backed)
         └── Read-only IAM group for auditors
```

### Implementation Steps

1. Create bucket with **Object Storage Retention Rules** (e.g., definite lock: 7 years for financial records).
2. **Lock the retention rule** post-creation — even tenant admins cannot shorten or remove it.
3. Create IAM group `auditors` with `inspect` + `read` only on the WORM bucket.
4. Enable OCI Vault encryption with HSM-backed keys; store key backup in secondary region.
5. Export OCI Audit logs to a second immutable bucket for tamper-evident audit trail.
6. Provide client with monthly compliance report via OCI Logging Analytics saved query.

---

## 5. CDN + Static Asset Distribution

### Problem Statement

Fintechs, healthtechs, and ISVs serve large volumes of documents (PDFs, images, videos) to end users and need secure, low-latency delivery without exposing internal storage credentials.

### Architecture Overview

```
Client App
    │
    ├── Request pre-signed URL (TTL-bound)
    │       │
    │       ▼
    │   Backend API (OCI Functions or App Server)
    │       │ generates Pre-Authenticated Request (PAR)
    │       ▼
    └── Direct download from private Object Storage
              │
              ▼
         End User (TTL-bound private document)

Public-safe static assets
    │
    ▼
Cloudflare at OCI or customer-managed Cloudflare
    │ cache only approved public prefixes
    ▼
OCI Object Storage origin contract
```

### Implementation Steps

1. Store assets in Object Storage with `NoPublicAccess`.
2. Backend generates **Pre-Authenticated Requests (PARs)** per object with short TTL (e.g., 15 min).
3. Use **Cloudflare at OCI** or an existing Cloudflare account for cacheable public-safe static assets (JS, CSS, images, immutable media).
4. Keep sensitive documents PAR-only with `Cache-Control: private, no-store`.
5. Implement signed URL rotation logic in the backend to prevent URL sharing abuse.
6. Monitor Object Storage egress and edge cache metrics in the owning monitoring stack.

### Deployable Blueprint

Use `blueprints/extensions/cdn-static-assets/` for the deployable OCI side of this pattern. It creates the private Object Storage origin, optional synthetic objects, lifecycle rules, smoke-test PARs, optional DNS CNAME hand-off, and a backend PAR broker sample. Run `scripts/test-cdn-static-assets-lifecycle.sh` for a real create, verify, curl, destroy, and cleanup test.

---

## 6. Sizing Reference

Storage list prices are illustrative USD public rates, reviewed on 2026-10-14; taxes, discounts, requests, transfer, and minimum-duration charges are additional inputs. Data Flow and Functions rows are unbenchmarked sizing examples, not performance or cost commitments. Confirm [Oracle current pricing](https://www.oracle.com/cloud/price-list/) before a customer quote.

### Object Storage Pricing (Public USD Rates, Reviewed October 2026)

| Tier | Price (USD/GB/month) | Use Case |
|---|---|---|
| Standard | ~$0.0255 | Active data, frequent access |
| Infrequent Access | ~$0.01 | Backups, 30–90 day retention |
| Archive | ~$0.0026 | Long-term compliance, cold data |

> Archive has a 90-day minimum storage duration and an early-deletion charge. The $0.01/GB retrieval SKU applies to Infrequent Access, not an established Archive retrieval fee. Include restore latency in RTO planning, plus requests, restored storage, and transfer costs. See [Oracle storage pricing](https://www.oracle.com/cloud/storage/pricing/) and [Archive FAQ](https://www.oracle.com/apac/cloud/storage/archive-storage/faq/).

### OCI Data Flow (Spark) Sizing Guide

| Workload | Shape | Executors | Est. Runtime | Monthly Cost |
|---|---|---|---|---|
| 10 GB daily ETL | VM.Standard3.Flex 4 OCPU | 2 | ~10 min | Not estimated |
| 500 GB weekly ETL | VM.Standard3.Flex 8 OCPU | 10 | ~45 min | Not estimated |
| 5 TB monthly scan | VM.Standard3.Flex 16 OCPU | 20 | ~2 h | Not estimated |

### OCI Functions Sizing Guide

| Throughput | Memory | Concurrency | Monthly Invocations | Est. Cost |
|---|---|---|---|---|
| Low (< 1k files/day) | 256 MB | Default | ~30k | Not estimated |
| Medium (10k files/day) | 512 MB | 10 | ~300k | Not estimated |
| High (100k files/day) | 1 GB | 50 | ~3M | Not estimated |

> The first 2 million monthly invocations and 400,000 monthly GB-seconds have free usage allowances under [Oracle Functions pricing](https://www.oracle.com/middleeast/cloud/cloud-native/functions/). Image storage, logging, networking, provisioned concurrency, and other services require separate sizing.

---

## 7. Commercialization Cheat Sheet

### Target Segments

| Solution | Primary Segments | Deal Size Indicator |
|---|---|---|
| Data Lake / Lakehouse | Financeiro, Varejo, Saúde | > 5 TB data / 10+ source systems |
| Event-Driven Processing | Fintech, Healthtech, Logística | > 10k documents/day or latency SLA |
| Backup / DR | Any regulated client | RPO/RTO in compliance scope |
| WORM Vault | BACEN, ANS, SOX clients | Legal hold or audit requirement |
| CDN + Assets | ISV, E-commerce, Healthtech | > 1M end users or > 100 GB/month egress |

### Discovery Questions

**Data Lake:**
- How many source systems do you currently have?
- Do your analysts write SQL or Python?
- Do you have a data catalog today?
- What is your current storage cost per TB/month?

**Event-Driven:**
- How many files do you receive per day? Per hour at peak?
- What is your current processing latency (upload to result)?
- Do you use any AI/ML services today for document processing?

**WORM / Compliance:**
- Which regulatory frameworks apply to your organization?
- What is your current retention policy per document type?
- Do you have documented evidence of immutability for auditors today?

### Objection Handling

| Objection | Response |
|---|---|
| "We already use AWS S3" | OCI Object Storage is S3 API-compatible (existing SDKs/tools work). Egress costs are significantly lower on OCI. |
| "We don't have a Spark team" | OCI Data Flow is fully managed — no cluster admin. Teams write standard PySpark. |
| "Functions are hard to debug" | OCI Functions integrates natively with OCI Logging and APM. Local testing with `fn invoke`. |
| "How do we prove WORM compliance?" | OCI Retention Rules are enforced at the storage API layer — even tenant admins cannot delete locked objects. Verifiable via OCI Audit API. |

---

*Last updated: 2026-06-04*
*Owner: Oracle Cloud Architecture*
