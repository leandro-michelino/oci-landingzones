# Redis Cache Landing Zone Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

## Deployment Purpose

This blueprint gives application teams a consistent private Redis cache pattern.
It documents subnet placement, NSG access, capacity choices, alarm hooks, IAM,
and secret hand-offs so Redis does not become an unmanaged side component.

## Architecture At A Glance

| Layer | Components |
| --- | --- |
| App access | Private application subnets and NSG-approved Redis flows. |
| Cache | OCI Cache with Redis cluster, node count, memory, and optional sharding. |
| Security | No public endpoint by default, optional Vault secret reference, group-scoped IAM. |
| Operations | Monitoring alarms for memory, connections, failover, and saturation. |
| Handoff | Endpoint, cluster ID, secret ID, and alarm IDs. |

## ASCII Architecture

```text
+--------------------------------------------------------------------------------+
|                         Redis Cache Landing Zone                                |
+--------------------------------------------------------------------------------+
|                                                                                |
|  Application Tier                                                              |
|      |                                                                         |
|      | Redis protocol through approved NSG rules                               |
|      v                                                                         |
|  OCI Cache with Redis Cluster                                                  |
|      |                                                                         |
|      +--> Primary endpoint                                                     |
|      +--> Discovery endpoint                                                   |
|      +--> Node count and memory sizing                                         |
|      +--> Optional shard model                                                 |
|      |                                                                         |
|      v                                                                         |
|  Runtime Consumers                                                             |
|      |                                                                         |
|      +--> Session storage                                                      |
|      +--> Application cache                                                    |
|      +--> Token or feature flag cache                                          |
|      `--> Queue-adjacent transient state                                       |
|                                                                                |
|  Governance Lane                                                               |
|      |                                                                         |
|      +--> Vault secret reference for app auth material                         |
|      +--> Monitoring alarms and notification topics                            |
|      +--> IAM policy statements for cache operators                            |
|      `--> Tags for owner, environment, and cost                                |
+--------------------------------------------------------------------------------+
```

## Terraform Components

| File | Purpose |
| --- | --- |
| `main.tf` | Creates the Redis cluster, optional alarms, and IAM policy shell. |
| `variables.tf` | Defines create/reference inputs, network placement, sizing, alarms, and policy statements. |
| `outputs.tf` | Exposes cluster, endpoint, alarm, secret, and policy values. |
| `terraform.tfvars.example` | Shows safe placeholder inputs for private deployments. |

## Request And Deployment Flow

1. App owner defines the cache role and durability expectations.
2. Network owner supplies subnet and NSG identifiers.
3. Platform owner sets node count, memory, software version, and cluster mode.
4. Security owner confirms Vault and IAM hand-off requirements.
5. Terraform creates the cluster and alarms.
6. App team consumes endpoint and secret references from outputs.

## Traffic And Trust Boundaries

- Redis remains in private subnet placement.
- NSGs should allow only app-tier callers and approved operator paths.
- Cache contents can include sensitive session or token data and must follow
  application security expectations.
- Vault secret references are hand-offs; this blueprint does not store secret values.
- Monitoring alarm destinations should be owned by the app or platform SRE team.

## Detailed Architecture Notes

- `create_cluster` defaults to false so validation and review do not create a cache.
- Existing Redis clusters can be referenced with `redis_cluster_id`.
- `alarms` is a generic map so teams can wire metrics available in their region.
- `oci_cache_config_set_id` supports customer-managed Redis configuration sets.
- `backup_id` supports restore-based deployments without baking restore logic into docs.
- Endpoint outputs are populated only when Terraform creates the cluster.

## Operational Boundaries

- Terraform does not create application keys or rotate auth material.
- Terraform does not migrate cached data between clusters.
- Cache warm-up, TTL strategy, and eviction policy remain application decisions.
- Cross-region cache replication is outside this simple landing-zone pattern.
- Load testing should be completed before production cutover.

## Review Checklist

- Cache purpose and data sensitivity are documented.
- App subnet and NSG access are approved.
- Node count and memory match expected concurrency.
- Vault secret owner is known.
- Alarm queries and destinations are defined for production.
- IAM policy statements are group-scoped.
- Terraform plan shows no unintended public exposure.
