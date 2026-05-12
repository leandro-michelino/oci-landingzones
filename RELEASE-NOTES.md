# Release Notes

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

## Unreleased

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

### Changed

- Removed unused `region_key_map` local configuration blocks from modules so
  module locals only keep values currently used by Terraform.
- Reworked the repository validation helper so `scripts/validate-all.sh`
  delegates to Ansible when available, with a shell fallback for minimal local
  environments.
- Scoped Ansible validation discovery to the implemented Phase 1-5 blueprint
  families and moved generated Terraform artifact cleanup into an `always`
  block.
- Reworked bootstrap so the shell helper delegates to Ansible and the Ansible
  role owns reusable bootstrap checks.
