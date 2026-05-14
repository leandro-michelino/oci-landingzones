# Network Load Balancer Landing Zone

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this blueprint when a workload needs Layer 4 TCP, UDP, or mixed protocol
load balancing with private backend sets, health checks, optional public or
private exposure, and clear network ownership boundaries.

## At A Glance

| Item | Details |
| --- | --- |
| Folder | `blueprints/networking/network-load-balancer` |
| Best fit | Layer 4 service entry point for database, TCP, UDP, or non-HTTP workloads. |
| Terraform shape | Network Load Balancer, backend sets, backends, listeners, IAM policy. |
| Default posture | Private by default; creation disabled until subnet and listener design are approved. |
| Customer paths | Extension-only against an existing VCN, or base-plus-extension after Networking. |

## What This Deploys

| Resource | Enable Flag |
| --- | --- |
| Network Load Balancer | `create_network_load_balancer` |
| Backend sets | `backend_sets` map |
| Backend registrations | `backend_sets[*].backends` |
| Listeners | `listeners` map |
| IAM policy shell | `policy_statements` not empty |

## Inputs To Decide

| Input | What To Decide |
| --- | --- |
| `is_private` | Private internal service vs reviewed public Layer 4 ingress. |
| `subnet_id`, `network_security_group_ids` | Placement and allowed traffic. |
| `backend_sets` | Load balancing policy, health checks, and targets. |
| `listeners` | Protocol and port exposure. |
| `is_preserve_source_destination` | Whether the workload requires source/destination preservation. |

## Deployment Order

1. Confirm the L4 use case and exposure model.
2. Confirm subnet, NSGs, backend target type, health check, and listener ports.
3. Add backend sets and listeners in local ignored tfvars.
4. Run `terraform plan` or `ansible-playbook ansible/plan.yml`.
5. Apply after network and application owners approve the traffic path.

## Outputs

| Output | Meaning |
| --- | --- |
| `network_load_balancer_id` | Network Load Balancer OCID. |
| `network_load_balancer_ip_addresses` | Assigned IP addresses when Terraform creates the NLB. |
| `backend_set_names` | Backend set names keyed by logical name. |
| `listener_ids` | Listener OCIDs keyed by logical name. |
| `access_policy_id` | Optional IAM policy OCID. |

## Validation

```bash
terraform fmt -check
terraform init -backend=false
terraform validate
ansible-playbook ansible/plan.yml
```

Review `architecture/README.md` before routing production traffic.
