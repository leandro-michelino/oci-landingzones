# Blueprint Index

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
| [AI Agents RAG Landing Zone](blueprints/ai/agents/) | Agentic RAG over approved enterprise documents. | [Architecture](blueprints/ai/agents/architecture/README.md) |
| [OCI AI Services](blueprints/ai/ai-services/) | Pretrained Vision, Language, and Document Understanding service setup. | [Architecture](blueprints/ai/ai-services/architecture/README.md) |
| [Azure + OCI AI Gateway](blueprints/ai/azure-oci-ai-gateway/) | End-to-end Azure + OCI AI gateway where OCI API Gateway routes requests to OCI Generative AI and Azure OpenAI by region, cost, or data residency policy. | [Architecture](blueprints/ai/azure-oci-ai-gateway/architecture/README.md) |
| [Document Intelligence Pipeline](blueprints/ai/document-intelligence/) | Intake, extraction, reasoning, and structured output for PDFs, images, contracts, invoices, claims, and reports. | [Architecture](blueprints/ai/document-intelligence/architecture/README.md) |
| [Embedding And Vector Ingestion Pipeline](blueprints/ai/embedding-pipeline/) | Standalone embedding ingestion for RAG, semantic search, and knowledge-base refresh. | [Architecture](blueprints/ai/embedding-pipeline/architecture/README.md) |
| [GenAI Fine-Tuning And Dedicated AI Cluster](blueprints/ai/genai-fine-tuning/) | Domain-specific model customization with controlled dataset, cluster, model, and endpoint hand-offs. | [Architecture](blueprints/ai/genai-fine-tuning/architecture/README.md) |
| [GenAI Multi-Model Gateway](blueprints/ai/genai-gateway/) | Multi-model GenAI front door with routing, usage plans, quotas, cost tags, audit bucket, and log group. | [Architecture](blueprints/ai/genai-gateway/architecture/README.md) |
| [GenAI Guardrails And Observability](blueprints/ai/genai-guardrails/) | Guardrail overlay for genai-private, genai-gateway, or app-owned GenAI endpoints. | [Architecture](blueprints/ai/genai-guardrails/architecture/README.md) |
| [OCI Generative AI Private Landing Zone](blueprints/ai/genai-private/) | Private GenAI access for applications, notebooks, and fine-tuning datasets. | [Architecture](blueprints/ai/genai-private/architecture/README.md) |
| [Multi-Agent Orchestration](blueprints/ai/multi-agent/) | Orchestrator plus specialist agents for search, data, code, or workflow automation. | [Architecture](blueprints/ai/multi-agent/architecture/README.md) |

## cis

| Blueprint | Summary | Architecture |
|---|---|---|
| [CIS Level 1 Landing Zone](blueprints/cis/level1/) | Builds the Level 1 CIS-aligned landing-zone baseline for teams that need pragmatic security controls without the stricter Level 2 posture. | [Architecture](blueprints/cis/level1/architecture/README.md) |
| [CIS Level 2 Landing Zone](blueprints/cis/level2/) | Builds the stricter CIS-aligned landing-zone baseline for regulated environments where hardened controls and tighter operational review are expected. | [Architecture](blueprints/cis/level2/architecture/README.md) |

## compliance

| Blueprint | Summary | Architecture |
|---|---|---|
| [Healthcare PCI Compliance](blueprints/compliance/healthcare-pci/) | HIPAA, PCI DSS, or mixed regulated environments that need explicit control evidence. | [Architecture](blueprints/compliance/healthcare-pci/architecture/README.md) |
| [SCCA Cloud Native Landing Zone](blueprints/compliance/scca-cloud-native/) | Combines core governance, controlled networking, and operations hooks for a SCCA-style cloud-native landing-zone pattern. | [Architecture](blueprints/compliance/scca-cloud-native/architecture/README.md) |
| [Security Posture Automation](blueprints/compliance/security-posture/) | Cloud Guard + Vulnerability Scanning + Events automation for protected compartments. | [Architecture](blueprints/compliance/security-posture/architecture/README.md) |
| [Zero Trust Landing Zone](blueprints/compliance/zero-trust/) | Creates a private, segmented, identity-aware landing-zone pattern with ZPR, network controls, and least-privilege boundaries called out up front. | [Architecture](blueprints/compliance/zero-trust/architecture/README.md) |

## core

| Blueprint | Summary | Architecture |
|---|---|---|
| [Core Landing Zone](blueprints/core/) | Builds the shared OCI foundation: compartments, IAM, tagging, logging, Cloud Guard, Vault/KMS, Security Zones, VSS, budgets, events, and monitoring. | [Architecture](blueprints/core/architecture/README.md) |

## data-platform

| Blueprint | Summary | Architecture |
|---|---|---|
| [Oracle APEX On Autonomous Database](blueprints/data-platform/apex-adw/) | Private APEX/ORDS ingress and operator hand-off for an existing Autonomous Database. | [Architecture](blueprints/data-platform/apex-adw/architecture/README.md) |
| [Autonomous Database](blueprints/data-platform/autonomous-database/) | Private ATP or ADW database for application and data-platform landing zones. | [Architecture](blueprints/data-platform/autonomous-database/architecture/README.md) |
| [Autonomous Database MongoDB API](blueprints/data-platform/mongodb-api/) | Managed MongoDB-compatible document API on OCI using Autonomous Database. | [Architecture](blueprints/data-platform/mongodb-api/architecture/README.md) |
| [MySQL HeatWave Landing Zone](blueprints/data-platform/mysql-heatwave/) | Private MySQL with HeatWave analytics, ML, or Lakehouse options. | [Architecture](blueprints/data-platform/mysql-heatwave/architecture/README.md) |
| [OCI NoSQL Database](blueprints/data-platform/nosql/) | Managed OCI NoSQL table with deploy-and-use app networking, optional secondary index and cross-region replica, and IAM/alert contracts. | [Architecture](blueprints/data-platform/nosql/architecture/README.md) |
| [OCI + AWS MySQL HeatWave DR (OCI Primary over IPSec)](blueprints/data-platform/oci-aws-mysql-heatwave-dr/) | OCI-primary MySQL HeatWave with AWS standby endpoint and IPSec-only cross-cloud replication lane. | [Architecture](blueprints/data-platform/oci-aws-mysql-heatwave-dr/architecture/README.md) |
| [OpenSearch Search And Vector Platform](blueprints/data-platform/opensearch/) | Managed OpenSearch cluster for search and vector index workloads. | [Architecture](blueprints/data-platform/opensearch/architecture/README.md) |
| [PostgreSQL Landing Zone](blueprints/data-platform/postgresql/) | Private PostgreSQL database tier for app teams that need managed open-source database foundations. | [Architecture](blueprints/data-platform/postgresql/architecture/README.md) |
| [Private Data Platform Landing Zone](blueprints/data-platform/private-data-platform/) | Builds a private data-platform pattern with network placement, vault/KMS, object storage, private endpoint, and streaming hooks. | [Architecture](blueprints/data-platform/private-data-platform/architecture/README.md) |

## devops

| Blueprint | Summary | Architecture |
|---|---|---|
| [OCI DevOps Pipeline](blueprints/devops/oci-devops-pipeline/) | Native CI/CD bootstrap for OKE, Compute, Functions, or artifact workflows. | [Architecture](blueprints/devops/oci-devops-pipeline/architecture/README.md) |

## disaster-recovery

| Blueprint | Summary | Architecture |
|---|---|---|
| [AWS + OCI Cross-Cloud DR](blueprints/disaster-recovery/aws-oci-cross-cloud-dr/) | Cross-cloud DR contract with OCI primary and AWS standby, DNS failover runbook metadata, and interconnect or no-interconnect connectivity modes. | [Architecture](blueprints/disaster-recovery/aws-oci-cross-cloud-dr/architecture/README.md) |
| [Azure + OCI Cross-Cloud DR](blueprints/disaster-recovery/azure-oci-cross-cloud-dr/) | Cross-cloud DR contract with OCI primary and Azure standby, DNS failover runbook metadata, and interconnect or no-interconnect connectivity modes. | [Architecture](blueprints/disaster-recovery/azure-oci-cross-cloud-dr/architecture/README.md) |
| [Full Stack Disaster Recovery](blueprints/disaster-recovery/fsdr/) | Creates OCI Full Stack Disaster Recovery primary and standby protection groups, log buckets, and DR plan wiring. | [Architecture](blueprints/disaster-recovery/fsdr/architecture/README.md) |

## extensions

| Blueprint | Summary | Architecture |
|---|---|---|
| [AKS + OKE Active Passive](blueprints/extensions/aks-oke-active-passive/) | Active/passive failover AKS + OKE operating model with OCI as primary, partner interconnect, GitOps contract, and DNS failover contract. | [Architecture](blueprints/extensions/aks-oke-active-passive/architecture/README.md) |
| [API Gateway Extension](blueprints/extensions/apigw/) | Adds OCI API Gateway resources to an existing landing zone so API exposure, routing, and deployment outputs are managed consistently. | [Architecture](blueprints/extensions/apigw/architecture/README.md) |
| [OCI Container Instances](blueprints/extensions/container-instances/) | Serverless container runtime for private app workers, APIs, and small services that do not need OKE. | [Architecture](blueprints/extensions/container-instances/architecture/README.md) |
| [Oracle Digital Assistant](blueprints/extensions/digital-assistant/) | Oracle Digital Assistant landing zone with optional deploy-and-use private endpoint network, ODA instance, private endpoint attachment, and IAM/alert contracts. | [Architecture](blueprints/extensions/digital-assistant/architecture/README.md) |
| [EKS + OKE Active Passive](blueprints/extensions/eks-oke-active-passive/) | Active/passive failover EKS + OKE operating model with OCI as primary, partner interconnect, GitOps contract, and DNS failover contract. | [Architecture](blueprints/extensions/eks-oke-active-passive/architecture/README.md) |
| [Event-Driven Application Platform](blueprints/extensions/event-driven-platform/) | Event-driven apps, AI automation, integration pipelines, and async workload hand-offs. | [Architecture](blueprints/extensions/event-driven-platform/architecture/README.md) |
| [Exadata Extension](blueprints/extensions/exadata/) | Adds OCI Cloud Exadata Infrastructure as an optional service extension after the landing-zone network and compartments are ready. | [Architecture](blueprints/extensions/exadata/architecture/README.md) |
| [Oracle Functions Extension](blueprints/extensions/functions/) | OCI-native serverless functions with optional OCIR repository, private application subnet, API Gateway routes, Events triggers, and scoped IAM. | [Architecture](blueprints/extensions/functions/architecture/README.md) |
| [Oracle Analytics Cloud](blueprints/extensions/oac/) | Private analytics tier for ADW, ATP, and enterprise reporting workloads. | [Architecture](blueprints/extensions/oac/architecture/README.md) |
| [Observability Platform](blueprints/extensions/observability/) | Shared observability foundation above the core logging and monitoring baseline. | [Architecture](blueprints/extensions/observability/architecture/README.md) |
| [Oracle Integration Cloud](blueprints/extensions/oic/) | Private integration platform for SaaS, ERP, and application connectivity. | [Architecture](blueprints/extensions/oic/architecture/README.md) |
| [OKE Service Mesh](blueprints/extensions/oke-service-mesh/) | OKE clusters that need managed mesh controls, mTLS policy preparation, and tracing integration. | [Architecture](blueprints/extensions/oke-service-mesh/architecture/README.md) |
| [OKE Extension](blueprints/extensions/oke/) | Adds OCI Container Engine for Kubernetes as a platform extension with cluster, node pool, subnet, endpoint, IAM, and logging decisions visible. | [Architecture](blueprints/extensions/oke/architecture/README.md) |
| [Redis Cache Landing Zone](blueprints/extensions/redis-cache/) | Private cache/session layer for application platforms. | [Architecture](blueprints/extensions/redis-cache/architecture/README.md) |
| [Streaming Extension](blueprints/extensions/streaming/) | Adds OCI Streaming resources with stream pool and stream outputs for event-driven or data-platform workloads. | [Architecture](blueprints/extensions/streaming/architecture/README.md) |
| [WAF Extension](blueprints/extensions/waf/) | Adds OCI WAF policy and web application firewall resources for workloads that need managed edge or application protection. | [Architecture](blueprints/extensions/waf/architecture/README.md) |

## identity

| Blueprint | Summary | Architecture |
|---|---|---|
| [CIS Basic Identity Baseline](blueprints/identity/cis-basic/) | Creates CIS-oriented IAM groups, dynamic groups, and policies without deploying the full core landing-zone stack. | [Architecture](blueprints/identity/cis-basic/architecture/README.md) |
| [Custom Identity Domain](blueprints/identity/custom-identity-domain/) | Creates one or more custom OCI identity domains and optional regional replicas for a named identity boundary. | [Architecture](blueprints/identity/custom-identity-domain/architecture/README.md) |
| [New Identity Domain](blueprints/identity/new-identity-domain/) | Creates a new OCI identity domain and optional replicas for a single identity boundary. | [Architecture](blueprints/identity/new-identity-domain/architecture/README.md) |

## industry

| Blueprint | Summary | Architecture |
|---|---|---|
| [Secure Desktops Landing Zone](blueprints/industry/secure-desktops/) | Managed VDI for contractors, regulated users, or private administrative workstations. | [Architecture](blueprints/industry/secure-desktops/architecture/README.md) |
| [Telco Cloud Native Landing Zone](blueprints/industry/telco-cloud-native/) | Composes network, vault, OKE, monitoring, and OS Management foundations for telco-oriented cloud-native workloads. | [Architecture](blueprints/industry/telco-cloud-native/architecture/README.md) |

## networking

| Blueprint | Summary | Architecture |
|---|---|---|
| [AWS + OCI Hybrid Network Backbone](blueprints/networking/aws-oci-hybrid-network-backbone/) | OCI DRG-primary hybrid network backbone with AWS Transit Gateway pairing and IPSec first, plus optional Direct Connect + FastConnect partner interconnect at final cutover. | [Architecture](blueprints/networking/aws-oci-hybrid-network-backbone/architecture/README.md) |
| [Azure + OCI Dual Connectivity Hardening](blueprints/networking/azure-oci-dual-connectivity/) | OCI-primary dual-connectivity pattern with IPSec/BGP first, plus optional Interconnect (ExpressRoute + FastConnect) enablement at final cutover. | [Architecture](blueprints/networking/azure-oci-dual-connectivity/architecture/README.md) |
| [Azure vWAN + OCI DRG Transit](blueprints/networking/azure-vwan-oci-drg-transit/) | OCI-primary transit pattern with Azure Virtual WAN and Virtual Hub on the Azure side, IPSec/BGP first for rollout, and Interconnect as default path when enabled in final cutover. | [Architecture](blueprints/networking/azure-vwan-oci-drg-transit/architecture/README.md) |
| [Externally Managed VCNs](blueprints/networking/externally-managed-vcns/) | Normalizes existing VCN, subnet, DRG, and route-target IDs so downstream blueprints can consume brownfield networking cleanly. | [Architecture](blueprints/networking/externally-managed-vcns/architecture/README.md) |
| [Hub-Spoke With Azure vWAN ExpressRoute](blueprints/networking/hub-spoke-with-azure-vwan-expressroute/) | OCI hub-spoke network connected to Azure Virtual WAN through ExpressRoute Gateway, with Azure VNets mapped to OCI spoke VCNs. | [Architecture](blueprints/networking/hub-spoke-with-azure-vwan-expressroute/architecture/README.md) |
| [Hub-Spoke With DRG And Three-Tier VCNs](blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns/) | Builds a hub VCN, DRG, spoke VCNs, and DRG attachments for a classic routed hub-spoke landing-zone network. | [Architecture](blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns/architecture/README.md) |
| [Hub-Spoke With Dual Region DR](blueprints/networking/hub-spoke-with-dual-region-dr/) | Creates paired primary and secondary hub-spoke networking for disaster-recovery-ready regional separation. | [Architecture](blueprints/networking/hub-spoke-with-dual-region-dr/architecture/README.md) |
| [Hub-Spoke With FortiGate HA](blueprints/networking/hub-spoke-with-fortigate-ha/) | Deploys a Fortinet FortiGate active-passive HA pair into a hub-spoke network for customer-managed inspection. | [Architecture](blueprints/networking/hub-spoke-with-fortigate-ha/architecture/README.md) |
| [Hub-Spoke With Bastion Jump Host](blueprints/networking/hub-spoke-with-hub-vcn-bastion-jump-host/) | Adds a bastion access path to a hub-spoke network so privileged access is explicit and reviewable. | [Architecture](blueprints/networking/hub-spoke-with-hub-vcn-bastion-jump-host/architecture/README.md) |
| [Hub-Spoke With FastConnect Virtual Circuit](blueprints/networking/hub-spoke-with-hub-vcn-fastconnect-vc/) | Adds FastConnect virtual circuit integration to a hub-spoke network for dedicated hybrid connectivity. | [Architecture](blueprints/networking/hub-spoke-with-hub-vcn-fastconnect-vc/architecture/README.md) |
| [Hub-Spoke With IPSec VPN](blueprints/networking/hub-spoke-with-hub-vcn-ipsec-vpn/) | Adds IPSec VPN connectivity to a hub-spoke network for encrypted hybrid connectivity. | [Architecture](blueprints/networking/hub-spoke-with-hub-vcn-ipsec-vpn/architecture/README.md) |
| [Hub-Spoke With Network Appliance](blueprints/networking/hub-spoke-with-hub-vcn-net-appliance/) | Adds a network appliance target into hub-spoke routing for inspection or custom transit behavior. | [Architecture](blueprints/networking/hub-spoke-with-hub-vcn-net-appliance/architecture/README.md) |
| [Hub-Spoke With Network Firewall](blueprints/networking/hub-spoke-with-hub-vcn-net-firewall/) | Adds OCI Network Firewall into hub-spoke routing so inspection is first-class in the landing-zone network. | [Architecture](blueprints/networking/hub-spoke-with-hub-vcn-net-firewall/architecture/README.md) |
| [Hub-Spoke With Multicloud Interconnect](blueprints/networking/hub-spoke-with-multicloud-interconnect/) | Composes hub-spoke networking with FastConnect and IPSec options for multicloud or multi-provider connectivity. | [Architecture](blueprints/networking/hub-spoke-with-multicloud-interconnect/architecture/README.md) |
| [Hub-Spoke With Private DNS Split Horizon](blueprints/networking/hub-spoke-with-private-dns-split-horizon/) | Adds private DNS views, zones, and resolver outputs to hub-spoke networking for split-horizon name resolution. | [Architecture](blueprints/networking/hub-spoke-with-private-dns-split-horizon/architecture/README.md) |
| [Hub-Spoke With Transit Routing NVA HA](blueprints/networking/hub-spoke-with-transit-routing-nva-ha/) | Adds highly available network virtual appliance routing to hub-spoke networking for inspected transit paths. | [Architecture](blueprints/networking/hub-spoke-with-transit-routing-nva-ha/architecture/README.md) |
| [Hub-Spoke With ZPR Micro Segmentation](blueprints/networking/hub-spoke-with-zpr-micro-segmentation/) | Adds ZPR configuration and policies to a hub-spoke network so micro-segmentation is part of the topology. | [Architecture](blueprints/networking/hub-spoke-with-zpr-micro-segmentation/architecture/README.md) |
| [Multi Tenancy Shared Services Network](blueprints/networking/multi-tenancy-shared-services/) | Creates a shared-services network pattern for multi-tenant environments that need central DNS and common network services. | [Architecture](blueprints/networking/multi-tenancy-shared-services/architecture/README.md) |
| [Network Load Balancer Landing Zone](blueprints/networking/network-load-balancer/) | Layer 4 service entry point for database, TCP, UDP, or non-HTTP workloads. | [Architecture](blueprints/networking/network-load-balancer/architecture/README.md) |
| [Regional Prod Nonprod Hubs](blueprints/networking/regional-prod-nonprod-hubs/) | Creates separate production and nonproduction hub networks in a region so environment isolation is stronger than naming alone. | [Architecture](blueprints/networking/regional-prod-nonprod-hubs/architecture/README.md) |
| [Standalone Private Endpoint Only VCN](blueprints/networking/standalone-private-endpoint-only/) | Creates a private-first VCN shape with private endpoint access and no public application subnet pattern. | [Architecture](blueprints/networking/standalone-private-endpoint-only/architecture/README.md) |
| [Standalone Three-Tier VCN Custom](blueprints/networking/standalone-three-tier-vcn-custom/) | Creates a standalone three-tier workload VCN with custom CIDRs, subnets, route tables, gateways, and security lists. | [Architecture](blueprints/networking/standalone-three-tier-vcn-custom/architecture/README.md) |
| [Standalone Three-Tier VCN Defaults](blueprints/networking/standalone-three-tier-vcn-defaults/) | Creates a simple standalone three-tier workload VCN using defaults that are useful for demos, first plans, and baseline workload networks. | [Architecture](blueprints/networking/standalone-three-tier-vcn-defaults/architecture/README.md) |
| [Standalone Three-Tier VCN With ZPR](blueprints/networking/standalone-three-tier-vcn-zpr/) | Creates a standalone three-tier VCN with ZPR controls so micro-segmentation is built into the workload network. | [Architecture](blueprints/networking/standalone-three-tier-vcn-zpr/architecture/README.md) |

## operating-entity

| Blueprint | Summary | Architecture |
|---|---|---|
| [Single Operating Entity](blueprints/operating-entity/) | Creates a single operating-entity boundary with compartments, groups, and policies for delegated administration. | [Architecture](blueprints/operating-entity/architecture/README.md) |
| [Multi Operating Entities](blueprints/operating-entity/multi-operating-entities/) | Creates multiple operating-entity boundaries at once, each with compartments, groups, and policies. | [Architecture](blueprints/operating-entity/multi-operating-entities/architecture/README.md) |
| [Workload Vending](blueprints/operating-entity/workload-vending/) | Vends a workload landing area with compartments, groups, and policies for an application or product team. | [Architecture](blueprints/operating-entity/workload-vending/architecture/README.md) |

## operations

| Blueprint | Summary | Architecture |
|---|---|---|
| [Cost Optimization](blueprints/operations/cost-optimization/) | Cost attribution, budget guardrails, FinOps notifications, optional Optimizer profiles, and finance/platform hand-off. | [Architecture](blueprints/operations/cost-optimization/architecture/README.md) |
