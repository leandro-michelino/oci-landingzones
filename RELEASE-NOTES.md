# Release Notes

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

## Unreleased

### Added

- Initial project README.
- Base repository structure for modules, blueprints, environments, docs, tests,
  and scripts.
- Terraform scaffold files for all planned modules and blueprints.
- Ansible scaffold for inventories, playbooks, roles, and local orchestration.
- Dedicated opt-in CIS Level 1 and Level 2 landing zone blueprint folders.
- CIS Level 1 and Level 2 wrappers wired to the implemented core/IAM
  foundation while remaining opt-in.
- Phase 1 core implementation for landing zone compartments and governance
  tagging.
- Phase 2 IAM foundation implementation for IAM groups, dynamic groups, and
  scoped policies.
- Phase 3 networking foundation implementation for reusable hub VCN, spoke VCN,
  DRG, IPSec VPN, OCI Network Firewall, FastConnect, private DNS, ZPR, Bastion,
  and network virtual appliance modules.
- Deployable networking foundations for standalone three-tier, standalone
  private-only, custom standalone, standalone ZPR, brownfield VCN references,
  DRG hub-spoke, IPSec, FastConnect, Bastion, OCI Network Firewall, NVA,
  private DNS, ZPR micro-segmentation, dual-region DR, multicloud, shared
  services, transit NVA HA, and regional prod/nonprod hub blueprints.
- Self-contained deployment README files and local architecture image locations
  across core, CIS, identity, networking, operating entity, and extension
  blueprints.
- Expanded deployment pattern catalog with new compliance, disaster recovery,
  operating entity, networking, data platform, and industry blueprint
  scaffolds.
- Project guardrails for ignore rules, pre-commit checks, contribution flow, and
  security handling.
- Initial documentation for naming conventions, deployment flow, CIS mapping,
  variables, architecture diagrams, runbooks, and the core blueprint.
