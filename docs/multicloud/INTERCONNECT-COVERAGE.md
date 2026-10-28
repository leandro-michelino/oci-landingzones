# Dedicated Interconnect Coverage And Local Validation

Reviewed October 28, 2026. Source implementation, cloud provisioning and runtime
connectivity are separate evidence categories. No cloud resource was provisioned.

## Existing And Added Coverage

| Cloud pair | Blueprint | What the source implements | Remaining activation / evidence |
| --- | --- | --- | --- |
| OCI / Azure | [Hub-spoke / Azure vWAN ExpressRoute](../../blueprints/networking/hub-spoke-with-azure-vwan-expressroute/README.md) | OCI foundation, optional partner FastConnect circuit and separate Azure Bicep vWAN/ExpressRoute resources. | Service key, provider circuit/peering inputs, region eligibility, provisioning and traffic verification. |
| OCI / Azure | [Dual connectivity](../../blueprints/networking/azure-oci-dual-connectivity/README.md) and [vWAN transit](../../blueprints/networking/azure-vwan-oci-drg-transit/README.md) | Interconnect-ID contracts with optional VPN/network foundations and separate Azure templates. | These contracts do not themselves create or validate the referenced FastConnect circuit. |
| OCI / AWS | [Existing hybrid backbone](../../blueprints/networking/aws-oci-hybrid-network-backbone/README.md) | OCI and AWS network/VPN foundations plus references to existing Direct Connect/FastConnect. | Existing circuit IDs are contracts; this is not automated managed Interconnect creation. |
| OCI / AWS | **New [managed Interconnect](../../blueprints/networking/aws-oci-managed-interconnect/README.md)** | OCI/ AWS networks, DRG, VGW, DXGW, association, routes, scoped SG rules and optional OCI-first managed circuit request. | Operator accepts activation key in AWS against DXGW; provider-managed AWS Interconnect object remains outside Terraform ownership. No working BGP/traffic evidence. |
| OCI / GCP | **New [Partner Interconnect](../../blueprints/networking/gcp-oci-partner-interconnect/README.md)** | OCI/Google networks, Cloud Router, two Partner VLAN attachments, optional two FastConnect VCs, scoped firewalls and optional two router interfaces/peers. | Partner provisioning, assigned-address reconciliation, attachment activation and BGP/traffic evidence. No Google project, billing account or organizational perimeter is created. |

Azure already had an implementation and was not duplicated. The two additions
close the explicit managed-AWS and Google Partner topology gaps. Neither is a
claim that every provider workflow is fully automated or that circuits are live.
The new roots have no workloads, VPN backup, DNS service or IAM policy creation.

## Product Distinctions

- Oracle Interconnect for Azure uses FastConnect and ExpressRoute in supported region pairs. A supplied circuit identifier does not prove circuit provisioning or route exchange. [Oracle Azure documentation](https://docs.oracle.com/en-us/iaas/Content/multicloud/interconnect-azure.htm).
- Oracle Interconnect for AWS has a managed create/accept activation workflow attached to OCI DRG and AWS DXGW. It is distinct from an ordinary carrier-provided Direct Connect/FastConnect connection. [Oracle AWS documentation](https://docs.oracle.com/en-us/iaas/Content/multicloud/interconnect-aws.htm), [AWS activation workflow](https://docs.aws.amazon.com/interconnect/latest/userguide/getting-started-multicloud.html).
- Oracle Interconnect for Google Cloud pairs Partner VLAN attachments and FastConnect virtual circuits. These are not customer-owned physical Dedicated/Cross-Cloud Interconnect ports. [Oracle Google documentation](https://docs.oracle.com/en-us/iaas/Content/multicloud/interconnect-gcp.htm), [Google attachment provider documentation](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_interconnect_attachment).

Current eligible regions, accounts and bandwidth must be confirmed before use.
`region_pair_verified` records an operator check; it is not an automated service
availability lookup. These examples do not override project cloud-test scopes.

## Validation Evidence

| New blueprint | Exact provider versions | Checks | Result |
| --- | --- | --- | --- |
| AWS managed Interconnect | oracle/oci 9.11.0; hashicorp/aws 6.70.0 | Terraform validate; 9 mocked plan cases | Passed locally |
| GCP Partner Interconnect | oracle/oci 9.11.0; hashicorp/google 7.46.2 | Terraform validate; 11 mocked plan cases | Passed locally |

The committed `tests/configuration-regressions.tftest.hcl` files reproduce the
mock cases. They cover disabled defaults, private foundations, empty/scoped
access, approved circuit parameters, rejected cost/eligibility settings,
invalid application ports, overlapping/out-of-network prefixes and GCP BGP/ASN
requirements. Mocks do not invoke cloud APIs or establish provider acceptance.

Reproduce from the repository root:

```bash
terraform -chdir=blueprints/networking/aws-oci-managed-interconnect init -backend=false
terraform -chdir=blueprints/networking/aws-oci-managed-interconnect validate
terraform -chdir=blueprints/networking/aws-oci-managed-interconnect test
terraform -chdir=blueprints/networking/gcp-oci-partner-interconnect init -backend=false
terraform -chdir=blueprints/networking/gcp-oci-partner-interconnect validate
terraform -chdir=blueprints/networking/gcp-oci-partner-interconnect test
```

No live plan, apply, service activation, BGP session, packet-flow, latency,
failover or cleanup test was performed. Account/region offering eligibility,
application behavior, paid charges and partner teardown remain unverified.

## Diagram Evidence

Both blueprints include an editable overview, PNG, resource maps for each cloud,
a local-contract page, identifier references and source inventory. There are
36 source declarations: OCI 14, AWS 11, GCP 9 and local contracts 2. Collection
resources expand only from enabled inputs; these are not deployed instance counts.
The AWS managed object/activation is explicitly described as externally managed.
No imaginary customer-managed VIF, BGP peer or physical cross-connect is added.

The original 80-entry conversion backlog stays at 49 complete / 31 pending.
The catalog now has 82 entry points and 51 complete overview pairs. This specific
request brings the GCP networking base forward; other planned GCP counterparts
remain pending in the [follow-on plan](GCP-OCI-BLUEPRINTS.md).

Diagram layout/export, visual review, source-to-node inventory checks and native
XML reference checks passed for all ten new pages. Six Ansible playbooks passed
syntax checks. TFLint passed for both new roots, as did repository contracts,
local Markdown links and the resource-inventory parser regression tests.
