# Networking and Governance Review: Catalog Items 71-80

Reviewed on 2026-10-23 with OCI Terraform provider 9.10.0. All ten blueprints passed `terraform validate`. Read-only plans for items 71-76 used only profile `DEFAULT`, region `sa-saopaulo-1`, and compartment `ocid1.compartment.oc1..aaaaaaaakezfqoalteuhlhopq7qymraumvajkfgspityukkf7kymzt36vorq`. All known planned `compartment_id` values matched that compartment. No apply or new OCI resource creation occurred.

| # | Blueprint | Finding and validation boundary |
| --- | --- | --- |
| 71 | `networking/network-load-balancer` | Default plan made no changes because NLB creation is opt-in and no subnet or backends were supplied. The earlier lifecycle tested a private NLB with an empty backend set and listener, not backend traffic. |
| 72 | `networking/regional-prod-nonprod-hubs` | Plan proposed 40 network resources, including two NAT gateways across separate production and nonproduction foundations. No traffic-isolation test. |
| 73 | `networking/standalone-private-endpoint-only` | Plan proposed seven network resources, without NAT or internet gateway. No private endpoint workload test. |
| 74 | `networking/standalone-three-tier-vcn-custom` | Plan proposed 11 network resources, including NAT and internet gateway. No workload packet-flow test. |
| 75 | `networking/standalone-three-tier-vcn-defaults` | Plan proposed 11 network resources, including NAT and internet gateway. No workload packet-flow test. |
| 76 | `networking/standalone-three-tier-vcn-zpr` | Plan proposed 11 network resources, including NAT; tenancy-root ZPR configuration and policies stayed disabled. No policy-enforcement test. |
| 77 | `operating-entity` | Schema only. The blueprint creates tenancy-root IAM groups and a compartment tree, requiring home-region and tenancy-level scope. No live plan or apply. |
| 78 | `operating-entity/multi-operating-entities` | Schema only. Per-entity tenancy-root IAM groups require home-region and tenancy-level scope. No live plan or apply. |
| 79 | `operating-entity/workload-vending` | Schema only. Workload IAM groups require home-region and tenancy-level scope. No live plan or apply. |
| 80 | `operations/cost-optimization` | Schema and one mocked provider test passed. Tagging is enabled by default and uses the home-region provider. Budgets, notifications, alarms, and Optimizer resources were not deployed. No live plan, price estimate, or cost-behavior test. |

The `DEFAULT` tenancy's home region was confirmed by the OCI region-subscription API as `me-abudhabi-1`, outside the selected Sao Paulo-only test region. Running items 77-79 as a real lifecycle test would also create tenancy-root IAM groups, beyond the selected compartment-only scope. Item 80's tagging and IAM operations use the home-region provider. These four items remain pending a separate scope decision; schema and the item 80 mock test are not evidence of provisioning or runtime behavior.

No functional Terraform correction was needed. The diagrams for items 77-79 incorrectly listed groups that the code does not create; they now match the implemented administrator, operator, and auditor roles. Module and architecture comments now record the latest validation scope. Earlier 2026-10-14 lifecycle dates for items 71-76 remain historical, with apply, drift, destroy, and OCI API cleanup recorded in [ephemeral deployment evidence](EPHEMERAL-DEPLOYMENT-EVIDENCE.md). This round did not repeat those applies or cleanup checks.

The plans were inspected before any apply. The user previously authorized ephemeral NAT tests, but no resource was created in this round, so there was no new deployment to destroy or inventory-check. No current price estimate was verified. Plan files and logs are stored only under ignored `.leo-local/networking-governance-review-20261023/`.

Repository-wide `./scripts/validate-all.sh` passed after these documentation changes: Terraform validation, TFLint, Checkov (274 passed, 0 failed, 13 skipped), Ansible checks, cloud deployment simulations, and pre-commit. Trivy was unavailable and was skipped by the script. These static checks do not extend the live-test scope above.
