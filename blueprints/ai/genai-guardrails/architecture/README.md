# GenAI Guardrails And Observability Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

## Deployment Purpose

Add auditability and security review controls around GenAI workloads without
forcing every model-serving blueprint to reimplement the same observability
shape. The blueprint collects logs, archives reviewed records, creates alarm
hooks, and provides a Cloud Guard recipe placeholder for customer-specific
detection rules.

## Architecture At A Glance

| Layer | Responsibility |
| --- | --- |
| Log source | Gateway, Functions router, application, or model endpoint telemetry. |
| Service Connector | Moves selected records to archive, stream, function, or topic target. |
| Audit bucket | Stores redacted prompt and response records. |
| Monitoring alarms | Token budget, error rate, latency, and unusual activity alerts. |
| Cloud Guard | Detector recipe shell for GenAI-specific signals. |
| IAM | Security reviewer and service permissions. |

## ASCII Architecture

```text
GenAI Gateway / App / Endpoint
      |
      | logs, metrics, events
      v
Logging Log Group
      |
      | selected records
      v
Service Connector Hub
 |-- Object Storage audit bucket
 |-- Streaming topic for SIEM pipeline
 |-- Function for PII redaction
 `-- Notification topic for alerting
      |
      v
Monitoring Alarms + Cloud Guard Detector Recipe
      |
      v
Security Reviewer / Audit Reader Groups
```

## Terraform Components

| File | Purpose |
| --- | --- |
| `main.tf` | Bucket, log group, Service Connector, Cloud Guard recipe, alarms, IAM. |
| `variables.tf` | Connector, alarm, detector, and policy inputs. |
| `outputs.tf` | Guardrail resource IDs for runbooks and downstream wiring. |
| `terraform.tfvars.example` | Example alarm and disabled create flags. |
| `ansible/*.yml` | Local plan, apply, and destroy wrappers. |

## Request And Deployment Flow

1. Identify the GenAI log source and metrics namespace.
2. Decide whether records are archived directly or processed by a redaction function.
3. Configure token, error, and unusual-volume alarms.
4. Add Cloud Guard detector recipe wiring where the customer uses Cloud Guard.
5. Publish audit bucket and alarm outputs to security runbooks.

## Traffic And Trust Boundaries

- Raw prompts and responses can contain sensitive data.
- Redaction should happen before long-term archive when required by policy.
- Audit bucket readers should be separate from GenAI app operators.
- Monitoring destinations should be approved incident channels.
- Detector recipes should be reviewed with the security team before enforcement.

## Detailed Architecture Notes

The blueprint is intentionally an overlay. It can attach to the GenAI gateway,
an application-owned Function router, or a workload that already logs GenAI
calls. This keeps the serving path independent from the audit path.

Service Connector Hub can target Object Storage, Streaming, Functions, or
Notifications. The variables expose those target IDs rather than making one
opinion mandatory.

Cloud Guard behavior is customer-specific, so this blueprint creates the recipe
shell and leaves detector rule tuning to the security review.

## Operational Boundaries

- Do not commit real prompts, responses, detector rules with customer data, or
  SIEM endpoint details.
- Keep connector source IDs and alarm destinations in local tfvars.
- Pair this blueprint with `genai-gateway` for shared API platforms.
- Pair it with `embedding-pipeline` or `document-intelligence` for data-heavy AI
  workflows.

## Review Checklist

- [ ] Log source and destination are approved.
- [ ] Sensitive prompt/response handling is documented.
- [ ] Alarm queries match the deployed GenAI service namespace.
- [ ] Notification destinations are owned by the right operations team.
- [ ] Cloud Guard recipe scope is reviewed before enforcement.
- [ ] Audit-reader IAM is least privilege.
