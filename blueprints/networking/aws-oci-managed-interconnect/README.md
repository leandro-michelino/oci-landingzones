# OCI + AWS Managed Interconnect

| Item | Details |
| --- | --- |
| Best fit | Dedicated private OCI/AWS workload networking with both cloud foundations declared and explicit partner activation. |
| Default behavior | Cloud creation disabled. Only a local Terraform validation contract is planned. |
| Cloud ownership | One explicit OCI compartment and a separately authenticated AWS account/project. |
| Evidence | Local schema validation and mocked plans only; see [validation record](../../../docs/multicloud/INTERCONNECT-COVERAGE.md). |
| Diagram | [Architecture and resource coverage](architecture/README.md). |

## Deployment Purpose

OCI + AWS Managed Interconnect provides a private-network deployment pattern. It does not
deploy applications, databases or a working cross-cloud connection by default.
All cloud resources are declared directly in this folder; the guarded Ansible
runners use this same Terraform root and the shared apply/destroy confirmations.

## Prerequisites

- A current supported interconnect region pair, offering access and quota, confirmed with both providers. Region names in examples do not establish eligibility.
- Explicit OCI tenancy/compartment, profile `DEFAULT` unless intentionally changed, and sufficient scoped network permissions. No tenancy policy is created.
- Existing remote account/project with billing and credentials configured through the provider's normal credential chain. No credentials are embedded.
- Valid IPv4 prefixes with non-overlapping cloud address spaces, approved application ports and owners for routes, DNS, security and operations.
- Approval of all billed dependencies before foundation creation (`costs_approved=true`). Circuit creation also requires `region_pair_verified=true` and a verified provider service.

## Configuration

Copy `terraform.tfvars.example` to ignored `terraform.tfvars` and replace every
placeholder. Keep `enable_foundation`, `enable_interconnect` and cost approval
false for documentation/default checks. An empty application-port set permits
no application ingress. Routes alone do not authorize traffic.

- `enable_foundation`: both cloud private network foundations; approval of cost is mandatory.
- `enable_interconnect`: OCI circuit request(s), requiring foundations and verified eligibility.
- `provider_service_id`: regional FastConnect service specifically matching this offering.
- `bandwidth_shape_name`: shape supported by that service; confirm current availability.
- `allowed_tcp_ports`: reviewed ports only, scoped to the opposite workload subnet.
- `aws_account_id`: expected AWS provider account and managed-service remote owner.
- `aws_region` / `aws_az`: matching regional gateway and private subnet placement.
- `aws_dx_asn` / `aws_vgw_asn`: distinct DXGW and VGW ASNs; this does not configure managed-service BGP manually.

## Deployment Workflow

1. Verify current OCI/AWS offering access, supported local region pair, account ownership, quota, bandwidth and charges. The disabled example's regions are placeholders, not an approved pair.
2. Set `costs_approved=true` and `enable_foundation=true`; inspect the plan before any apply. This creates both cloud networks and the VGW/DXGW association.
3. Confirm provider service selection specifically identifies the managed AWS Interconnect offering; do not substitute a generic partner connection.
4. Set `region_pair_verified=true`, the verified `provider_service_id` and `enable_interconnect=true`. Review the OCI-first private circuit request targeting the selected AWS account and region.
5. Copy the activation key securely from OCI and accept the managed multicloud Interconnect in AWS against the created Direct Connect gateway. This acceptance and the AWS managed object are operator/provider managed, outside this Terraform root.
6. Wait for provider provisioning and BGP UP. Verify the DRG and DXGW/VGW route scope and bidirectional application traffic with separately approved workloads.
7. Test provider-path resilience and capture runtime evidence before any production acceptance. No customer VIF or manually configured managed-service BGP peer is required by this blueprint.
8. Before teardown, coordinate termination of the managed object in both consoles. Remove the OCI circuit and gateway association, then the remaining foundations; verify both inventories.

## Local Validation

```bash
terraform init -backend=false
terraform validate
terraform test
```

Tests replace both providers with mocks; they make no cloud API calls. They test
disabled defaults, private foundations, scoped access, circuit parameters and
negative cost/address/region inputs. This is not provider API acceptance,
partner provisioning, BGP, routing, latency, encryption or failover evidence.

## Outputs And Operations

`resource_ids` identifies key created networking resources. `blueprint_name` and
`name_prefix` support runbooks. Read identifiers and service activation tokens
only through approved local workflows. Keep all local inputs, saved plans and
state files outside Git. Enable a reviewed encrypted remote backend before use.

Use `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` for the
shared runner. Apply/destroy require its existing confirmation environment
variables. This request authorizes code and diagrams, not cloud deployment.

## Limits

No VPN fallback, workloads, DNS resolver/records, customer IAM policies or
traffic probes are created. The cloud backbones remain provider-owned.
Private transport alone does not establish application encryption or an SLA.
Provider/account support and live circuit behavior remain unverified.

## Official References

- [Oracle Interconnect for AWS](https://docs.oracle.com/en-us/iaas/Content/multicloud/interconnect-aws.htm)
- [AWS managed create/accept workflow](https://docs.aws.amazon.com/interconnect/latest/userguide/getting-started-multicloud.html)
- [AWS Direct Connect gateway association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dx_gateway_association)
- [OCI virtual circuit provider schema](https://docs.oracle.com/en-us/iaas/tools/terraform-provider-oci/latest/docs/r/core_virtual_circuit.html)
