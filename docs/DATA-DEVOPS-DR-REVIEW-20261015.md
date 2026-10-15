# Data Platform, DevOps, and DR Review, October 15, 2026

This review covers catalog items 21-30. The live fixtures used OCI profile
`DEFAULT`, region `sa-saopaulo-1`, and the operator-selected
`Leandro.Michelino` compartment (OCID ending `zt36vorq`). They created only
disposable OCI network resources. Database systems, tables, search clusters,
Vault, Object Storage, Streaming, DevOps services, FSDR protection groups,
AWS/Azure resources, and a second OCI region were outside the live scope.

For each of the eight live fixtures, the saved plan was checked for resource
type, compartment, and region before apply. OCI GET confirmed the created
resources. A subsequent Terraform plan reported no changes; destroy then
left zero managed resources. Per-resource deletion checks and scoped OCI API
inventory were completed before moving to the next blueprint.

| # | Blueprint | Passing Live Run | Review Result and Limit |
| --- | --- | ---: | --- |
| 21 | `data-platform/mysql-heatwave` | 5 network resources | Attached an explicit ingress-empty security list to the private subnet; added DB and HeatWave input guards. No MySQL or HeatWave service was created. |
| 22 | `data-platform/nosql` | 5 network resources | Made table creation optional for the network test, preserved the table state address with a `moved` block, and guarded index/replica inputs. No table or replica was created. |
| 23 | `data-platform/oci-aws-mysql-heatwave-dr` | 4 network resources | Removed an ineffective internet route from the private DB subnet, corrected optional IPSec fields, and limited AWS replication ingress to IPSec-enabled plans. No VPN, database, replication, or failover was tested. |
| 24 | `data-platform/opensearch` | 4 network resources | Attached an explicit ingress-empty security list; made NSG client ingress opt-in. No OpenSearch cluster or endpoint traffic was tested. |
| 25 | `data-platform/postgresql` | 5 network resources | Attached an explicit ingress-empty security list and added guarded DB inputs. No PostgreSQL system or client connection was tested. |
| 26 | `data-platform/private-data-platform` | 7 network resources | Corrected conditional dependencies and endpoint NSG wiring; pinned the network source to the published `c07231c91d146265a46836757f3c399861a59fff` revision. Vault and Streaming remain pinned to `v0.2.0`; no data service or endpoint traffic was tested. |
| 27 | `devops/oci-devops-pipeline` | None | Local validation and mocked plans exercised topic/project dependencies and disabled/opted-in configurations. No live DevOps project or pipeline was created or executed. |
| 28 | `disaster-recovery/aws-oci-cross-cloud-dr` | 5 network resources | Guarded optional bucket lookup and DNS inputs; the fixture tested only the OCI primary network. No AWS standby, interconnect, data replication, DNS cutover, or failover was tested. |
| 29 | `disaster-recovery/azure-oci-cross-cloud-dr` | 5 network resources | Applied the same OCI network and contract corrections. No Azure standby, interconnect, data replication, DNS cutover, or failover was tested. |
| 30 | `disaster-recovery/fsdr` | None | Local validation and mocked plans checked standby association and standby-region plan placement. No second-region resources, DR protection groups, plan execution, or failover were tested. |

The passing live runs created **40 OCI network resources** in total. Every one
was destroyed and verified absent. The final API audit recorded zero active
VCNs, DRGs, subnets, route tables, security lists, internet gateways, NAT
gateways, service gateways, NSGs, DHCP options, and network load balancers in
the selected compartment; it found no test leftovers. This is a scoped
resource inventory, not an account-wide billing or cost verification.

## Failed Attempts and Recheck

The first item 26 live run created seven network resources, then exposed
Terraform drift that would remove OCI-managed `Oracle-Tags.CreatedBy` and
`Oracle-Tags.CreatedOn`. Those seven resources were destroyed; managed state,
per-ID deletion, and scoped inventory all confirmed cleanup. The network
dependency was updated from `v0.2.0` to the already-published immutable
revision above, which preserves those provenance tags. A fresh isolated run
created seven resources, returned a no-change plan, and passed the same
cleanup checks. Thus the passing runs account for 40 creations; the separate
drifted attempt accounts for seven additional creations, also removed.

An earlier apply-style mocked test for item 26 unexpectedly traversed a
nested module's real provider and attempted a VCN create with a placeholder
compartment OCID. OCI returned `404 NotAuthorizedOrNotFound`; the attempt
produced no resource ID or managed state, and a subsequent API audit found
no VCN in the authorized compartment. The test was changed to plan-only and
its four cases passed. Apply-style mocks must not be treated as isolation
proof when a nested module may retain its real provider.

## Validation and Deployment Boundaries

Terraform initialization/validation and blueprint-specific regression cases
passed with OCI provider 9.9.0 for these ten entry points: **58 cases across
ten suites** (5, 5, 6, 4, 5, 4, 7, 8, 8, and 6 in catalog order). The test
files are under each blueprint's `tests/` directory. The full repository
check also completed: 80/80 blueprint schema validations with OCI provider
9.10.0, 277 Ansible syntax checks, TFLint, Trivy, 281 passing Checkov checks
with zero failures and 13 skips, cloud-deployment simulations, and all
pre-commit hooks. The Functions blueprint, outside this ten-item round,
reported a provider deprecation warning for its `image` field; its schema
still validated. Full-check logs are in ignored
`.leo-local/full-validation-20261015/validate-all-retry.log`. Mocked plans
and schema checks prove only the asserted configuration paths. The live
results prove reduced OCI network provisioning and cleanup, not full workload
or DR operation.

Existing deployments need an explicit plan review before adopting these
changes. In particular, the NoSQL table address now uses `moved` state
migration, the private-data network dependency changes immutable revision,
and the optional FSDR plan now targets the associated standby group and
standby region. The FSDR plan address and placement change is not a tested
in-place live migration. Existing optional service defaults were preserved
where possible; a no-change plan for these isolated fixtures does not establish
no-change behavior for existing deployments.

The ignored local evidence directory is
`.leo-local/data-devops-dr-20261015/`. It contains the saved plans, live
GET/drift/destroy logs, per-ID deletion checks, `results.json`, the first
item 26 attempt in `results-before-26-provider-fix.json`, and
`final-api-audit.json`. It is excluded from Git because it may contain
tenant-specific OCIDs and operator metadata. No paid workload or external
cloud test was authorized in this round; actual charges were not checked.
