# Redis Cache Landing Zone

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this blueprint when an application team needs a private Redis-compatible
cache for sessions, API acceleration, queue-adjacent state, or low-latency read
patterns. It provides OCI Cache with Redis cluster wiring, NSG hand-off, alarm
hooks, and IAM policy scaffolding.

## At A Glance

| Item | Details |
| --- | --- |
| Folder | `blueprints/extensions/redis-cache` |
| Best fit | Private cache/session layer for application platforms. |
| Terraform shape | Redis cluster, Monitoring alarms, Vault secret hand-off, IAM policy. |
| Default posture | Cluster creation is disabled until subnet, node sizing, and access model are reviewed. |
| Customer paths | Extension-only with an existing app VCN, or base-plus-extension after Core and Networking. |

## What This Deploys

| Resource | Enable Flag |
| --- | --- |
| OCI Cache with Redis cluster | `create_cluster` |
| Monitoring alarms | `alarms` map |
| IAM policy shell | `policy_statements` not empty |
| Vault secret reference | `vault_secret_id` |

## Inputs To Decide

| Input | What To Decide |
| --- | --- |
| `subnet_id`, `nsg_ids` | Which private app subnets may reach Redis. |
| `node_count`, `node_memory_in_gbs` | Capacity and HA posture. |
| `cluster_mode`, `shard_count` | Standalone cache or sharded cache. |
| `oci_cache_config_set_id` | Whether to apply a customer config set. |
| `alarms` | Memory pressure, evictions, connection saturation, and failover signals. |

## Deployment Order

1. Confirm whether Redis is session state, transient cache, or shared platform cache.
2. Confirm subnet, NSG, and application caller boundaries.
3. Choose node count, memory, cluster mode, and backup/restore posture.
4. Run `terraform plan` or `ansible-playbook ansible/plan.yml`.
5. Hand endpoint outputs and Vault secret references to the app team.

## Outputs

| Output | Meaning |
| --- | --- |
| `redis_cluster_id` | Redis cluster OCID. |
| `redis_primary_endpoint` | Primary FQDN when Terraform creates the cluster. |
| `redis_discovery_endpoint` | Discovery FQDN when Terraform creates the cluster. |
| `vault_secret_id` | Optional application auth-material hand-off secret. |
| `alarm_ids` | Monitoring alarm OCIDs. |

## Validation

```bash
terraform fmt -check
terraform init -backend=false
terraform validate
ansible-playbook ansible/plan.yml
```

See `architecture/README.md` before customer review.
