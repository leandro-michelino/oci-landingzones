# GenAI Guardrails And Observability

Use this blueprint when GenAI workloads need responsible-AI controls around
audit logging, PII handling, anomaly alarms, Cloud Guard hooks, and security
reviewer access.

## At A Glance

| Item | Details |
| --- | --- |
| Folder | `blueprints/ai/genai-guardrails` |
| Best fit | Guardrail overlay for `genai-private`, `genai-gateway`, or app-owned GenAI endpoints. |
| Terraform shape | Audit bucket, log group, Service Connector, Cloud Guard detector recipe shell, Monitoring alarms, IAM policy. |
| Default posture | Create flags are disabled until the customer chooses destinations and alarms. |

## Practical Use Cases

- **Safety overlay:** Add guardrails around existing GenAI endpoints without rebuilding the whole application stack.
- **Policy review:** Make blocked categories, sensitive data handling, and response controls explicit.
- **Observability layer:** Capture guardrail events so teams can tune policy based on real behavior.
- **Pre-production AI approval:** Give risk teams a clear checkpoint before model access is opened widely.

## What This Deploys

| Resource | Enable Flag |
| --- | --- |
| Redacted audit bucket | `create_audit_bucket` |
| Guardrail log group | `create_log_group` |
| Service Connector | `create_service_connector` |
| Cloud Guard detector recipe | `create_cloud_guard_recipe` |
| Monitoring alarms | `alarms` map |
| IAM policy shell | `policy_statements` not empty |

## Inputs To Decide

| Input | What To Decide |
| --- | --- |
| `connector_source_*` | Where prompt, response, or gateway logs come from. |
| `connector_target_*` | Object Storage, Streaming, Function, or Notification destination. |
| `alarms` | Token budget, error rate, and unusual-volume queries. |
| `source_detector_recipe_id` | Optional Cloud Guard recipe to clone. |
| `policy_statements` | Access for services, auditors, and security reviewers. |

## Deployment Order

Deploy this after the GenAI endpoint or gateway emits logs. For extension-only
use, supply existing log, bucket, topic, and detector values. For full use,
deploy Core, Operations, and the GenAI serving blueprint first.

## Outputs

| Output | Meaning |
| --- | --- |
| `audit_bucket_name` | Redacted archive bucket. |
| `log_group_id` | Log group OCID. |
| `service_connector_id` | Service Connector OCID. |
| `detector_recipe_id` | Cloud Guard detector recipe OCID. |
| `alarm_ids` | Monitoring alarm OCIDs. |

## What Good Looks Like

- Guardrail policies map to the application risk profile.
- Allowed, blocked, and redacted examples are tested.
- Events and logs are available for review.
- Application owners know how policy changes will affect users.

## Validation

```bash
terraform fmt -check
terraform init -backend=false
terraform validate
ansible-playbook ansible/plan.yml
```
