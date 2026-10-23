# Architecture Index

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

The current catalog has 80 deployable blueprint entry points across 13
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
| data-platform | [Autonomous Database MongoDB API](../../blueprints/data-platform/mongodb-api/) | [Architecture](../../blueprints/data-platform/mongodb-api/architecture/) |
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
| extensions | [AKS + OKE Active Passive](../../blueprints/extensions/aks-oke-active-passive/) | [Architecture](../../blueprints/extensions/aks-oke-active-passive/architecture/) |
| extensions | [EKS + OKE Active Passive](../../blueprints/extensions/eks-oke-active-passive/) | [Architecture](../../blueprints/extensions/eks-oke-active-passive/architecture/) |
| extensions | [OCI Container Instances](../../blueprints/extensions/container-instances/) | [Architecture](../../blueprints/extensions/container-instances/architecture/) |
| extensions | [CDN Static Asset Distribution](../../blueprints/extensions/cdn-static-assets/) | [Architecture](../../blueprints/extensions/cdn-static-assets/architecture/) |
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
| networking | [Hub-Spoke With Azure vWAN ExpressRoute](../../blueprints/networking/hub-spoke-with-azure-vwan-expressroute/) | [Architecture](../../blueprints/networking/hub-spoke-with-azure-vwan-expressroute/architecture/) |
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
- Run service-specific real lifecycle tests when a blueprint has one. For
  OpenSearch, use `scripts/test-opensearch-lifecycle.sh` with an ignored local
  tfvars file; committed samples live under
  `blueprints/data-platform/opensearch/samples/`.
- For NoSQL, use `scripts/test-nosql-lifecycle.sh` with an ignored local tfvars
  file; committed samples live under `blueprints/data-platform/nosql/samples/`.
- For OIC, use `scripts/test-oic-lifecycle.sh` with an ignored local tfvars
  file; committed samples live under `blueprints/extensions/oic/samples/`.
- For CDN Static Asset Distribution, use
  `scripts/test-cdn-static-assets-lifecycle.sh` with an ignored local tfvars
  file; committed samples live under
  `blueprints/extensions/cdn-static-assets/samples/`.

## Review On 2026-10-13

All 80 blueprint entry points passed `terraform init -backend=false` and
`terraform validate` with OCI provider 9.9.0 in an isolated source copy. Git
dependencies were materialized from their exact cached pinned revisions:
`v0.2.0` at `7807b64a959fd3a2ed312a3e9088055d838a03b4` and
`4fcd80386471010d9a4a22200e47edb1956bda11`. Source URLs were replaced only
in that disposable copy; repository module references remain pinned.

This establishes local schema compatibility and documentation component
inventory alignment. It does not establish working routes, DNS resolution,
service availability, IAM permission, runtime integration, HA, or production
readiness. Manual traffic-path review was prioritized for Networking.

The first live Networking round used profile `DEFAULT`, region
`sa-saopaulo-1`, and the compartment explicitly selected by the operator. It
covered the first ten Networking blueprints in catalog order, with cleanup after
each attempt. Later Networking rounds completed the remaining catalog items,
including authorized ephemeral NAT tests. See
[Ephemeral Deployment Evidence](../EPHEMERAL-DEPLOYMENT-EVIDENCE.md) for
provisioning, verification, cleanup, and untested paths. External-cloud and
second-region tests remain pending. No cost estimate or account-wide billing
verification was performed.

The later [Data Platform, DevOps, and DR review](../DATA-DEVOPS-DR-REVIEW-20261015.md)
covers catalog items 21-30. Its eight live checks validate disposable OCI
network foundations and cleanup only; DevOps and FSDR were local-only checks.
Refer to each blueprint architecture file for the implemented resource scope
and the report for untested service and cross-cloud paths.

Live tests stage the corrected provider configuration into isolated dependency
copies while preserving the original cached pinned revisions. These tests
validate working-tree fixes. A new immutable dependency version must be published
and selected before composed blueprints can consume the corrected shared
provider configuration from a remote source.

### Networking Review

| Blueprint | Local Schema | Remaining Architecture Or Live-Test Condition |
| --- | --- | --- |
| `aws-oci-hybrid-network-backbone` | Passed | AWS connectivity requires a separate AWS side; no external account deployment. VPN parameters and CPE reachability remain untested. |
| `azure-oci-dual-connectivity` | Passed | Azure and dedicated interconnect costs require review; no Azure deployment or circuit activation. |
| `azure-vwan-oci-drg-transit` | Passed | Azure vWAN/vHub gateways and optional interconnect require cost review and external ownership. |
| `externally-managed-vcns` | Passed | Creates no network resources; supplied OCIDs still require live ownership and route verification. |
| `hub-spoke-with-azure-vwan-expressroute` | Passed | FastConnect/ExpressRoute and Azure vWAN require cost review; dedicated links were not created. |
| `hub-spoke-with-drg-and-three-tier-vcns` | Passed | Foundation only; DRG attachments do not prove inspected transit, centralized NAT, or hub return routes. |
| `hub-spoke-with-dual-region-dr` | Passed | A second region is required by this architecture; a Sao Paulo-only test cannot prove inter-region DR. |
| `hub-spoke-with-fortigate-ha` | Passed | Compute, boot storage, and Fortinet licensing require cost review; no instances were created. |
| `hub-spoke-with-hub-vcn-bastion-jump-host` | Passed | Deploys managed OCI Bastion, not a Compute jump host; sessions and target access remain untested. |
| `hub-spoke-with-hub-vcn-fastconnect-vc` | Passed | Dedicated FastConnect circuit and partner charges require approval before activation. |
| `hub-spoke-with-hub-vcn-ipsec-vpn` | Passed | Real tunnel and routing verification requires valid CPE/IP/BGP inputs; foundation validation only. |
| `hub-spoke-with-hub-vcn-net-appliance` | Passed | Appliance Compute, boot storage, and licensing require review; guest forwarding and HA are external. |
| `hub-spoke-with-hub-vcn-net-firewall` | Passed | Firewall instance hours and data processing require cost review; traffic insertion must be configured separately. |
| `hub-spoke-with-multicloud-interconnect` | Passed | Dedicated links and external cloud prerequisites require review; no external cloud or circuit was deployed. |
| `hub-spoke-with-private-dns-split-horizon` | Passed | DNS views/zones and endpoint configuration require service-specific live query and resolution tests. |
| `hub-spoke-with-transit-routing-nva-ha` | Passed | Compute, boot storage, and licensing require review; multiple instances alone do not establish HA or inspected transit. |
| `hub-spoke-with-zpr-micro-segmentation` | Passed | Security attributes/policies need workload-backed connectivity tests; Terraform validation does not prove enforcement. |
| `multi-tenancy-shared-services` | Passed | Cross-tenancy IAM needs cooperation from the other tenancy; DEFAULT-only execution cannot prove that side. |
| `network-load-balancer` | Passed | Backend connectivity, listeners, health, and traffic/egress cost review remain pending. |
| `regional-prod-nonprod-hubs` | Passed | Prod/nonprod routing isolation and permitted flows require live tests with agreed inputs. |
| `standalone-private-endpoint-only` | Passed | Creates endpoint-ready networking, not service-specific private endpoints or NSGs; documentation corrected. |
| `standalone-three-tier-vcn-custom` | Passed | Custom CIDRs, routes, and security inputs determine connectivity and exposure. |
| `standalone-three-tier-vcn-defaults` | Passed | Corrected web-only HTTP/HTTPS security list; app/database default ingress is empty. Custom maps must include referenced keys. |
| `standalone-three-tier-vcn-zpr` | Passed | Private subnet and security attribute enforcement need workload-backed connectivity tests. |

### Other Blueprint Entry Points

These entry points passed schema validation and component inventory checks.
Their live behavior and detailed service-specific acceptance remain pending.

| Blueprint | Local Schema |
| --- | --- |
| `blueprints/ai/agents` | Passed |
| `blueprints/ai/ai-services` | Passed |
| `blueprints/ai/azure-oci-ai-gateway` | Passed |
| `blueprints/ai/document-intelligence` | Passed |
| `blueprints/ai/embedding-pipeline` | Passed |
| `blueprints/ai/genai-fine-tuning` | Passed |
| `blueprints/ai/genai-gateway` | Passed |
| `blueprints/ai/genai-guardrails` | Passed |
| `blueprints/ai/genai-private` | Passed |
| `blueprints/ai/multi-agent` | Passed |
| `blueprints/cis/level1` | Passed |
| `blueprints/cis/level2` | Passed |
| `blueprints/compliance/healthcare-pci` | Passed |
| `blueprints/compliance/scca-cloud-native` | Passed |
| `blueprints/compliance/security-posture` | Passed |
| `blueprints/compliance/zero-trust` | Passed |
| `blueprints/core` | Passed |
| `blueprints/data-platform/apex-adw` | Passed |
| `blueprints/data-platform/autonomous-database` | Passed |
| `blueprints/data-platform/mongodb-api` | Passed |
| `blueprints/data-platform/mysql-heatwave` | Passed |
| `blueprints/data-platform/nosql` | Passed |
| `blueprints/data-platform/oci-aws-mysql-heatwave-dr` | Passed |
| `blueprints/data-platform/opensearch` | Passed |
| `blueprints/data-platform/postgresql` | Passed |
| `blueprints/data-platform/private-data-platform` | Passed |
| `blueprints/devops/oci-devops-pipeline` | Passed |
| `blueprints/disaster-recovery/aws-oci-cross-cloud-dr` | Passed |
| `blueprints/disaster-recovery/azure-oci-cross-cloud-dr` | Passed |
| `blueprints/disaster-recovery/fsdr` | Passed |
| `blueprints/extensions/aks-oke-active-passive` | Passed |
| `blueprints/extensions/apigw` | Passed |
| `blueprints/extensions/cdn-static-assets` | Passed |
| `blueprints/extensions/container-instances` | Passed |
| `blueprints/extensions/digital-assistant` | Passed |
| `blueprints/extensions/eks-oke-active-passive` | Passed |
| `blueprints/extensions/event-driven-platform` | Passed |
| `blueprints/extensions/exadata` | Passed |
| `blueprints/extensions/functions` | Passed |
| `blueprints/extensions/oac` | Passed |
| `blueprints/extensions/observability` | Passed |
| `blueprints/extensions/oic` | Passed |
| `blueprints/extensions/oke-service-mesh` | Passed |
| `blueprints/extensions/oke` | Passed |
| `blueprints/extensions/redis-cache` | Passed |
| `blueprints/extensions/streaming` | Passed |
| `blueprints/extensions/waf` | Passed |
| `blueprints/identity/cis-basic` | Passed |
| `blueprints/identity/custom-identity-domain` | Passed |
| `blueprints/identity/new-identity-domain` | Passed |
| `blueprints/industry/secure-desktops` | Passed |
| `blueprints/industry/telco-cloud-native` | Passed |
| `blueprints/operating-entity` | Passed |
| `blueprints/operating-entity/multi-operating-entities` | Passed |
| `blueprints/operating-entity/workload-vending` | Passed |
| `blueprints/operations/cost-optimization` | Passed |

### Changes And Evidence

- All 298 Ansible playbooks passed syntax checks. TFLint, Terraform formatting, repository contracts, and Markdown links passed.
- Regression checks confirmed state/plan/lock preservation, existing-state refusal, no destroy after a failed plan, and cleanup after a failed apply.
- A Terraform console assertion confirmed that only web receives default HTTP/HTTPS ingress.
- Separate web ingress from app/database ingress in the default three-tier VCN.
- Clarify that the private-endpoint-only foundation creates neither service-specific private endpoints nor NSGs.
- Clarify routing and HA responsibilities in hub, firewall, and NVA diagrams.
- Require OCI provider 9.9.x for the validated GenAI private endpoint baseline.
- Preserve deployment state, saved plans, and dependency locks during validation cleanup.
- Guard real Networking lifecycle runs against existing OCI managed resources and prevent destroy after a failed plan.
- Reconcile exact resource addresses in 30 architecture component tables.
- Align CDN examples and commands with the requested `DEFAULT` profile.

Raw per-blueprint validation results and private execution logs are held locally
in `.leo-local/architecture-review-20261013/`. They are not deployment evidence.

Before any paid test, review the current [Oracle Cloud price list](https://www.oracle.com/cloud/price-list/),
[Network Firewall pricing](https://www.oracle.com/cloud/networking/network-firewall/pricing/),
and [FastConnect pricing](https://www.oracle.com/cloud/networking/fastconnect/pricing/)
with the actual service inputs and duration.

## Networking Follow-Up On 2026-10-14

Catalog items 11 through 20 completed their approved OCI lifecycle modes with
no-change drift checks and verified teardown in Sao Paulo. This includes a
private NLB with an empty TCP backend set/listener and separate prod/nonprod
network foundations. Firewall, Compute appliances, dedicated circuits, private
DNS, ZPR activation, and external-tenancy integrations remained disabled.

The follow-up corrected a stale Firewall module pin, the ZPR tenancy-root scope
and home-region prerequisite, automatic tag handling, and diagram descriptions
that implied workloads, additional spokes, or cross-tenancy connections not
created by the default blueprint. See [the per-item evidence](../EPHEMERAL-DEPLOYMENT-EVIDENCE.md#networking-items-11-through-20-2026-10-14)
for exact tested modes, remaining limits, and cleanup checks.

### Networking Completion, October 14, 2026

The remaining four Networking entries completed ephemeral network tests and verified cleanup. All 24 catalog entries are now reviewed, with paid/external/global dependencies and packet-flow limits explicitly retained in the [deployment evidence](../EPHEMERAL-DEPLOYMENT-EVIDENCE.md#networking-items-21-through-24-october-14-2026). This is catalog review coverage, not full end-to-end deployment coverage.

### Main Publication And Complete Repository Revalidation

The [October 14 repository review](../REPOSITORY-VALIDATION-20261014.md) records integration into main, immutable dependency updates, 80 blueprint schema checks, 298 Ansible syntax checks, 17 mocked regressions, and explicit AI/runtime/cost limits. Static validation coverage remains distinct from full workload deployment coverage.

### CIS, Compliance, Core, And Database Configuration Review

The [ten-entry October 14 follow-up](../CIS-COMPLIANCE-DATA-REVIEW-20261014.md) records corrected null-safe plans, Budget ownership/provider scope, Events target fields, immutable Core/Firewall/ZPR dependencies, and closed database subnet security lists. Two network-only lifecycles passed and were cleaned up; full CIS/regulated/database outcomes remain outside that evidence.

## Extensions Review, October 17, 2026

The [items 31-40 review](../EXTENSIONS-REVIEW-20261017.md) records the
Digital Assistant private-backend network correction and reduced live
lifecycle, CDN opt-in bucket default, Functions provider migration, mocked
regressions, and explicit limits for paid and external services.

## Extensions and Identity Review, October 23, 2026

The [items 41-50 review](../EXTENSIONS-IDENTITY-REVIEW-20261023.md) records
schema validation and DEFAULT-configured no-change plans for ten blueprints,
three enabled-resource plans, 15 plan-only mocked cases, safer IAM defaults,
home-region provider targeting, and prerequisite checks for OIC and WAF
attachments. No live service was provisioned in this round.

## Industry and Networking Review, October 23, 2026

The [items 51-60 review](../INDUSTRY-NETWORK-REVIEW-20261023.md) records the
Secure Desktops BYOL validation fix, telco Vault opt-in and OKE subnet-key
correction, and seven single-region read-only network plans. Full hybrid
connectivity and dual-region DR remain outside this round's evidence.
