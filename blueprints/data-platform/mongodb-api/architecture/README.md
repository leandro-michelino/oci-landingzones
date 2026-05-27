# Autonomous Database MongoDB API Architecture

This page is the deployment architecture for `blueprints/data-platform/mongodb-api`. It is intentionally Architecture-first so it is easy to review in GitHub, terminals, pull requests, runbooks, and customer notes without a diagramming tool.

## Deployment Purpose

Deploys an OCI-managed MongoDB-compatible document API by creating an Autonomous Database with the MongoDB API database tool enabled. The blueprint is private-first and captures network placement, NSGs, KMS, backup, IAM, and hand-off outputs.

## Architecture At A Glance

| Item | Details |
|---|---|
| Boundary | `blueprints/data-platform/mongodb-api` owns this deployment folder and its Terraform + Ansible runners. |
| Purpose | Managed MongoDB-compatible API endpoint backed by Autonomous Database. |
| Terraform components | `oci_core_vcn.mongodb_api`, `oci_core_subnet.mongodb_api`, `oci_core_network_security_group.mongodb_api`, `oci_database_autonomous_database.this`, `oci_database_autonomous_database_backup.manual`, `oci_identity_policy.access` |
| Primary architecture view | The Architecture diagram below shows OCI control flow, private data path, optional backup, and app hand-off points for this exact deployment. |

## Architecture

```text
+--------------------------------------------------------------------------------------------------------------+
| Autonomous Database MongoDB API                                                                              |
+--------------------------------------------------------------------------------------------------------------+
| Legend: [managed resource]  (supplied/external)  {trust boundary}  -> traffic/control flow                   |
|                                                                                                              |
| [Operator / CI] -> [blueprint-local Ansible runner] -> [Terraform OCI provider]                              |
|         |                    |                         |                                                     |
|         | validates docs      | init/validate/plan      | OCI API calls                                      |
|         v                    v                         v                                                     |
| {Existing tenancy / compartment / VCN boundary}                                                              |
|         |                                                                                                    |
|         | supplied IDs: compartment, optional existing subnet/NSGs, optional KMS key, optional policy scope   |
|         v                                                                                                    |
| [optional private VCN]                                                                                       |
|         |-- private endpoint subnet                                                                              |
|         |-- NSG ingress from approved client CIDRs to MongoDB API port                                           |
|         v                                                                                                    |
| [Autonomous Database]                                                                                        |
|         |-- JSON/document workload setting and compute/storage sizing                                         |
|         |-- db_tools_details: MongoDB API enabled                                                            |
|         |-- private endpoint label, subnet, NSGs, and optional public allow-list                              |
|         |-- optional KMS key, backup retention, manual backup, and tags                                       |
|         |                                                                                                    |
|         +--> [MongoDB API URL output]                                                                        |
|         |          |                                                                                         |
|         |          v                                                                                         |
|         |   (application secret store / deployment pipeline)                                                  |
|         |          |                                                                                         |
|         |          v                                                                                         |
| [private application subnet] -> [ADB private endpoint] -> [MongoDB API] -> [Autonomous Database storage]      |
|                                                                                                              |
| Optional control resources:                                                                                  |
|   [manual backup] -> [Autonomous Database backup service]                                                     |
|   [IAM policy]   -> [groups, dynamic groups, or operators named in policy_statements]                         |
|                                                                                                              |
| Review focus: MongoDB API compatibility, private endpoint routing, DNS, NSGs, password source, backup policy, |
| KMS key, and IAM scope.                                                                                      |
+--------------------------------------------------------------------------------------------------------------+
```

## Terraform Components

| Kind | Name | Source Or Role |
|---|---|---|
| Resource | `oci_database_autonomous_database.this` | Creates the Autonomous Database, private endpoint settings, MongoDB API tool configuration, and database-level controls. |
| Resource | `oci_core_vcn.mongodb_api` | Optional private VCN for complete deploy-and-use private endpoint deployments. |
| Resource | `oci_core_subnet.mongodb_api` | Optional private endpoint subnet. |
| Resource | `oci_core_network_security_group.mongodb_api` | Optional NSG attached to the Autonomous Database private endpoint. |
| Resource | `oci_core_network_security_group_security_rule.mongodb_api_ingress` | Optional NSG ingress rules from approved client CIDRs to the MongoDB API port. |
| Resource | `oci_database_autonomous_database_backup.manual` | Creates an optional initial manual backup when enabled. |
| Resource | `oci_identity_policy.access` | Creates optional IAM policy statements in the tenancy home region. |

## Request And Deployment Flow

- Operator supplies tenancy, region, compartment, subnet, NSG, credential, and optional KMS or IAM values.
- Terraform creates or consumes private network resources, then plans the Autonomous Database with `db_tools_details` configured for the MongoDB API.
- Terraform creates optional backup and IAM resources only when their enable inputs require them.
- Outputs expose the Autonomous Database OCID, state, private endpoint values, MongoDB API URL, service console URL, and optional policy or backup IDs.
- Application owners consume the URL and credentials through an approved deployment or secret hand-off process.

## Traffic And Trust Boundaries

- Control plane traffic is local operator or CI authentication into the OCI provider and the blueprint-local Ansible Terraform runner.
- Data plane traffic should originate from approved private application subnets and reach the Autonomous Database private endpoint through VCN DNS and NSG rules.
- Public access is represented only by `enable_public_access_control` and `whitelisted_ips`; prefer a private endpoint and empty public allow-list for production.
- Trust boundaries are the tenancy, compartment, VCN, private subnet, NSG, private endpoint, and managed Autonomous Database service edge.
- Secrets, OCIDs, endpoint URLs, and customer CIDRs belong in ignored local tfvars or an approved pipeline variable store, not in committed files.

## Detailed Architecture Notes

- This blueprint delivers the OCI-managed MongoDB-compatible API rather than self-managed MongoDB server nodes on Compute or OKE.
- Use `AJD` for the default JSON/document workload unless the DBA team explicitly chooses another supported workload.
- `db_tools_details` enables the MongoDB API and optionally controls the tool compute count and idle timeout.
- `mongodb_api_url` is an operational hand-off output and should be treated like an application endpoint.
- The admin password is a sensitive Terraform input but still needs secure runtime injection because local runtime metadata can contain sensitive values.
- Private endpoint DNS, route reachability, and NSG ingress from app tiers should be verified before handing the URL to developers.
- The optional network path is intentionally small: one VCN, one private subnet, one NSG, and only the MongoDB API port from approved client CIDRs.
- Optional IAM policy statements are intentionally caller-supplied so tenancy group names and delegated administration models remain local decisions.

## Operational Boundaries

- Keep customer-specific OCIDs, CIDRs, endpoint URLs, contacts, and secrets in ignored local tfvars or approved pipeline variables.
- Run plan from this blueprint folder so provider files and local Ansible runners resolve predictably.
- Treat apply and destroy as approval-gated operations; use the guarded Ansible playbooks or a reviewed Terraform workflow.
- Re-check route exposure, IAM scope, compartment boundaries, tags, and output hand-offs whenever inputs change.
- Validate application compatibility with the Oracle Database API for MongoDB before production migration or cutover.
- Keep self-managed MongoDB replica sets, OKE operators, or backup agents out of this blueprint unless the target pattern changes from managed API to self-managed database.

## Review Checklist

- Confirm the diagram matches `main.tf`: optional VCN/subnet/NSG resources, `oci_database_autonomous_database.this`, `oci_database_autonomous_database_backup.manual`, and `oci_identity_policy.access`.
- Confirm the described private endpoint path is the path you want in OCI before apply.
- Confirm the application has been tested against the MongoDB API compatibility surface it needs.
- Confirm admin password handling, KMS key, backup retention, and optional manual backup behavior.
- Confirm public exposure, private endpoint access, DNS behavior, DRG routing, and inspection points are intentional.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.
