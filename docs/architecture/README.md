# Architecture Index

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This folder is the repository-level architecture index. The authoritative
architecture for a deployable pattern still lives beside that pattern at
`blueprints/<family>/<deployment>/architecture/README.md`.

If you are new here, start with this file to understand how the repo is wired,
then jump into a specific blueprint Architecture file for delivery detail.

## Repository Architecture

```text
+--------------------------------------------------------------------------------+
|                         OCI Landing Zones Repository                            |
+--------------------------------------------------------------------------------+
|                                                                                |
|  Operator / CI                                                                 |
|      |                                                                         |
|      v                                                                         |
|  scripts/validate-all.sh                                                       |
|      |                                                                         |
|      +--> scripts/check-repo-contracts.sh                                      |
|      |       |                                                                 |
|      |       +--> forbidden doc and local module source checks                |
|      |       `--> blueprint TF + Ansible file contract checks                 |
|      |                                                                         |
|      +--> ansible/playbooks/validate.yml                                       |
|      |       |                                                                 |
|      |       +--> Terraform fmt, init -backend=false, validate                 |
|      |       +--> README and Architecture contract checks                |
|      |       +--> Ansible syntax checks                                        |
|      |       `--> generated artifact cleanup                                  |
|      |                                                                         |
|      +--> fallback shell checks when Ansible is unavailable                    |
|      `--> scripts/simulate-cloud-deployments.sh for Azure/AWS wrappers        |
|                                                                                |
|  Deployable blueprints                                                         |
|      |                                                                         |
|      +--> blueprints/core                                                      |
|      +--> blueprints/cis/*                                                     |
|      +--> blueprints/networking/*                                              |
|      +--> blueprints/identity/*                                                |
|      +--> blueprints/operating-entity/*                                        |
|      +--> blueprints/operations/*                                              |
|      +--> blueprints/compliance/*                                              |
|      +--> blueprints/extensions/*                                              |
|      +--> blueprints/data-platform/*                                           |
|      +--> blueprints/ai/*                                                      |
|      +--> blueprints/devops/*                                                  |
|      +--> blueprints/disaster-recovery/*                                       |
|      `--> blueprints/industry/*                                                |
|              |                                                                 |
|              v                                                                 |
|      reusable modules under modules/                                           |
|              |                                                                 |
|              v                                                                 |
|      OCI resources in the selected tenancy and region                          |
|                                                                                |
+--------------------------------------------------------------------------------+
```

## Architecture Contract

Each deployable blueprint must include:

| Artifact | Purpose |
|---|---|
| `README.md` | Operator-facing deployment purpose, inputs, outputs, workflow, validation, and review notes. |
| `architecture/README.md` | Detailed Architecture, Terraform components, request flow, design notes, trust boundaries, and review checklist. |
| `main.tf` | The Terraform composition that matches the documented architecture. |
| `terraform.tfvars.example` | Safe input shape without real tenancy secrets or OCIDs. |
| `ansible/plan.yml`, `ansible/apply.yml`, `ansible/destroy.yml` | Local orchestration entry points for the blueprint. |

Deployable blueprint Terraform sources must use pinned Git module references,
not local `../` paths. That keeps a customer able to sparse-checkout only one
blueprint, such as `blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns/`,
and still run `terraform init` from that folder.

## Review Flow

```text
choose blueprint
  |
  v
choose customer path
  |-- extension-only: bring existing compartment/network/service IDs
  `-- base-plus-extension: deploy base outputs before extension inputs
  |
  v
sparse-checkout only the needed blueprint folders
  |
  v
read blueprint README.md
  |
  v
review blueprint architecture/README.md
  |
  v
copy terraform.tfvars.example to ignored terraform.tfvars
  |
  v
terraform init -backend=false && terraform validate
  |
  v
terraform plan or ansible/plan.yml
```

## Blueprint Architecture Inventory

The current catalog has 77 deployable blueprint entry points across 13
families. Each entry point owns its local Architecture in
`architecture/README.md`.

| Family | Blueprint | Architecture |
|---|---|---|
| ai | [AI Agents RAG Landing Zone](../../blueprints/ai/agents/) | [Architecture](../../blueprints/ai/agents/architecture/) |
| ai | [OCI AI Services](../../blueprints/ai/ai-services/) | [Architecture](../../blueprints/ai/ai-services/architecture/) |
| ai | [Azure + OCI AI Gateway](../../blueprints/ai/azure-oci-ai-gateway/) | [Architecture](../../blueprints/ai/azure-oci-ai-gateway/architecture/) |
| ai | [Document Intelligence Pipeline](../../blueprints/ai/document-intelligence/) | [Architecture](../../blueprints/ai/document-intelligence/architecture/) |
| ai | [Embedding And Vector Ingestion Pipeline](../../blueprints/ai/embedding-pipeline/) | [Architecture](../../blueprints/ai/embedding-pipeline/architecture/) |
| ai | [GenAI Fine-Tuning And Dedicated AI Cluster](../../blueprints/ai/genai-fine-tuning/) | [Architecture](../../blueprints/ai/genai-fine-tuning/architecture/) |
| ai | [GenAI Multi-Model Gateway](../../blueprints/ai/genai-gateway/) | [Architecture](../../blueprints/ai/genai-gateway/architecture/) |
| ai | [GenAI Guardrails And Observability](../../blueprints/ai/genai-guardrails/) | [Architecture](../../blueprints/ai/genai-guardrails/architecture/) |
| ai | [OCI Generative AI Private Landing Zone](../../blueprints/ai/genai-private/) | [Architecture](../../blueprints/ai/genai-private/architecture/) |
| ai | [Multi-Agent Orchestration](../../blueprints/ai/multi-agent/) | [Architecture](../../blueprints/ai/multi-agent/architecture/) |
| cis | [CIS Level 1 Landing Zone](../../blueprints/cis/level1/) | [Architecture](../../blueprints/cis/level1/architecture/) |
| cis | [CIS Level 2 Landing Zone](../../blueprints/cis/level2/) | [Architecture](../../blueprints/cis/level2/architecture/) |
| compliance | [Healthcare PCI Compliance](../../blueprints/compliance/healthcare-pci/) | [Architecture](../../blueprints/compliance/healthcare-pci/architecture/) |
| compliance | [SCCA Cloud Native Landing Zone](../../blueprints/compliance/scca-cloud-native/) | [Architecture](../../blueprints/compliance/scca-cloud-native/architecture/) |
| compliance | [Security Posture Automation](../../blueprints/compliance/security-posture/) | [Architecture](../../blueprints/compliance/security-posture/architecture/) |
| compliance | [Zero Trust Landing Zone](../../blueprints/compliance/zero-trust/) | [Architecture](../../blueprints/compliance/zero-trust/architecture/) |
| core | [Core Landing Zone](../../blueprints/core/) | [Architecture](../../blueprints/core/architecture/) |
| data-platform | [Oracle APEX On Autonomous Database](../../blueprints/data-platform/apex-adw/) | [Architecture](../../blueprints/data-platform/apex-adw/architecture/) |
| data-platform | [Autonomous Database](../../blueprints/data-platform/autonomous-database/) | [Architecture](../../blueprints/data-platform/autonomous-database/architecture/) |
| data-platform | [MySQL HeatWave Landing Zone](../../blueprints/data-platform/mysql-heatwave/) | [Architecture](../../blueprints/data-platform/mysql-heatwave/architecture/) |
| data-platform | [OCI + AWS MySQL HeatWave DR](../../blueprints/data-platform/oci-aws-mysql-heatwave-dr/) | [Architecture](../../blueprints/data-platform/oci-aws-mysql-heatwave-dr/architecture/) |
| data-platform | [OCI NoSQL Database](../../blueprints/data-platform/nosql/) | [Architecture](../../blueprints/data-platform/nosql/architecture/) |
| data-platform | [OpenSearch Search And Vector Platform](../../blueprints/data-platform/opensearch/) | [Architecture](../../blueprints/data-platform/opensearch/architecture/) |
| data-platform | [PostgreSQL Landing Zone](../../blueprints/data-platform/postgresql/) | [Architecture](../../blueprints/data-platform/postgresql/architecture/) |
| data-platform | [Private Data Platform Landing Zone](../../blueprints/data-platform/private-data-platform/) | [Architecture](../../blueprints/data-platform/private-data-platform/architecture/) |
| devops | [OCI DevOps Pipeline](../../blueprints/devops/oci-devops-pipeline/) | [Architecture](../../blueprints/devops/oci-devops-pipeline/architecture/) |
| disaster-recovery | [Azure + OCI Cross-Cloud DR](../../blueprints/disaster-recovery/azure-oci-cross-cloud-dr/) | [Architecture](../../blueprints/disaster-recovery/azure-oci-cross-cloud-dr/architecture/) |
| disaster-recovery | [AWS + OCI Cross-Cloud DR](../../blueprints/disaster-recovery/aws-oci-cross-cloud-dr/) | [Architecture](../../blueprints/disaster-recovery/aws-oci-cross-cloud-dr/architecture/) |
| disaster-recovery | [Full Stack Disaster Recovery](../../blueprints/disaster-recovery/fsdr/) | [Architecture](../../blueprints/disaster-recovery/fsdr/architecture/) |
| extensions | [API Gateway Extension](../../blueprints/extensions/apigw/) | [Architecture](../../blueprints/extensions/apigw/architecture/) |
| extensions | [AKS + OKE Active Active](../../blueprints/extensions/aks-oke-active-active/) | [Architecture](../../blueprints/extensions/aks-oke-active-active/architecture/) |
| extensions | [EKS + OKE Active Active](../../blueprints/extensions/eks-oke-active-active/) | [Architecture](../../blueprints/extensions/eks-oke-active-active/architecture/) |
| extensions | [OCI Container Instances](../../blueprints/extensions/container-instances/) | [Architecture](../../blueprints/extensions/container-instances/architecture/) |
| extensions | [Event-Driven Application Platform](../../blueprints/extensions/event-driven-platform/) | [Architecture](../../blueprints/extensions/event-driven-platform/architecture/) |
| extensions | [Exadata Extension](../../blueprints/extensions/exadata/) | [Architecture](../../blueprints/extensions/exadata/architecture/) |
| extensions | [Oracle Functions Extension](../../blueprints/extensions/functions/) | [Architecture](../../blueprints/extensions/functions/architecture/) |
| extensions | [Oracle Analytics Cloud](../../blueprints/extensions/oac/) | [Architecture](../../blueprints/extensions/oac/architecture/) |
| extensions | [Oracle Digital Assistant](../../blueprints/extensions/digital-assistant/) | [Architecture](../../blueprints/extensions/digital-assistant/architecture/) |
| extensions | [Observability Platform](../../blueprints/extensions/observability/) | [Architecture](../../blueprints/extensions/observability/architecture/) |
| extensions | [Oracle Integration Cloud](../../blueprints/extensions/oic/) | [Architecture](../../blueprints/extensions/oic/architecture/) |
| extensions | [OKE Extension](../../blueprints/extensions/oke/) | [Architecture](../../blueprints/extensions/oke/architecture/) |
| extensions | [OKE Service Mesh](../../blueprints/extensions/oke-service-mesh/) | [Architecture](../../blueprints/extensions/oke-service-mesh/architecture/) |
| extensions | [Redis Cache Landing Zone](../../blueprints/extensions/redis-cache/) | [Architecture](../../blueprints/extensions/redis-cache/architecture/) |
| extensions | [Streaming Extension](../../blueprints/extensions/streaming/) | [Architecture](../../blueprints/extensions/streaming/architecture/) |
| extensions | [WAF Extension](../../blueprints/extensions/waf/) | [Architecture](../../blueprints/extensions/waf/architecture/) |
| identity | [CIS Basic Identity Baseline](../../blueprints/identity/cis-basic/) | [Architecture](../../blueprints/identity/cis-basic/architecture/) |
| identity | [Custom Identity Domain](../../blueprints/identity/custom-identity-domain/) | [Architecture](../../blueprints/identity/custom-identity-domain/architecture/) |
| identity | [New Identity Domain](../../blueprints/identity/new-identity-domain/) | [Architecture](../../blueprints/identity/new-identity-domain/architecture/) |
| industry | [Secure Desktops Landing Zone](../../blueprints/industry/secure-desktops/) | [Architecture](../../blueprints/industry/secure-desktops/architecture/) |
| industry | [Telco Cloud Native Landing Zone](../../blueprints/industry/telco-cloud-native/) | [Architecture](../../blueprints/industry/telco-cloud-native/architecture/) |
| networking | [Externally Managed VCNs](../../blueprints/networking/externally-managed-vcns/) | [Architecture](../../blueprints/networking/externally-managed-vcns/architecture/) |
| networking | [AWS + OCI Hybrid Network Backbone](../../blueprints/networking/aws-oci-hybrid-network-backbone/) | [Architecture](../../blueprints/networking/aws-oci-hybrid-network-backbone/architecture/) |
| networking | [Azure + OCI Dual Connectivity Hardening](../../blueprints/networking/azure-oci-dual-connectivity/) | [Architecture](../../blueprints/networking/azure-oci-dual-connectivity/architecture/) |
| networking | [Azure vWAN + OCI DRG Transit](../../blueprints/networking/azure-vwan-oci-drg-transit/) | [Architecture](../../blueprints/networking/azure-vwan-oci-drg-transit/architecture/) |
| networking | [Hub-Spoke With DRG And Three-Tier VCNs](../../blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns/) | [Architecture](../../blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns/architecture/) |
| networking | [Hub-Spoke With Dual Region DR](../../blueprints/networking/hub-spoke-with-dual-region-dr/) | [Architecture](../../blueprints/networking/hub-spoke-with-dual-region-dr/architecture/) |
| networking | [Hub-Spoke With Bastion Jump Host](../../blueprints/networking/hub-spoke-with-hub-vcn-bastion-jump-host/) | [Architecture](../../blueprints/networking/hub-spoke-with-hub-vcn-bastion-jump-host/architecture/) |
| networking | [Hub-Spoke With FastConnect Virtual Circuit](../../blueprints/networking/hub-spoke-with-hub-vcn-fastconnect-vc/) | [Architecture](../../blueprints/networking/hub-spoke-with-hub-vcn-fastconnect-vc/architecture/) |
| networking | [Hub-Spoke With FortiGate HA](../../blueprints/networking/hub-spoke-with-fortigate-ha/) | [Architecture](../../blueprints/networking/hub-spoke-with-fortigate-ha/architecture/) |
| networking | [Hub-Spoke With IPSec VPN](../../blueprints/networking/hub-spoke-with-hub-vcn-ipsec-vpn/) | [Architecture](../../blueprints/networking/hub-spoke-with-hub-vcn-ipsec-vpn/architecture/) |
| networking | [Hub-Spoke With Network Appliance](../../blueprints/networking/hub-spoke-with-hub-vcn-net-appliance/) | [Architecture](../../blueprints/networking/hub-spoke-with-hub-vcn-net-appliance/architecture/) |
| networking | [Hub-Spoke With Network Firewall](../../blueprints/networking/hub-spoke-with-hub-vcn-net-firewall/) | [Architecture](../../blueprints/networking/hub-spoke-with-hub-vcn-net-firewall/architecture/) |
| networking | [Hub-Spoke With Multicloud Interconnect](../../blueprints/networking/hub-spoke-with-multicloud-interconnect/) | [Architecture](../../blueprints/networking/hub-spoke-with-multicloud-interconnect/architecture/) |
| networking | [Hub-Spoke With Private DNS Split Horizon](../../blueprints/networking/hub-spoke-with-private-dns-split-horizon/) | [Architecture](../../blueprints/networking/hub-spoke-with-private-dns-split-horizon/architecture/) |
| networking | [Hub-Spoke With Transit Routing NVA HA](../../blueprints/networking/hub-spoke-with-transit-routing-nva-ha/) | [Architecture](../../blueprints/networking/hub-spoke-with-transit-routing-nva-ha/architecture/) |
| networking | [Hub-Spoke With ZPR Micro Segmentation](../../blueprints/networking/hub-spoke-with-zpr-micro-segmentation/) | [Architecture](../../blueprints/networking/hub-spoke-with-zpr-micro-segmentation/architecture/) |
| networking | [Multi Tenancy Shared Services Network](../../blueprints/networking/multi-tenancy-shared-services/) | [Architecture](../../blueprints/networking/multi-tenancy-shared-services/architecture/) |
| networking | [Network Load Balancer Landing Zone](../../blueprints/networking/network-load-balancer/) | [Architecture](../../blueprints/networking/network-load-balancer/architecture/) |
| networking | [Regional Prod Nonprod Hubs](../../blueprints/networking/regional-prod-nonprod-hubs/) | [Architecture](../../blueprints/networking/regional-prod-nonprod-hubs/architecture/) |
| networking | [Standalone Private Endpoint Only VCN](../../blueprints/networking/standalone-private-endpoint-only/) | [Architecture](../../blueprints/networking/standalone-private-endpoint-only/architecture/) |
| networking | [Standalone Three-Tier VCN Custom](../../blueprints/networking/standalone-three-tier-vcn-custom/) | [Architecture](../../blueprints/networking/standalone-three-tier-vcn-custom/architecture/) |
| networking | [Standalone Three-Tier VCN Defaults](../../blueprints/networking/standalone-three-tier-vcn-defaults/) | [Architecture](../../blueprints/networking/standalone-three-tier-vcn-defaults/architecture/) |
| networking | [Standalone Three-Tier VCN With ZPR](../../blueprints/networking/standalone-three-tier-vcn-zpr/) | [Architecture](../../blueprints/networking/standalone-three-tier-vcn-zpr/architecture/) |
| operating-entity | [Single Operating Entity](../../blueprints/operating-entity/) | [Architecture](../../blueprints/operating-entity/architecture/) |
| operating-entity | [Multi Operating Entities](../../blueprints/operating-entity/multi-operating-entities/) | [Architecture](../../blueprints/operating-entity/multi-operating-entities/architecture/) |
| operating-entity | [Workload Vending](../../blueprints/operating-entity/workload-vending/) | [Architecture](../../blueprints/operating-entity/workload-vending/architecture/) |
| operations | [Cost Optimization](../../blueprints/operations/cost-optimization/) | [Architecture](../../blueprints/operations/cost-optimization/architecture/) |

## Maintenance Notes

- Keep this file focused on repository-level structure.
- Keep pattern-specific diagrams in the local blueprint architecture folder.
- Every deployable blueprint must keep a local Architecture file that
  matches the Terraform entry point and the local README.
- Run `./scripts/validate-changed.sh` after adding or changing a blueprint; it
  checks the repository contract plus the touched Terraform and Ansible surface.
- Run `./scripts/validate-all.sh` before release work or broad shared changes
  that should exercise every blueprint together.
