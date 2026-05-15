# Blueprint Index

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Generated from deployable folders under `blueprints/`.
Run `make blueprints` after adding, moving, or removing a blueprint.

| Quick Links |
|---|
| [Main README](README.md) |
| [Deployment Guide](docs/DEPLOYMENT-GUIDE.md) |
| [Deployment Pattern Catalog](docs/DEPLOYMENT-PATTERN-CATALOG.md) |
| [Architecture Index](docs/architecture/README.md) |

## ai

| Blueprint | Summary | Architecture |
|---|---|---|
| [AI Agents RAG Landing Zone](blueprints/ai/agents/) | Agentic RAG over approved enterprise documents. | [ASCII](blueprints/ai/agents/architecture/README.md) |
| [OCI AI Services](blueprints/ai/ai-services/) | Pretrained Vision, Language, and Document Understanding service setup. | [ASCII](blueprints/ai/ai-services/architecture/README.md) |
| [Document Intelligence Pipeline](blueprints/ai/document-intelligence/) | Intake, extraction, reasoning, and structured output for PDFs, images, contracts, invoices, claims, and reports. | [ASCII](blueprints/ai/document-intelligence/architecture/README.md) |
| [Embedding And Vector Ingestion Pipeline](blueprints/ai/embedding-pipeline/) | Standalone embedding ingestion for RAG, semantic search, and knowledge-base refresh. | [ASCII](blueprints/ai/embedding-pipeline/architecture/README.md) |
| [GenAI Fine-Tuning And Dedicated AI Cluster](blueprints/ai/genai-fine-tuning/) | Domain-specific model customization with controlled dataset, cluster, model, and endpoint hand-offs. | [ASCII](blueprints/ai/genai-fine-tuning/architecture/README.md) |
| [GenAI Multi-Model Gateway](blueprints/ai/genai-gateway/) | Multi-model GenAI front door with routing, usage plans, quotas, cost tags, audit bucket, and log group. | [ASCII](blueprints/ai/genai-gateway/architecture/README.md) |
| [GenAI Guardrails And Observability](blueprints/ai/genai-guardrails/) | Guardrail overlay for genai-private, genai-gateway, or app-owned GenAI endpoints. | [ASCII](blueprints/ai/genai-guardrails/architecture/README.md) |
| [OCI Generative AI Private Landing Zone](blueprints/ai/genai-private/) | Private GenAI access for applications, notebooks, and fine-tuning datasets. | [ASCII](blueprints/ai/genai-private/architecture/README.md) |
| [Multi-Agent Orchestration](blueprints/ai/multi-agent/) | Orchestrator plus specialist agents for search, data, code, or workflow automation. | [ASCII](blueprints/ai/multi-agent/architecture/README.md) |

## cis

| Blueprint | Summary | Architecture |
|---|---|---|
| [CIS Level 1 Landing Zone](blueprints/cis/level1/) | Builds the Level 1 CIS-aligned landing-zone baseline for teams that need pragmatic security controls without the stricter Level 2 posture. | [ASCII](blueprints/cis/level1/architecture/README.md) |
| [CIS Level 2 Landing Zone](blueprints/cis/level2/) | Builds the stricter CIS-aligned landing-zone baseline for regulated environments where hardened controls and tighter operational review are expected. | [ASCII](blueprints/cis/level2/architecture/README.md) |

## compliance

| Blueprint | Summary | Architecture |
|---|---|---|
| [Healthcare PCI Compliance](blueprints/compliance/healthcare-pci/) | HIPAA, PCI DSS, or mixed regulated environments that need explicit control evidence. | [ASCII](blueprints/compliance/healthcare-pci/architecture/README.md) |
| [SCCA Cloud Native Landing Zone](blueprints/compliance/scca-cloud-native/) | Combines core governance, controlled networking, and operations hooks for a SCCA-style cloud-native landing-zone pattern. | [ASCII](blueprints/compliance/scca-cloud-native/architecture/README.md) |
| [Security Posture Automation](blueprints/compliance/security-posture/) | Cloud Guard + Vulnerability Scanning + Events automation for protected compartments. | [ASCII](blueprints/compliance/security-posture/architecture/README.md) |
| [Zero Trust Landing Zone](blueprints/compliance/zero-trust/) | Creates a private, segmented, identity-aware landing-zone pattern with ZPR, network controls, and least-privilege boundaries called out up front. | [ASCII](blueprints/compliance/zero-trust/architecture/README.md) |

## core

| Blueprint | Summary | Architecture |
|---|---|---|
| [Core Landing Zone](blueprints/core/) | Builds the shared OCI foundation: compartments, IAM, tagging, logging, Cloud Guard, Vault/KMS, Security Zones, VSS, budgets, events, and monitoring. | [ASCII](blueprints/core/architecture/README.md) |

## data-platform

| Blueprint | Summary | Architecture |
|---|---|---|
| [Oracle APEX On Autonomous Database](blueprints/data-platform/apex-adw/) | Private APEX/ORDS ingress and operator hand-off for an existing Autonomous Database. | [ASCII](blueprints/data-platform/apex-adw/architecture/README.md) |
| [Autonomous Database](blueprints/data-platform/autonomous-database/) | Private ATP or ADW database for application and data-platform landing zones. | [ASCII](blueprints/data-platform/autonomous-database/architecture/README.md) |
| [MySQL HeatWave Landing Zone](blueprints/data-platform/mysql-heatwave/) | Private MySQL with HeatWave analytics, ML, or Lakehouse options. | [ASCII](blueprints/data-platform/mysql-heatwave/architecture/README.md) |
| [OpenSearch Search And Vector Platform](blueprints/data-platform/opensearch/) | Managed OpenSearch cluster for search and vector index workloads. | [ASCII](blueprints/data-platform/opensearch/architecture/README.md) |
| [PostgreSQL Landing Zone](blueprints/data-platform/postgresql/) | Private PostgreSQL database tier for app teams that need managed open-source database foundations. | [ASCII](blueprints/data-platform/postgresql/architecture/README.md) |
| [Private Data Platform Landing Zone](blueprints/data-platform/private-data-platform/) | Builds a private data-platform pattern with network placement, vault/KMS, object storage, private endpoint, and streaming hooks. | [ASCII](blueprints/data-platform/private-data-platform/architecture/README.md) |

## devops

| Blueprint | Summary | Architecture |
|---|---|---|
| [OCI DevOps Pipeline](blueprints/devops/oci-devops-pipeline/) | Native CI/CD bootstrap for OKE, Compute, Functions, or artifact workflows. | [ASCII](blueprints/devops/oci-devops-pipeline/architecture/README.md) |

## disaster-recovery

| Blueprint | Summary | Architecture |
|---|---|---|
| [Full Stack Disaster Recovery](blueprints/disaster-recovery/fsdr/) | Creates OCI Full Stack Disaster Recovery primary and standby protection groups, log buckets, and DR plan wiring. | [ASCII](blueprints/disaster-recovery/fsdr/architecture/README.md) |

## extensions

| Blueprint | Summary | Architecture |
|---|---|---|
| [API Gateway Extension](blueprints/extensions/apigw/) | Adds OCI API Gateway resources to an existing landing zone so API exposure, routing, and deployment outputs are managed consistently. | [ASCII](blueprints/extensions/apigw/architecture/README.md) |
| [OCI Container Instances](blueprints/extensions/container-instances/) | Serverless container runtime for private app workers, APIs, and small services that do not need OKE. | [ASCII](blueprints/extensions/container-instances/architecture/README.md) |
| [Event-Driven Application Platform](blueprints/extensions/event-driven-platform/) | Event-driven apps, AI automation, integration pipelines, and async workload hand-offs. | [ASCII](blueprints/extensions/event-driven-platform/architecture/README.md) |
| [Exadata Extension](blueprints/extensions/exadata/) | Adds OCI Cloud Exadata Infrastructure as an optional service extension after the landing-zone network and compartments are ready. | [ASCII](blueprints/extensions/exadata/architecture/README.md) |
| [Oracle Functions Extension](blueprints/extensions/functions/) | OCI-native serverless functions with optional OCIR repository, private application subnet, API Gateway routes, Events triggers, and scoped IAM. | [ASCII](blueprints/extensions/functions/architecture/README.md) |
| [Oracle Analytics Cloud](blueprints/extensions/oac/) | Private analytics tier for ADW, ATP, and enterprise reporting workloads. | [ASCII](blueprints/extensions/oac/architecture/README.md) |
| [Observability Platform](blueprints/extensions/observability/) | Shared observability foundation above the core logging and monitoring baseline. | [ASCII](blueprints/extensions/observability/architecture/README.md) |
| [Oracle Integration Cloud](blueprints/extensions/oic/) | Private integration platform for SaaS, ERP, and application connectivity. | [ASCII](blueprints/extensions/oic/architecture/README.md) |
| [OKE Service Mesh](blueprints/extensions/oke-service-mesh/) | OKE clusters that need managed mesh controls, mTLS policy preparation, and tracing integration. | [ASCII](blueprints/extensions/oke-service-mesh/architecture/README.md) |
| [OKE Extension](blueprints/extensions/oke/) | Adds OCI Container Engine for Kubernetes as a platform extension with cluster, node pool, subnet, endpoint, IAM, and logging decisions visible. | [ASCII](blueprints/extensions/oke/architecture/README.md) |
| [Redis Cache Landing Zone](blueprints/extensions/redis-cache/) | Private cache/session layer for application platforms. | [ASCII](blueprints/extensions/redis-cache/architecture/README.md) |
| [Streaming Extension](blueprints/extensions/streaming/) | Adds OCI Streaming resources with stream pool and stream outputs for event-driven or data-platform workloads. | [ASCII](blueprints/extensions/streaming/architecture/README.md) |
| [WAF Extension](blueprints/extensions/waf/) | Adds OCI WAF policy and web application firewall resources for workloads that need managed edge or application protection. | [ASCII](blueprints/extensions/waf/architecture/README.md) |

## identity

| Blueprint | Summary | Architecture |
|---|---|---|
| [CIS Basic Identity Baseline](blueprints/identity/cis-basic/) | Creates CIS-oriented IAM groups, dynamic groups, and policies without deploying the full core landing-zone stack. | [ASCII](blueprints/identity/cis-basic/architecture/README.md) |
| [Custom Identity Domain](blueprints/identity/custom-identity-domain/) | Creates one or more custom OCI identity domains and optional regional replicas for a named identity boundary. | [ASCII](blueprints/identity/custom-identity-domain/architecture/README.md) |
| [New Identity Domain](blueprints/identity/new-identity-domain/) | Creates a new OCI identity domain and optional replicas for a single identity boundary. | [ASCII](blueprints/identity/new-identity-domain/architecture/README.md) |

## industry

| Blueprint | Summary | Architecture |
|---|---|---|
| [Secure Desktops Landing Zone](blueprints/industry/secure-desktops/) | Managed VDI for contractors, regulated users, or private administrative workstations. | [ASCII](blueprints/industry/secure-desktops/architecture/README.md) |
| [Telco Cloud Native Landing Zone](blueprints/industry/telco-cloud-native/) | Composes network, vault, OKE, monitoring, and OS Management foundations for telco-oriented cloud-native workloads. | [ASCII](blueprints/industry/telco-cloud-native/architecture/README.md) |

## networking

| Blueprint | Summary | Architecture |
|---|---|---|
| [Externally Managed VCNs](blueprints/networking/externally-managed-vcns/) | Normalizes existing VCN, subnet, DRG, and route-target IDs so downstream blueprints can consume brownfield networking cleanly. | [ASCII](blueprints/networking/externally-managed-vcns/architecture/README.md) |
| [Hub-Spoke With DRG And Three-Tier VCNs](blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns/) | Builds a hub VCN, DRG, spoke VCNs, and DRG attachments for a classic routed hub-spoke landing-zone network. | [ASCII](blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns/architecture/README.md) |
| [Hub-Spoke With Dual Region DR](blueprints/networking/hub-spoke-with-dual-region-dr/) | Creates paired primary and secondary hub-spoke networking for disaster-recovery-ready regional separation. | [ASCII](blueprints/networking/hub-spoke-with-dual-region-dr/architecture/README.md) |
| [Hub-Spoke With Bastion Jump Host](blueprints/networking/hub-spoke-with-hub-vcn-bastion-jump-host/) | Adds a bastion access path to a hub-spoke network so privileged access is explicit and reviewable. | [ASCII](blueprints/networking/hub-spoke-with-hub-vcn-bastion-jump-host/architecture/README.md) |
| [Hub-Spoke With FastConnect Virtual Circuit](blueprints/networking/hub-spoke-with-hub-vcn-fastconnect-vc/) | Adds FastConnect virtual circuit integration to a hub-spoke network for dedicated hybrid connectivity. | [ASCII](blueprints/networking/hub-spoke-with-hub-vcn-fastconnect-vc/architecture/README.md) |
| [Hub-Spoke With IPSec VPN](blueprints/networking/hub-spoke-with-hub-vcn-ipsec-vpn/) | Adds IPSec VPN connectivity to a hub-spoke network for encrypted hybrid connectivity. | [ASCII](blueprints/networking/hub-spoke-with-hub-vcn-ipsec-vpn/architecture/README.md) |
| [Hub-Spoke With Network Appliance](blueprints/networking/hub-spoke-with-hub-vcn-net-appliance/) | Adds a network appliance target into hub-spoke routing for inspection or custom transit behavior. | [ASCII](blueprints/networking/hub-spoke-with-hub-vcn-net-appliance/architecture/README.md) |
| [Hub-Spoke With Network Firewall](blueprints/networking/hub-spoke-with-hub-vcn-net-firewall/) | Adds OCI Network Firewall into hub-spoke routing so inspection is first-class in the landing-zone network. | [ASCII](blueprints/networking/hub-spoke-with-hub-vcn-net-firewall/architecture/README.md) |
| [Hub-Spoke With Multicloud Interconnect](blueprints/networking/hub-spoke-with-multicloud-interconnect/) | Composes hub-spoke networking with FastConnect and IPSec options for multicloud or multi-provider connectivity. | [ASCII](blueprints/networking/hub-spoke-with-multicloud-interconnect/architecture/README.md) |
| [Hub-Spoke With Private DNS Split Horizon](blueprints/networking/hub-spoke-with-private-dns-split-horizon/) | Adds private DNS views, zones, and resolver outputs to hub-spoke networking for split-horizon name resolution. | [ASCII](blueprints/networking/hub-spoke-with-private-dns-split-horizon/architecture/README.md) |
| [Hub-Spoke With Transit Routing NVA HA](blueprints/networking/hub-spoke-with-transit-routing-nva-ha/) | Adds highly available network virtual appliance routing to hub-spoke networking for inspected transit paths. | [ASCII](blueprints/networking/hub-spoke-with-transit-routing-nva-ha/architecture/README.md) |
| [Hub-Spoke With ZPR Micro Segmentation](blueprints/networking/hub-spoke-with-zpr-micro-segmentation/) | Adds ZPR configuration and policies to a hub-spoke network so micro-segmentation is part of the topology. | [ASCII](blueprints/networking/hub-spoke-with-zpr-micro-segmentation/architecture/README.md) |
| [Multi Tenancy Shared Services Network](blueprints/networking/multi-tenancy-shared-services/) | Creates a shared-services network pattern for multi-tenant environments that need central DNS and common network services. | [ASCII](blueprints/networking/multi-tenancy-shared-services/architecture/README.md) |
| [Network Load Balancer Landing Zone](blueprints/networking/network-load-balancer/) | Layer 4 service entry point for database, TCP, UDP, or non-HTTP workloads. | [ASCII](blueprints/networking/network-load-balancer/architecture/README.md) |
| [Regional Prod Nonprod Hubs](blueprints/networking/regional-prod-nonprod-hubs/) | Creates separate production and nonproduction hub networks in a region so environment isolation is stronger than naming alone. | [ASCII](blueprints/networking/regional-prod-nonprod-hubs/architecture/README.md) |
| [Standalone Private Endpoint Only VCN](blueprints/networking/standalone-private-endpoint-only/) | Creates a private-first VCN shape with private endpoint access and no public application subnet pattern. | [ASCII](blueprints/networking/standalone-private-endpoint-only/architecture/README.md) |
| [Standalone Three-Tier VCN Custom](blueprints/networking/standalone-three-tier-vcn-custom/) | Creates a standalone three-tier workload VCN with custom CIDRs, subnets, route tables, gateways, and security lists. | [ASCII](blueprints/networking/standalone-three-tier-vcn-custom/architecture/README.md) |
| [Standalone Three-Tier VCN Defaults](blueprints/networking/standalone-three-tier-vcn-defaults/) | Creates a simple standalone three-tier workload VCN using defaults that are useful for demos, first plans, and baseline workload networks. | [ASCII](blueprints/networking/standalone-three-tier-vcn-defaults/architecture/README.md) |
| [Standalone Three-Tier VCN With ZPR](blueprints/networking/standalone-three-tier-vcn-zpr/) | Creates a standalone three-tier VCN with ZPR controls so micro-segmentation is built into the workload network. | [ASCII](blueprints/networking/standalone-three-tier-vcn-zpr/architecture/README.md) |

## operating-entity

| Blueprint | Summary | Architecture |
|---|---|---|
| [Single Operating Entity](blueprints/operating-entity/) | Creates a single operating-entity boundary with compartments, groups, and policies for delegated administration. | [ASCII](blueprints/operating-entity/architecture/README.md) |
| [Multi Operating Entities](blueprints/operating-entity/multi-operating-entities/) | Creates multiple operating-entity boundaries at once, each with compartments, groups, and policies. | [ASCII](blueprints/operating-entity/multi-operating-entities/architecture/README.md) |
| [Workload Vending](blueprints/operating-entity/workload-vending/) | Vends a workload landing area with compartments, groups, and policies for an application or product team. | [ASCII](blueprints/operating-entity/workload-vending/architecture/README.md) |

## operations

| Blueprint | Summary | Architecture |
|---|---|---|
| [Cost Optimization](blueprints/operations/cost-optimization/) | Cost attribution, budget guardrails, FinOps notifications, optional Optimizer profiles, and finance/platform hand-off. | [ASCII](blueprints/operations/cost-optimization/architecture/README.md) |
