# GenAI Fine-Tuning And Dedicated AI Cluster Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

## Deployment Purpose

Create a repeatable fine-tuning landing zone for OCI GenAI. The blueprint keeps
training data, dedicated capacity, fine-tuned model creation, endpoint exposure,
and IAM policy decisions in one deployment folder.

## Architecture At A Glance

| Layer | Responsibility |
| --- | --- |
| Training bucket | Stores reviewed JSONL or service-supported training data. |
| Dedicated AI cluster | Provides reserved capacity for fine-tuning. |
| Fine-tuned model | Customer-specific model derived from an approved base model. |
| Model endpoint | Optional private endpoint for inference. |
| IAM policy | Separates ML engineers, deployers, and callers. |

## ASCII Architecture

```text
Dataset Owner
    |
    | approved training data
    v
Object Storage Training Bucket
    |
    | namespace / bucket / object
    v
OCI GenAI Fine-Tuning Job
    |
    | uses base_model_id
    | uses dedicated_ai_cluster_id
    v
Fine-Tuned Model
    |
    | optional deploy
    v
GenAI Endpoint
    |
    | hand-off
    v
GenAI Gateway / App / Batch Caller

IAM: ML engineer -> dataset + fine tuning
IAM: platform ops -> cluster + endpoint
IAM: app caller -> endpoint invoke
```

## Terraform Components

| File | Purpose |
| --- | --- |
| `main.tf` | Object Storage bucket, dedicated AI cluster, model, endpoint, and IAM policy. |
| `variables.tf` | Dataset, cluster, training config, endpoint, and policy inputs. |
| `outputs.tf` | Cluster, model, endpoint, bucket, and policy hand-offs. |
| `terraform.tfvars.example` | Safe local example with create flags disabled. |
| `ansible/*.yml` | Standard plan, apply, and destroy wrappers. |

## Request And Deployment Flow

1. Data owner approves dataset content and storage location.
2. ML owner selects the base model and training configuration.
3. Platform owner confirms dedicated cluster shape and budget.
4. Terraform creates or references the training bucket and cluster.
5. Terraform creates the fine-tuned model.
6. Optional endpoint is created and passed to gateway or app owners.

## Traffic And Trust Boundaries

- Training data should stay in private Object Storage buckets.
- Fine-tuning capacity should live in the workload or AI platform compartment.
- Endpoint access should be granted to approved callers only.
- Dataset paths, model IDs, and endpoint IDs are deployment-specific and should
  stay in local tfvars or controlled pipeline variables.
- Private endpoint use should follow the network boundary from `genai-private`.

## Detailed Architecture Notes

The blueprint supports brownfield and greenfield use. Brownfield customers can
bring an existing dataset bucket and dedicated AI cluster. Greenfield customers
can let this folder create the bucket and cluster after Core and Networking are
already in place.

Fine-tuning settings intentionally remain explicit. Epoch count, batch size, and
learning rate are easy to overlook, so the variables keep them visible in
review. Expensive resources are disabled by default for safe validation.

The optional endpoint is separated from model creation so teams can run review
and approval before exposing the custom model to applications.

## Operational Boundaries

- This blueprint does not sanitize or generate training data.
- Do not commit datasets, customer examples, prompts, secrets, or model outputs.
- Use `genai-gateway` when multiple teams consume the endpoint.
- Use `genai-guardrails` when prompt logging, PII handling, or token alarms are
  required.

## Review Checklist

- [ ] Dataset has been approved for fine-tuning.
- [ ] Base model ID is correct and region-supported.
- [ ] Dedicated cluster shape and count are budget-approved.
- [ ] Endpoint creation is intentionally enabled or deferred.
- [ ] IAM statements separate ML engineers, operators, and callers.
- [ ] Outputs are documented for downstream consumers.
