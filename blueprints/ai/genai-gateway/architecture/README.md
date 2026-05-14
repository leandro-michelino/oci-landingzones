# GenAI Multi-Model Gateway Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

## Deployment Purpose

Provide a governed API front door for one or more OCI GenAI models, private
endpoints, or routing functions. The blueprint separates app-team consumption
from platform-team model operations by putting routes, quotas, logging, and IAM
in one reviewed deployment folder.

## Architecture At A Glance

| Layer | Responsibility |
| --- | --- |
| API Gateway | Stable HTTPS endpoint, path routing, and private/public exposure decision. |
| Usage plans | Per-team rate limits and quota controls. |
| GenAI backends | Existing GenAI endpoints, model APIs, or routing functions. |
| Audit storage | Prompt and response archive bucket for reviewed workloads. |
| Logging | Gateway and routing telemetry log group. |
| IAM | Caller, operator, and audit-reader policy hand-offs. |

## ASCII Architecture

```text
App Team A          App Team B          Batch Job
    |                   |                  |
    | HTTPS + IAM       | HTTPS + IAM      | HTTPS + IAM
    v                   v                  v
+--------------------------------------------------+
| API Gateway: GenAI Multi-Model Gateway           |
| |-- /chat        -> GenAI endpoint or router     |
| |-- /embed       -> embedding model endpoint     |
| |-- /classify    -> specialist model/function    |
| `-- usage plans  -> quota + rate limit per team  |
+--------------------------------------------------+
        |                    |
        | route by path      | emit telemetry
        v                    v
OCI GenAI Endpoints      Logging Log Group
        |                    |
        | prompt/response    | archived records
        v                    v
Object Storage Audit Bucket  Audit Reader Group
```

## Terraform Components

| File | Purpose |
| --- | --- |
| `main.tf` | API Gateway, deployment routes, usage plans, audit bucket, log group, and IAM policy. |
| `variables.tf` | Operator-facing input contract for routes, quotas, gateway placement, and audit storage. |
| `outputs.tf` | Gateway, deployment, usage plan, audit bucket, and policy hand-off values. |
| `terraform.tfvars.example` | Safe example with all expensive and exposed resources disabled. |
| `ansible/*.yml` | Repo-standard local plan, apply, and destroy wrappers. |

## Request And Deployment Flow

1. Customer chooses whether the gateway is private or public.
2. Platform team maps model tasks to route paths.
3. App/team quotas are written as `usage_plans`.
4. Audit and log destinations are confirmed.
5. Terraform creates or references the gateway and deployment.
6. Downstream app teams receive the gateway endpoint and usage contract.

## Traffic And Trust Boundaries

- Public endpoint use must be intentional and reviewed.
- Private endpoint mode expects private DNS and network reachability from apps.
- API Gateway does not replace model-level authorization; IAM and service
  policies still control who can call GenAI.
- Prompt and response archives may contain sensitive data and should use private
  buckets, retention rules, and least-privilege audit-reader groups.
- Route backends should point to reviewed GenAI endpoints or routing functions.

## Detailed Architecture Notes

The gateway can run in front of a single model endpoint or a broader model
portfolio. Simple deployments map one route to one backend URL. Mature
deployments can point routes at an Oracle Functions router that chooses a model
based on headers, task type, latency, or cost.

Usage plans are designed for chargeback and fairness. They are not a substitute
for budget alarms, but they help prevent one application from consuming shared
capacity unexpectedly.

The audit bucket is optional because some customers centralize prompt logging in
Logging Analytics or a SIEM. When enabled here, it provides a clear hand-off for
retention, redaction, and incident-review processes.

## Operational Boundaries

- This blueprint can run extension-only with existing subnet, gateway, route,
  model, and IAM values.
- In a full landing zone, deploy Core, Networking, Operations, and
  `genai-private` before this gateway.
- Keep backend URLs, customer paths, quota values, and IAM group names in local
  ignored tfvars or approved pipeline variables.
- Do not commit prompt examples, real model payloads, customer hostnames, or
  private API keys.

## Review Checklist

- [ ] Gateway endpoint type is correct for the customer exposure model.
- [ ] Every route has a reviewed backend and timeout.
- [ ] Usage plans are aligned to team quotas and budget expectations.
- [ ] Audit storage and log retention are approved.
- [ ] IAM policy statements are scoped to callers, operators, and auditors.
- [ ] Outputs are passed only to approved downstream application owners.
