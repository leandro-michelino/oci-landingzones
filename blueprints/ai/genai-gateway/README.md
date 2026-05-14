# GenAI Multi-Model Gateway

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this blueprint when a platform team needs one governed front door for
multiple OCI GenAI endpoints, models, or routing functions. It gives app teams a
stable API Gateway endpoint while the platform team controls routes, quotas,
audit storage, logs, and IAM.

## At A Glance

| Item | Details |
| --- | --- |
| Folder | `blueprints/ai/genai-gateway` |
| Best fit | Multi-model GenAI front door with routing, usage plans, quotas, cost tags, audit bucket, and log group. |
| Terraform shape | API Gateway, deployment routes, usage plans, Object Storage audit bucket, Logging log group, IAM policy. |
| Default posture | Expensive or externally visible resources are disabled until explicit enable flags are set. |
| Customer paths | Run extension-only with existing gateway/subnet/model endpoints, or base-plus-extension after Core, Networking, and `genai-private`. |

## What This Deploys

| Resource | Enable Flag |
| --- | --- |
| API Gateway | `create_gateway` |
| API Gateway deployment routes | `create_deployment` |
| Usage plans and quotas | `create_usage_plans` |
| Prompt/response audit bucket | `create_audit_bucket` |
| Logging log group | `create_log_group` |
| IAM policy shell | `policy_statements` not empty |

## Inputs To Decide

Start with `terraform.tfvars.example`, then create a local ignored
`terraform.tfvars` with real OCIDs and reviewed route decisions.

| Input | What To Decide |
| --- | --- |
| `gateway_endpoint_type` | PRIVATE for internal platforms, PUBLIC only when internet exposure is intentional. |
| `routes` | Path, methods, and backend URL for each model or routing function. |
| `usage_plans` | Per-team quotas and rate limits. |
| `create_audit_bucket` | Whether prompt and response audit logs are stored in this blueprint. |
| `policy_statements` | Who can manage routes, invoke the gateway, and read audit data. |

## Deployment Order

This blueprint supports both extension-only and base-plus-extension paths.
For extension-only use, supply existing compartment, subnet, API Gateway,
deployment, GenAI endpoint, and IAM values. For base-plus-extension use, deploy
Core, Networking, optional Operations, and `genai-private` first, then pass the
outputs here.

1. Confirm the customer exposure model: private internal gateway or reviewed public endpoint.
2. Confirm GenAI endpoint/model/function backends and route names.
3. Decide quota, rate limit, and audit-retention rules per team.
4. Run `terraform plan` or `ansible-playbook ansible/plan.yml`.
5. Apply only after gateway routes, IAM, and logging destinations are reviewed.

## Outputs

| Output | Meaning |
| --- | --- |
| `gateway_id` | API Gateway OCID. |
| `deployment_id` | API Gateway deployment OCID. |
| `usage_plan_ids` | Usage plan OCIDs keyed by logical name. |
| `audit_bucket_name` | Prompt and response audit bucket name. |
| `log_group_id` | Gateway log group OCID. |

## Validation

Run from this folder:

```bash
terraform fmt -check
terraform init -backend=false
terraform validate
```

For repo-standard execution:

```bash
ansible-playbook ansible/plan.yml
```

See `architecture/README.md` before using this in a customer review.
