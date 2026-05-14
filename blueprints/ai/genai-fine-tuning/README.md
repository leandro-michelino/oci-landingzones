# GenAI Fine-Tuning And Dedicated AI Cluster

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this blueprint when a customer needs customer-managed fine-tuning for OCI
GenAI: training data in Object Storage, a dedicated AI cluster, a fine-tuned
model, and an optional private model endpoint.

## At A Glance

| Item | Details |
| --- | --- |
| Folder | `blueprints/ai/genai-fine-tuning` |
| Best fit | Domain-specific model customization with controlled dataset, cluster, model, and endpoint hand-offs. |
| Terraform shape | Training bucket, dedicated AI cluster, fine-tuned model, endpoint, IAM policy. |
| Default posture | All cost-driving resources are disabled until explicit enable flags are set. |
| Customer paths | Use with existing buckets/clusters, or after Core, Networking, and `genai-private`. |

## What This Deploys

| Resource | Enable Flag |
| --- | --- |
| Training dataset bucket | `create_training_bucket` |
| Dedicated AI cluster | `create_dedicated_ai_cluster` |
| Fine-tuned model | `create_fine_tuned_model` |
| GenAI endpoint | `create_endpoint` |
| IAM policy shell | `policy_statements` not empty |

## Inputs To Decide

| Input | What To Decide |
| --- | --- |
| `base_model_id` | The approved base model for fine-tuning. |
| `training_dataset_*` | Namespace, bucket, object path, and dataset type. |
| `cluster_type`, `cluster_unit_shape`, `cluster_unit_count` | Fine-tuning capacity and cost posture. |
| `training_config_type` | Fine-tuning algorithm/profile. |
| `generative_ai_private_endpoint_id` | Private endpoint from `genai-private`, when endpoint isolation is required. |

## Deployment Order

1. Confirm dataset ownership, format, and sensitive-data review.
2. Deploy or identify the training bucket.
3. Deploy or identify the dedicated AI cluster.
4. Create the fine-tuned model.
5. Create the endpoint only after model approval.
6. Hand the endpoint ID to `genai-gateway` or application teams.

## Outputs

| Output | Meaning |
| --- | --- |
| `training_bucket_name` | Bucket holding training data. |
| `dedicated_ai_cluster_id` | Dedicated AI cluster OCID. |
| `fine_tuned_model_id` | Fine-tuned model OCID. |
| `endpoint_id` | Optional endpoint OCID. |
| `access_policy_id` | IAM policy OCID. |

## Validation

```bash
terraform fmt -check
terraform init -backend=false
terraform validate
ansible-playbook ansible/plan.yml
```

Review `architecture/README.md` before using this pattern in a customer design.
