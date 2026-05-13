# Release Notes

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

## v0.1.0 - 2026-05-12

### Added

- Initial project README.
- Base repository structure for modules, blueprints, environments, docs, tests,
  and scripts.
- Initial Terraform placeholders for planned modules and blueprints.
- Initial Ansible inventories, playbooks, roles, and local orchestration
  structure.
- Dedicated opt-in CIS Level 1 and Level 2 landing zone blueprint folders.
- CIS Level 1 and Level 2 wrappers wired to the implemented core/IAM
  foundation while remaining opt-in.
- Repository cleanup guidance for generated Terraform state, lock, plan, cache,
  and local test artifacts.
- Phase 1 core implementation for landing zone compartments and governance
  tagging.
- Governance logging implementation for core log groups, optional service logs,
  VCN flow-log shortcuts, saved searches, and opt-in tenancy audit retention.
- Cloud Guard implementation for tenancy configuration, default landing zone
  target, optional detector/responder recipe attachments, and additional
  targets.
- Vault/KMS implementation for opt-in landing zone vaults and master encryption
  keys.
- Security Zones implementation for opt-in landing zone compartment guardrails
  using approved security recipes.
- Vulnerability Scanning Service implementation for opt-in host and container
  scan recipes and targets.
- Governance budgets implementation for opt-in landing zone budgets and budget
  alert rules.
- Governance Events implementation for ONS notification topics, subscriptions,
  default IAM change rules, and custom Events rules.
- Monitoring implementation for opt-in alarms, notification topics, and
  subscriptions.
- Phase 2 IAM foundation implementation for IAM groups, dynamic groups, and
  scoped policies.
- Phase 3 networking foundation implementation for reusable hub VCN, spoke VCN,
  DRG, IPSec VPN, OCI Network Firewall, FastConnect, private DNS, ZPR, Bastion,
  and network virtual appliance modules.
- Phase 4 operating entity implementation for single operating entity,
  multi-operating-entity, and workload vending blueprints using reusable
  compartment, group, and policy modules.
- Phase 5 extension implementation for opt-in OKE, API Gateway, Streaming, WAF,
  and Exadata blueprints with resource creation disabled by default.
- Deployable networking foundations for standalone three-tier, standalone
  private-only, custom standalone, standalone ZPR, brownfield VCN references,
  DRG hub-spoke, IPSec, FastConnect, Bastion, OCI Network Firewall, NVA,
  private DNS, ZPR micro-segmentation, dual-region DR, multicloud, shared
  services, transit NVA HA, and regional prod/nonprod hub blueprints.
- Example tfvars and deployment notes for operating entity onboarding,
  multi-entity onboarding, and workload vending.
- Ansible-backed validation that discovers implemented Terraform blueprints,
  uses a Terraform plugin cache, bounds slow Terraform checks with timeouts, and
  cleans generated Terraform artifacts after validation.
- Standalone-consumable blueprint architecture folders that use pinned Git
  module sources instead of local relative module paths.
- Self-contained deployment README files and local architecture image locations
  across core, CIS, identity, networking, operating entity, and extension
  blueprints.
- Expanded deployment pattern catalog with new compliance, disaster recovery,
  operating entity, networking, data platform, and industry blueprint
  placeholders.
- Project guardrails for ignore rules, pre-commit checks, contribution flow, and
  security handling.
- Initial documentation for naming conventions, deployment flow, CIS mapping,
  variables, architecture diagrams, runbooks, and the core blueprint.
- Canonical ASCII architecture diagrams and review checklists for every
  blueprint-local `architecture/README.md`.
- Blueprint-local Ansible plan, apply, and destroy runners for every
  architecture folder.
- Full Terraform implementation wiring for the identity, compliance, disaster
  recovery, private data platform, and telco cloud-native blueprints that were
  previously documentation-only placeholders.
- OCI OS Management Hub module resources for managed instance groups and
  scheduled jobs.

### Changed

- Removed unused `region_key_map` local configuration blocks from modules so
  module locals only keep values currently used by Terraform.
- Reworked the repository validation helper so `scripts/validate-all.sh`
  delegates to Ansible when available, with a shell fallback for minimal local
  environments.
- Broadened Ansible validation discovery across Terraform blueprints, made
  scaffold markers fail validation, and moved generated Terraform artifact
  cleanup into an `always` block.
- Reworked bootstrap so the shell helper delegates to Ansible and the Ansible
  role owns reusable bootstrap checks.
