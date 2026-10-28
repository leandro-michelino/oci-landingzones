# VMware Hybrid Local Validation / 2026-10-28

## Implemented Scope

Three new industry entry points compose the OCVS foundation at immutable revision
`94ad89026bbf2ddbda531976a500e6d2ee084c7f`:

- `blueprints/vmware/ocvs-onprem-hcx`
- `blueprints/vmware/azure-avs-ocvs-interconnect`
- `blueprints/vmware/azure-avs-ocvs-onprem-triangle`

OCI may create the inherited dense/vSAN SDDC, an isolated DRG, its VCN attachment
and partner FastConnect virtual circuits. All creation flags default false.
The Azure companions may create an AVS private cloud, HCX add-on, Oracle-facing
ExpressRoute circuit, authorization and AVS Global Reach associations, separately
from Terraform. Existing OCVS network IDs, carrier circuits, HCX Connector,
route/security/DNS configuration and guest/application operations remain external.
The [runbook](multicloud/VMWARE-HYBRID.md) describes ownership and sequence.

## Passed Local Checks

| Check | Result | Actual evidence/scope |
| --- | --- | --- |
| Terraform schema | Three roots passed `terraform validate` with oracle/oci 9.11.0 | New roots plus the source-pinned OCVS module; no API calls |
| Mocked wrapper plans | 7 + 9 + 9 = 25 passed | `tests/configuration-regressions.tftest.hcl` in each new root |
| TFLint | All three roots passed | `--call-module-type=none`; inherited implementation is not linted again |
| Azure compilation | Two Bicep files compiled without warnings | Standalone bundled Bicep compiler; ARM output only in temporary files |
| Ansible syntax | 15 playbooks passed | Nine OCI and six Azure wrappers; no playbook execution |

The wrapper tests explicitly override the pinned OCVS module. They test disabled
cloud defaults, transport cost approval, DRG/attachment creation intent, circuit
prerequisites, required site keys, expected circuit multiplicity and the root
HCX requirement. Azure cases also reject missing BGP pairs and duplicate /30
networks. They do not retest the inherited OCVS module's network lookups,
cluster creation or licensing controls. The inherited module has its separate
[prior evidence](OCVS-20261028.md); that evidence is not upgraded to a new live
result. Local schema validation includes the pinned module's real schema.

An initial test harness assumed root mock-data defaults applied to the nested
blueprint provider. That assumption failed in the isolated test setup. The
wrapper tests were corrected to override the component explicitly, and all 25
final cases passed. Tests pin non-secret inputs so ignored local tfvars cannot
change their intended scope. The local restricted process environment initially
blocked provider/linter plugin startup; rerunning these local checks with process
access succeeded. No workaround accessed a cloud API.

## Diagram And Application Scope

Editable native draw.io files and PNGs distinguish declared cloud resources,
existing identifiers, service-managed components and external workflow steps.
Azure AVS and ExpressRoute use exact bundled Azure SVGs; VMware vCenter, NSX
Manager and guest VMs use their exact bundled `vvd` stencils. OCVS uses an
identified SDDC box because no dedicated icon was found in the installed OCI
Toolkit v24.2 or draw.io library. No substitute cloud service icon is used.

The [generic workload proposals](multicloud/VMWARE-WORKLOADS.md) use NGINX,
Spring Boot and PostgreSQL on VMs and also describe legacy applications,
development/test and recovery rehearsals. The existing OCVS blueprint receives
the same industry-neutral proposal guidance. Dashed application arrows are
proposed flows, not installed guests, open firewall rules or observed traffic.
No workload has been run, benchmarked, backed up, restored or migrated here.

## Unverified External Gates

- AVS-to-Oracle ExpressRoute Global Reach eligibility for the exact region/provider pairing; keep `avsTransitVerified=false` until vendor confirmation.
- Actual AVS/OCVS regional capacity, versions, quotas, VMware/guest licenses, dense shape and commitment selections.
- Partner provisioning, service keys, circuit bandwidth, BGP sessions, learned routes and failover behavior.
- Existing per-cluster OCVS networks, NSX routes/firewalls, private DNS/NTP, MTU and activation/update egress.
- HCX interoperability, site pairing, profiles, per-pair service meshes, appliances and tunnel health.
- Application transactions, database consistency, replication, backup/restore, migration, RPO/RTO and rollback.

Oracle's Interconnect documentation does not establish onprem transit through
either cloud. The triangle uses separate onprem connections to OCI and AVS.
Microsoft's AVS networking documentation explains the need for appropriate
circuit connectivity; it does not certify this exact AVS/Oracle pairing.
Local compilation is not a support endorsement. No paid service activation,
live deployment, cloud discovery, runtime test or live cleanup was performed.

## Final Diagram And Repository Checks

The targeted resource inventories passed against root Terraform, the immutable
OCVS module source and companion Bicep. There are 32 declarations and 48
existing-reference inputs across the three new roots. Native-page IDs and
connector references are valid; generated overviews match their authoring
scripts and the reviewed source/connector contract. The global audit passed
for 77 blueprint plus one conceptual overviews, 662 connectors, 287 native
files/PNGs and 14 OCI/cloud bridges. Source condition and icon/text-crossing
checks passed. Four resource-coverage regression tests passed. The repository
contracts, generated index, naming and Markdown-link checks passed.

Original conversion coverage is still 69/80; current catalog coverage is 77/88
including eight additions. These counts do not imply any new real deployment.

## Explicit FastConnect Diagram Revision

All four VMware overviews, including the base OCVS component, now use the official FastConnect connection badge. On-premises-to-OCI links end at the DRG, which associates with the prepared OCVS VCN. Azure-facing links identify both FastConnect and ExpressRoute. The triangle retains its independent customer-to-Azure ExpressRoute leg; HCX pairing arrows remain external overlays.

The base component's DRG, attachment and circuit are marked existing/external, not created by its Terraform. Hybrid source already declared the optional private partner VCs per role; infrastructure, guards and disabled defaults are unchanged. Diagram/native-page/source checks passed, and all four PNGs were visually inspected. The global connection audit now has 710 reviewed connectors across 87 blueprint and one conceptual overview; native document count is 320. No cloud operation or runtime verification was performed for this diagram revision. Prior Terraform/mock/Bicep results retain their original scope and were not rerun for this documentation-only change.
