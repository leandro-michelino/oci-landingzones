# Deployment Pattern Catalog

Author: Leandro Michelino | ACE | <leandro.michelino@oracle.com>

This catalog keeps the deployment menu broader than a single reference
implementation. It borrows from OCI landing zone repositories, OCI reference
architectures, and patterns that show up in real customer conversations.

Implemented patterns should have a self-contained blueprint folder with its own
`README.md`, `architecture/README.md`, Terraform files, variables example, and
validation notes. The architecture README is the canonical text artifact for the
pattern and must include an ASCII diagram before the pattern is used in a
customer review.
Status `Implemented` means the folder has deployable foundation wiring, even
when some expensive or external resources are disabled by default. Status
`Planned` is reserved for future patterns that do not yet have a blueprint
folder.

## Pattern Families

| Family | Pattern | Blueprint | Status |
| --- | --- | --- | --- |
| Core | Core landing zone with no application networking | `blueprints/core/` | Implemented |
| CIS | CIS Level 1 landing zone | `blueprints/cis/level1/` | Implemented |
| CIS | CIS Level 2 landing zone | `blueprints/cis/level2/` | Implemented |
| Identity | CIS basic identity baseline | `blueprints/identity/cis-basic/` | Implemented |
| Identity | New identity domain | `blueprints/identity/new-identity-domain/` | Implemented |
| Identity | Custom identity domain | `blueprints/identity/custom-identity-domain/` | Implemented |
| Operating entity | Single operating entity onboarding | `blueprints/operating-entity/` | Implemented |
| Operating entity | Multi-operating-entity landing zone | `blueprints/operating-entity/multi-operating-entities/` | Implemented |
| Operating entity | Workload vending / application team onboarding | `blueprints/operating-entity/workload-vending/` | Implemented |
| Networking | Standalone three-tier VCN defaults | `blueprints/networking/standalone-three-tier-vcn-defaults/` | Implemented |
| Networking | Standalone three-tier VCN custom | `blueprints/networking/standalone-three-tier-vcn-custom/` | Implemented |
| Networking | Standalone three-tier VCN with ZPR | `blueprints/networking/standalone-three-tier-vcn-zpr/` | Implemented |
| Networking | Standalone private endpoint only | `blueprints/networking/standalone-private-endpoint-only/` | Implemented |
| Networking | Externally managed VCNs | `blueprints/networking/externally-managed-vcns/` | Implemented |
| Networking | Hub-spoke with DRG and three-tier VCNs | `blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns/` | Implemented |
| Networking | Hub-spoke with IPSec VPN | `blueprints/networking/hub-spoke-with-hub-vcn-ipsec-vpn/` | Implemented |
| Networking | Hub-spoke with FastConnect virtual circuit | `blueprints/networking/hub-spoke-with-hub-vcn-fastconnect-vc/` | Implemented |
| Networking | Hub-spoke with network firewall | `blueprints/networking/hub-spoke-with-hub-vcn-net-firewall/` | Implemented |
| Networking | Hub-spoke with network appliance | `blueprints/networking/hub-spoke-with-hub-vcn-net-appliance/` | Implemented |
| Networking | Hub-spoke with bastion jump host | `blueprints/networking/hub-spoke-with-hub-vcn-bastion-jump-host/` | Implemented |
| Networking | Hub-spoke with transit routing NVA HA | `blueprints/networking/hub-spoke-with-transit-routing-nva-ha/` | Implemented |
| Networking | Hub-spoke with private DNS split horizon | `blueprints/networking/hub-spoke-with-private-dns-split-horizon/` | Implemented |
| Networking | Hub-spoke with ZPR micro-segmentation | `blueprints/networking/hub-spoke-with-zpr-micro-segmentation/` | Implemented |
| Networking | Hub-spoke with dual-region DR | `blueprints/networking/hub-spoke-with-dual-region-dr/` | Implemented |
| Networking | Multi-tenancy shared services | `blueprints/networking/multi-tenancy-shared-services/` | Implemented |
| Networking | Hub-spoke with multicloud interconnect | `blueprints/networking/hub-spoke-with-multicloud-interconnect/` | Implemented |
| Networking | Regional prod/nonprod hub separation | `blueprints/networking/regional-prod-nonprod-hubs/` | Implemented |
| Networking | OCI Network Load Balancer (Layer 4 TCP/UDP, private backend, health checks) | `blueprints/networking/network-load-balancer/` | Implemented |
| Compliance | SCCA-style cloud-native landing zone | `blueprints/compliance/scca-cloud-native/` | Implemented |
| Compliance | Zero Trust landing zone | `blueprints/compliance/zero-trust/` | Implemented |
| Compliance | Healthcare / PCI compliance landing zone | `blueprints/compliance/healthcare-pci/` | Implemented |
| Compliance | Security posture automation (Cloud Guard + Vuln Scan + auto-remediation) | `blueprints/compliance/security-posture/` | Implemented |
| Disaster recovery | Full Stack Disaster Recovery | `blueprints/disaster-recovery/fsdr/` | Implemented |
| Data platform | Autonomous Database ATP / ADW | `blueprints/data-platform/autonomous-database/` | Implemented |
| Data platform | Private data platform landing zone | `blueprints/data-platform/private-data-platform/` | Implemented |
| Data platform | PostgreSQL landing zone | `blueprints/data-platform/postgresql/` | Implemented |
| Data platform | Oracle APEX on Autonomous Database | `blueprints/data-platform/apex-adw/` | Implemented |
| Data platform | OpenSearch search and vector platform | `blueprints/data-platform/opensearch/` | Implemented |
| Data platform | MySQL HeatWave | `blueprints/data-platform/mysql-heatwave/` | Implemented |
| AI | OCI Generative AI private landing zone | `blueprints/ai/genai-private/` | Implemented |
| AI | OCI AI Services (Vision, Language, Speech, Document Understanding, Anomaly Detection) | `blueprints/ai/ai-services/` | Implemented |
| AI | GenAI multi-model gateway (API Gateway routing, per-team quotas, cost tagging, audit log) | `blueprints/ai/genai-gateway/` | Implemented |
| AI | GenAI fine-tuning and dedicated AI cluster (training data bucket, custom model endpoint) | `blueprints/ai/genai-fine-tuning/` | Implemented |
| AI | GenAI guardrails and observability (PII redaction, token alarms, audit trail, Cloud Guard) | `blueprints/ai/genai-guardrails/` | Implemented |
| AI | Document intelligence pipeline (Document Understanding + GenAI, intake/output buckets) | `blueprints/ai/document-intelligence/` | Implemented |
| AI | Embedding and vector ingestion pipeline (chunking, GenAI embedding, OpenSearch index) | `blueprints/ai/embedding-pipeline/` | Implemented |
| AI | Multi-agent orchestration (orchestrator + specialist agents, Streaming, tool registry, audit) | `blueprints/ai/multi-agent/` | Implemented |
| AI | AI Agents - RAG landing zone (agents, knowledge base, OpenSearch) | `blueprints/ai/agents/` | Implemented |
| DevOps | OCI DevOps pipeline | `blueprints/devops/oci-devops-pipeline/` | Implemented |
| Industry | Telco cloud-native landing zone | `blueprints/industry/telco-cloud-native/` | Implemented |
| Industry | OCI Secure Desktops (VDI, private network, IAM, session policies) | `blueprints/industry/secure-desktops/` | Implemented |
| Extensions | OKE extension | `blueprints/extensions/oke/` | Implemented |
| Extensions | OKE service mesh | `blueprints/extensions/oke-service-mesh/` | Implemented |
| Extensions | Exadata extension | `blueprints/extensions/exadata/` | Implemented |
| Extensions | API Gateway extension | `blueprints/extensions/apigw/` | Implemented |
| Extensions | Oracle Analytics Cloud | `blueprints/extensions/oac/` | Implemented |
| Extensions | Oracle Integration Cloud | `blueprints/extensions/oic/` | Implemented |
| Extensions | Observability platform | `blueprints/extensions/observability/` | Implemented |
| Extensions | Streaming extension | `blueprints/extensions/streaming/` | Implemented |
| Extensions | WAF extension | `blueprints/extensions/waf/` | Implemented |
| Extensions | Container Instances | `blueprints/extensions/container-instances/` | Implemented |
| Extensions | Oracle Functions | `blueprints/extensions/functions/` | Implemented |
| Extensions | Event-driven application platform (Events, Service Connector Hub, Streaming, Functions, Notifications) | `blueprints/extensions/event-driven-platform/` | Implemented |
| Extensions | Redis Cache landing zone | `blueprints/extensions/redis-cache/` | Implemented |
| Operations | Cost optimization | `blueprints/operations/cost-optimization/` | Implemented |
| AI | OCI Data Science (notebooks, model catalog, deployment) | `blueprints/ai/data-science/` | Planned |
| Data platform | GoldenGate replication hub | `blueprints/data-platform/goldengate/` | Planned |
| Extensions | Oracle Digital Assistant | `blueprints/extensions/digital-assistant/` | Planned |
| Data platform | Data Catalog and lineage | `blueprints/data-platform/data-catalog/` | Planned |
| Extensions | Vault Advanced / BYOK (HSM, key rotation, break-glass) | `blueprints/extensions/vault-advanced/` | Planned |
| Industry | Financial services landing zone (PCI DSS + SOC 2 + Data Safe) | `blueprints/industry/financial-services/` | Planned |
| Industry | HPC / GPU cluster (RDMA, cluster network, NFS) | `blueprints/industry/hpc-gpu/` | Planned |
| Compliance | Public sector / FedRAMP alignment | `blueprints/compliance/public-sector/` | Planned |
| Networking | Public edge and ingress zone (DNS, WAF, public LB, cert, route-to-app) | `blueprints/networking/public-edge-ingress/` | Planned |
| Extensions | Batch and queue workers (instance pool or container instances, queue, retry) | `blueprints/extensions/batch-workers/` | Planned |
| Data platform | Object Storage data lakehouse (bronze/silver/gold zones, KMS, lifecycle, private endpoint) | `blueprints/data-platform/object-storage-lakehouse/` | Planned |
| Operations | Ransomware-resilient backup (backup policies, immutable archive, restore evidence) | `blueprints/operations/backup-resilience/` | Planned |
| Industry | WebLogic / Java app platform (LB, app tier, database, logs, bastion) | `blueprints/industry/weblogic-platform/` | Planned |
| Industry | VMware / hybrid migration zone (FastConnect or VPN, DNS, migration segments) | `blueprints/industry/vmware-hybrid-migration/` | Planned |
| Data platform | OCI NoSQL Database (key-value / document store, private endpoint, IAM) | `blueprints/data-platform/nosql/` | Planned |
| Data platform | OCI Data Flow (managed Spark, private subnet, Object Storage lake, IAM) | `blueprints/data-platform/data-flow/` | Planned |
| Data platform | OCI Data Integration (ETL/ELT pipelines, workspace, private endpoint) | `blueprints/data-platform/data-integration/` | Planned |
| Compliance | OCI Data Safe (database activity monitoring, auditing, data masking, assessment) | `blueprints/compliance/data-safe/` | Planned |
| Extensions | OCI Certificates Service (managed PKI / CA, TLS lifecycle, Vault integration) | `blueprints/extensions/certificates/` | Planned |
| Industry | Oracle Cloud VMware Solution (OCVS, baremetal VMware, private connectivity, DNS) | `blueprints/industry/ocvs/` | Planned |
| Extensions | OCI Process Automation (low-code workflow, Oracle SaaS integration, IAM) | `blueprints/extensions/process-automation/` | Planned |
| Extensions | OCI Email Delivery (SMTP relay, approved sender, IAM, NSG) | `blueprints/extensions/email-delivery/` | Planned |
| Compliance | OCI Threat Intelligence (IoC feeds, Cloud Guard integration, event rules) | `blueprints/compliance/threat-intelligence/` | Planned |

## Selection Notes

- Use `core` first for the shared compartment, tagging, and IAM foundation.
- Use operating entity patterns when the main question is ownership and
  delegated administration.
- Use networking patterns when the main question is traffic path, inspection,
  connectivity, or DNS.
- Use compliance patterns when control enforcement, auditability, or regulator
  mapping drives the design.
- Use data platform and industry patterns when the workload shape needs its own
  landing zone conventions.
- Use extension-only mode when the customer already has the base OCI estate and
  only needs one add-on service. Supply existing compartment, network, service,
  and IAM identifiers through local tfvars.
- Use base-plus-extension mode when this repo should create the foundation
  first. Deploy Core or CIS, Networking, optional ownership and operations
  blueprints, then pass their outputs into the selected extension.
- Use a single `blueprints/...` folder when consuming one architecture. The
  blueprint's pinned Git module sources fetch shared modules during
  `terraform init`.
- Treat the deployable blueprint as a customer outcome. Create a full folder
  only when the pattern has its own lifecycle, owner, approval path, state
  boundary, or architecture review.
- Keep narrow subtopics inside the owning blueprint. A single topic, event rule,
  alarm set, NSG choice, private endpoint, API route group, or optional IAM
  policy should not become its own deployment unless it represents an
  independently operated customer outcome.
- Promote repeated Terraform implementation into `modules/` when several
  blueprints need the same behavior, then keep each blueprint as a thin
  customer-facing wrapper with its own README, architecture, inputs, and
  outputs.
- Add curated full landing-zone bundles only for common real journeys, such as
  industry, compliance, or workload platform patterns, and compose existing
  base, networking, operations, and extension decisions instead of duplicating
  every subtopic.
- Review the blueprint-local ASCII architecture diagram before plan/apply so
  ownership boundaries, traffic paths, DNS, IAM, logging, and monitoring are
  aligned with the target environment.

## Research Inputs

The catalog should continue to evolve from:

- OCI core landing zone reference implementations.
- OCI operating entity landing zone implementations.
- OCI reference architectures for hub-spoke, DRG, network firewall, FastConnect,
  VPN, private DNS, OKE, Exadata, Zero Trust, and SCCA.
- Customer-specific requirements seen during real OCI landing zone work.
