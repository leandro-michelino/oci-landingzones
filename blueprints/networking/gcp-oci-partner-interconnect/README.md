# OCI + Google Cloud Partner Interconnect

| Item | Details |
| --- | --- |
| Best fit | Dedicated private OCI/GCP workload networking with both cloud foundations declared and explicit partner activation. |
| Default behavior | Cloud creation disabled. Only a local Terraform validation contract is planned. |
| Cloud ownership | One explicit OCI compartment and a separately authenticated GCP account/project. |
| Evidence | Local schema validation and mocked plans only; see [validation record](../../../docs/multicloud/INTERCONNECT-COVERAGE.md). |
| Diagram | [Architecture and resource coverage](architecture/README.md). |

## Deployment Purpose

OCI + Google Cloud Partner Interconnect provides a private-network deployment pattern. It does not
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
- `activate_attachments`: explicit Google attachment preactivation; false by default.
- `bgp_sessions`: per-edge approved Google/Oracle peering IPs with prefix lengths; no invented production addressing.
- `enable_bgp`: Google interfaces/peers only after provisioning; false by default.

## Deployment Workflow

1. Confirm existing Google project, billing, Compute API, IAM and current supported region pair.
2. Set `costs_approved=true` and `enable_foundation=true`; review the plan before any apply.
3. Create the private networks, Cloud Router and both Partner VLAN attachments.
4. Read `pairing_keys` securely and confirm the provider service and approved BGP addressing for each edge. Do not commit keys or assigned addresses.
5. Set `region_pair_verified=true`, `provider_service_id`, both `bgp_sessions` entries and `enable_interconnect=true`; review the two OCI private circuit requests.
6. Wait for partner provisioning. Refresh the attachments and reconcile the input BGP addresses with the actual assigned Cloud Router/customer addresses before enabling BGP.
7. Set `activate_attachments=true` after review and `enable_bgp=true` to configure the router interfaces and OCI peers. Import any partner-created interface/peer instead of creating a duplicate.
8. Verify both BGP sessions, advertisements, effective routes, bidirectional permitted traffic and single-edge loss using separately approved test workloads.
9. Before teardown, coordinate partner termination, remove BGP configuration/attachments and both OCI circuits, then remove the remaining foundation and verify both clouds.

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

- [Oracle Interconnect for Google Cloud](https://docs.oracle.com/en-us/iaas/Content/multicloud/interconnect-gcp.htm)
- [Google Partner Interconnect VLAN attachments](https://cloud.google.com/network-connectivity/docs/interconnect/how-to/partner/creating-vlan-attachments)
- [Google attachment provider schema](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_interconnect_attachment)
- [OCI virtual circuit provider schema](https://docs.oracle.com/en-us/iaas/tools/terraform-provider-oci/latest/docs/r/core_virtual_circuit.html)
