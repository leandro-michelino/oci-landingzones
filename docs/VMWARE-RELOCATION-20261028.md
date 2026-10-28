# VMware Blueprint Family Relocation

Review date: 2026-10-28. This is a repository organization and documentation change, with local checks only.

The following generic VMware patterns moved from `blueprints/industry/` to `blueprints/vmware/`:

| Blueprint | New location |
| --- | --- |
| Oracle Cloud VMware Solution | [ocvs](../blueprints/vmware/ocvs/) |
| OCVS with on-premises HCX | [ocvs-onprem-hcx](../blueprints/vmware/ocvs-onprem-hcx/) |
| Azure AVS and OCVS Interconnect | [azure-avs-ocvs-interconnect](../blueprints/vmware/azure-avs-ocvs-interconnect/) |
| Azure AVS, OCVS and on-premises triangle | [azure-avs-ocvs-onprem-triangle](../blueprints/vmware/azure-avs-ocvs-onprem-triangle/) |

These patterns describe a workload platform rather than an industry. Existing healthcare and other industry-specific blueprints remain in `industry/`. The catalog still contains 88 entry points, now organized into 14 families.

Catalogs, documentation links, diagram generators, coverage defaults and the reviewed connector/source registry use the new locations. Each editable diagram retains its overview and resource/input detail pages. VMware topology, application suggestions, direct customer ExpressRoute leg and conditional connectivity gates remain unchanged.

## Deployment Compatibility

Resource definitions, names, tags, Terraform addresses, provider requirements and cost/enable defaults are unchanged. Wrapper module URLs remain pinned to commit `94ad89026bbf2ddbda531976a500e6d2ee084c7f` and its historical `blueprints/industry/ocvs` source path. That immutable source location remains valid; replacing only its path while retaining the old revision would break module retrieval.

For an existing deployment, transfer its protected deployment state, backend configuration and private inputs to the new working location, or use the same configured remote backend. Do not apply from a fresh workspace without the existing deployment state. The move does not authorize cloud changes, migration or resource recreation.

## Local Validation

- `terraform validate`: all four relocated roots passed.
- `terraform test`: 44 mocked plans passed (19 OCVS, 7 HCX, 9 AVS Interconnect, 9 triangle). The hybrid wrappers override the pinned OCVS module in these tests; this is configuration evidence only.
- Ansible syntax: all 18 relocated playbooks passed, including Azure runners.
- Bicep: both relocated Azure templates compiled successfully to temporary local outputs.
- Resource inventories retain source fingerprints and pinned module revisions. Repository and connector checks are recorded with the accompanying diagram batch.

No cloud API deployment, VMware VM migration, HCX session, BGP adjacency, ExpressRoute/FastConnect activation or application traffic was tested. Historical validation metadata retains its original scope and dates.
