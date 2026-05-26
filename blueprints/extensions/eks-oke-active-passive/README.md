# EKS + OKE Active Passive

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this page as the operator guide for `blueprints/extensions/eks-oke-active-passive`.
It tells you what the blueprint builds, which inputs deserve a real review, how
to run Terraform or the local Ansible wrappers, and where to find the detailed
Architecture design.

## At A Glance

| Item | Details |
| --- | --- |
| Folder | `blueprints/extensions/eks-oke-active-passive` |
| Best fit | Active/passive failover EKS + OKE operating model with OCI as primary, partner interconnect, GitOps contract, and DNS failover contract. |
| Terraform shape | `oci_core_vcn.oke`, `oci_core_route_table.oke`, `oci_core_security_list.oke_*`, `oci_core_subnet.oke_*`, `oci_containerengine_cluster.oci_primary`, `oci_containerengine_node_pool.oci_primary`, optional `oci_health_checks_http_monitor.traffic_failover`, optional `oci_dns_steering_policy.traffic_failover`, optional `oci_dns_steering_policy_attachment.traffic_failover`, `terraform_data.interconnect_contract`, `terraform_data.gitops_contract`, `terraform_data.traffic_steering_contract` |
| Inputs to settle first | `compartment_ocid`, `enable_oke_networking`, `oke_vcn_cidr`, `oke_node_subnet_cidrs`, `oke_kubernetes_version`, `fastconnect_virtual_circuit_id`, `direct_connect_connection_id`, `eks_cluster_id`, `app_fqdn`, `oci_primary_endpoint`, `aws_secondary_endpoint`, `enable_oci_traffic_management`, `oci_traffic_management_zone_id` |
| Outputs to hand off | `blueprint_name`, `name_prefix`, `resource_ids`, `primary_cluster`, `secondary_cluster`, `interconnect_contract`, `traffic_steering_contract`, `dns_failover_contract`, `gitops_contract` |
| Local runner | `terraform plan` for quick iteration; `ansible/plan.yml` and guarded `ansible/apply.yml` for the repo-standard flow. |

## Deployment Purpose

Implements an OCI-primary EKS + OKE active/passive Kubernetes pattern that uses
partner Direct Connect + FastConnect interconnect, excludes IPSec backup paths,
publishes GitOps and DNS failover contracts, and can optionally create OCI
Traffic Management failover resources for the application FQDN.

## Kubernetes Version Guidance

Use the latest Kubernetes minor version supported by both OKE and EKS in the
target regions, and keep both clusters on the same minor version for this
blueprint. The examples keep `1.36` / `v1.36.0` as the intended version when it
is supported by the selected cloud regions. In the real E2E test run on May 26,
2026, AWS EKS in `eu-west-1` did not accept `1.36`, so the test used `1.35` on
EKS and `v1.35.2` on OKE.

## When To Use This Deployment

- OCI should remain the primary traffic target for Kubernetes workloads.
- EKS is part of the same workload platform and already exists or is managed by another pipeline.
- Cross-cloud connectivity uses Direct Connect + FastConnect partner interconnect.
- You need explicit DNS failover and GitOps hand-off contracts.

## Practical Use Cases

Use this blueprint when OCI is the main Kubernetes landing zone, AWS remains a
strategic recovery or ecosystem target, and the platform team wants failover to
be boring, visible, and repeatable.

Examples:

- **OCI-primary app with AWS standby:** serve customers from OKE and keep EKS
  ready as the passive target for regional disruption or major maintenance.
- **AWS ecosystem bridge:** keep workloads close to OCI data or network services
  while maintaining a tested EKS path for teams that depend on AWS-native
  integrations.
- **GitOps-driven recovery:** let Argo CD or Flux keep manifests synchronized so
  failover is mostly traffic steering, not a frantic rebuild.
- **Compliance evidence:** produce clear Terraform outputs showing primary and
  secondary clusters, interconnect IDs, DNS failover intent, and the no-IPSec
  backup stance.
- **Operational drill:** run the differentiated hello-world endpoints and record
  OCI-to-AWS and AWS-to-OCI failover times through the delegated Traffic
  Management FQDN.

## What This Deploys

This folder is self-contained at the deployment level: Terraform composes the
OCI resource graph and cross-cloud operating contracts, while the local Ansible
files provide the same plan/apply/destroy rhythm everywhere in the repo.

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Resource | `oci_core_vcn.oke`, `oci_core_route_table.oke`, `oci_core_security_list.oke_*`, `oci_core_subnet.oke_*` | Optional OCI networking stack for deploy-and-use OKE routing and security defaults. |
| Resource | `oci_containerengine_cluster.oci_primary` | Optional OCI primary OKE cluster when `enable_oke_cluster=true`. |
| Resource | `oci_containerengine_node_pool.oci_primary` | Optional OCI primary OKE node pool when `enable_oke_node_pool=true`. |
| Resource | `terraform_data.interconnect_contract` | Interconnect-only contract for FastConnect + Direct Connect and no IPSec backup. |
| Resource | `terraform_data.gitops_contract` | GitOps orchestration metadata for Argo CD or Flux. |
| Resource | `terraform_data.traffic_steering_contract` | Active/passive DNS failover metadata for OCI primary and AWS standby. |
| Optional resource | `oci_health_checks_http_monitor.traffic_failover` | OCI Health Checks monitor for primary and standby endpoints when Traffic Management is enabled. |
| Optional resource | `oci_dns_steering_policy.traffic_failover` | OCI DNS Traffic Management failover policy with OCI as primary and AWS as standby. |
| Optional resource | `oci_dns_steering_policy_attachment.traffic_failover` | Attaches the failover steering policy to the application FQDN in an OCI DNS zone. |

The exact OCI behavior is controlled by `variables.tf` and the values supplied
in your local ignored `terraform.tfvars` file.

## Folder Contract

```text
blueprints/extensions/eks-oke-active-passive/
|-- README.md                  Operator guide for this deployment
|-- architecture/README.md     Detailed Architecture for this deployment
|-- hello-world/index.html     Sample app page for active/passive smoke tests
|-- aws/
|   |-- main.yaml             EKS secondary AWS deployment template
|   |-- parameters.example.json Example AWS deployment parameters
|   `-- README.md              AWS session guide
|-- main.tf                    Terraform modules, resources, and data sources
|-- variables.tf               Input contract
|-- outputs.tf                 Deployment hand-off values
|-- providers.tf               OCI provider configuration
|-- versions.tf                Terraform and provider constraints
|-- terraform.tfvars.example   Example input shape
`-- ansible/
    |-- plan.yml               Local init, validate, and plan
    |-- apply.yml              Guarded init, validate, plan, and apply
    |-- destroy.yml            Guarded destroy
    |-- aws-plan.yml         AWS plan session for EKS secondary
    |-- aws-apply.yml        AWS apply session for EKS secondary
    |-- aws-destroy.yml      AWS destroy session for EKS secondary
    |-- serve-hello-world.yml  Start local hello-world endpoint for demos and checks
    `-- stop-hello-world.yml   Stop local hello-world endpoint
```

## Inputs To Decide

Start with `terraform.tfvars.example`, then create a local ignored
`terraform.tfvars` with real IDs, endpoints, names, and enable flags.

### Base Tenancy And Naming

| Input | What To Decide |
| --- | --- |
| `tenancy_ocid` | OCI tenancy OCID. |
| `current_user_ocid` | OCI user OCID used for local execution or bootstrap. |
| `region` | OCI region name. |
| `home_region` | OCI tenancy home region. OCI Traffic Management steering policies and attachments use this region even when OKE runs in another region. |
| `oci_config_profile` | Optional OCI CLI config profile for local execution. |
| `org` | Short organization prefix used in names. |
| `environment` | Deployment environment name. |
| `region_key` | Short OCI region key used in resource names. |
| `defined_tags` | Defined tags applied to resources. |
| `freeform_tags` | Freeform tags applied to resources. |

### Deployment-Specific Decisions

| Input | What To Decide |
| --- | --- |
| `compartment_ocid` | Compartment OCID where OKE resources are created. Defaults to tenancy_ocid for validation-only tests. |
| `enable_oke_networking` | When true, creates VCN, route table, security lists, and required OKE subnets. |
| `oke_vcn_cidr` | CIDR for OCI VCN created in deploy-and-use mode. |
| `oke_endpoint_subnet_cidr` | CIDR for OKE API endpoint subnet. |
| `oke_node_subnet_cidrs` | CIDR list for OKE worker node subnets. |
| `oke_service_lb_subnet_cidr` | CIDR for OKE load balancer subnet. |
| `oke_api_allowed_cidr` | Allowed source CIDR to reach the OKE API endpoint. |
| `oke_node_ssh_allowed_cidr` | Optional SSH source CIDR for worker node access. |
| `oke_service_lb_allowed_cidr` | Optional public CIDR allowed to reach OKE service load balancers on HTTP and HTTPS. Defaults to `0.0.0.0/0` for quick smoke tests; narrow it for production. |
| `interconnect_mode` | Must remain `direct-connect-fastconnect-partner` for this pattern. |
| `fastconnect_virtual_circuit_id` | OCI FastConnect virtual circuit OCID for the partner interconnect. |
| `direct_connect_connection_id` | AWS Direct Connect connection ID paired to FastConnect through partner exchange. |
| `enable_ipsec_backup` | Must remain `false` in this blueprint variant. |
| `oci_is_primary` | Must remain `true` in this blueprint variant. |
| `enable_oke_cluster` | Create the OCI primary OKE cluster. Disabled by default to avoid cost in smoke tests. |
| `enable_oke_node_pool` | Create the OCI primary OKE node pool. Disabled by default to avoid compute cost. |
| `oke_cluster_id` | Existing OKE cluster OCID used when only creating node pools. |
| `oke_kubernetes_version` | Kubernetes version for OKE resources. Use the latest common minor version supported by both OKE and EKS; override to `v1.35.2` when EKS region support requires `1.35`. |
| `oke_vcn_id` | VCN OCID for OKE cluster networking. |
| `oke_endpoint_subnet_id` | Optional endpoint subnet OCID for OKE API server. |
| `oke_node_subnet_ids` | Node subnet OCIDs for OKE worker nodes. |
| `eks_cluster_id` | Existing EKS cluster resource ID used as secondary target. |
| `eks_cluster_name` | Existing EKS cluster name for hand-off outputs. |
| `eks_stack_name` | Existing EKS stack for hand-off outputs. |
| `gitops_tool` | GitOps controller choice: `argocd` or `flux`. |
| `gitops_repo_url` | GitOps repository URL for multi-cluster rollout. |
| `app_fqdn` | Application FQDN used for DNS failover decisions. |
| `oci_primary_endpoint` | OCI primary ingress endpoint. |
| `aws_secondary_endpoint` | AWS secondary ingress endpoint. |
| `oci_primary_traffic_percent` | Keep `100` for active/passive. Use a lower value only when intentionally moving this blueprint to active/active with weighted DNS/GSLB. |
| `enable_oci_traffic_management` | Create OCI Traffic Management failover resources for the application FQDN. Disabled by default because it requires a real OCI DNS zone and endpoint answers. |
| `oci_traffic_management_zone_id` | OCI DNS zone OCID used for the failover steering policy attachment. |
| `oci_traffic_management_domain_name` | DNS name attached to the steering policy. Defaults to `app_fqdn`. |
| `oci_traffic_management_record_type` | DNS answer type for Traffic Management, usually `CNAME` for Kubernetes load balancer hostnames or `A` for IP endpoints. |
| `oci_traffic_management_ttl` | TTL for failover answers. |
| `enable_oci_traffic_management_health_check` | Create an OCI Health Checks HTTP monitor when Traffic Management is enabled. |
| `oci_traffic_management_health_check_monitor_id` | Existing OCI Health Checks monitor OCID to reuse instead of creating a monitor. |

## Outputs And Hand-Off

These outputs are the deployment contract for downstream blueprints, runbooks,
customer notes, or manual hand-off. If an output name changes, update
dependent docs and consumers in the same change.

| Output | Hand-Off Meaning |
| --- | --- |
| `blueprint_name` | Blueprint identifier. |
| `name_prefix` | Standard OCI naming prefix for resources created by this blueprint. |
| `resource_ids` | Map of resource identifiers created by this blueprint. |
| `primary_cluster` | OCI primary cluster IDs and cloud role metadata. |
| `secondary_cluster` | EKS standby cluster IDs and cloud role metadata. |
| `interconnect_contract` | Interconnect path contract: Direct Connect + FastConnect and no IPSec backup. |
| `traffic_steering_contract` | Backward-compatible output containing the active/passive DNS failover contract. |
| `dns_failover_contract` | DNS failover contract for OCI primary to AWS standby cutover, including OCI Traffic Management resource IDs when enabled. |
| `gitops_contract` | GitOps metadata contract for rollout tooling and repository wiring. |
| `operator_summary` | Friendly output for humans: key resource names, IDs, Kubernetes guidance, application endpoints, Traffic Management status, and kubeconfig commands. |

## Active/Active Option

This blueprint defaults to active/passive because OCI Traffic Management
failover is the most explicit fit for an OCI-primary Kubernetes operating
model. Active/active is still possible when the application is designed for
dual serving, session handling, data consistency, and health-aware global
routing. In that case, use a weighted OCI Traffic Management policy or another
GSLB layer with non-zero traffic to both clusters, and keep the active/active
decision visible in the runbook.

## E2E Smoke Test Notes

For an internet-reachable smoke test, deploy the same hello-world workload to
both Kubernetes clusters with a `LoadBalancer` service in each cloud. OCI
Traffic Management is the global failover layer: it checks the primary OCI
endpoint and serves the AWS standby answer only when the failover policy marks
the primary unhealthy. Kubernetes service load balancers do not balance traffic
between clouds by themselves.

Direct IPs and provider load balancer hostnames are useful for app smoke tests,
but they bypass OCI Traffic Management. To test failover through the Traffic
Management URL in a browser, delegate a real public domain or subdomain to the
OCI DNS zone nameservers and attach the steering policy to that delegated FQDN.
Temporary non-delegated zones can validate policy creation and authoritative
DNS behavior, but they will not resolve through normal public recursive DNS.

For differentiated E2E testing, publish a page that returns `Hello World OCI`
on the OKE primary endpoint and `Hello World AWS` on the EKS standby endpoint.
That makes it obvious which side the DNS policy is currently serving.

## Failover Metrics

With the default Traffic Management settings in this blueprint, use a practical
target of 60 to 120 seconds for OCI-to-AWS failover and AWS-to-OCI failback
after the endpoint health state changes. The default steering policy TTL is
30 seconds, the default health check interval is 30 seconds, and the default
health check timeout is 10 seconds. Real browser timing also depends on public
DNS delegation, recursive resolver caching, client DNS cache, and how quickly
the Kubernetes `LoadBalancer` endpoint starts or stops returning healthy
responses.

Measure the metric from the client side by polling the delegated Traffic
Management FQDN and recording the first response body change from
`Hello World OCI` to `Hello World AWS` during failover, then from
`Hello World AWS` back to `Hello World OCI` during failback. Direct IP tests
prove the individual cloud endpoint health, but they bypass Traffic Management
and should not be used as the failover timing measurement.

Set `home_region` to the tenancy home region before enabling OCI Traffic
Management. The health monitor can run in the workload region, but the global
DNS steering policy and attachment are created through the home-region provider
alias. For temporary, non-delegated test zones, validate DNS against the OCI
authoritative nameservers returned by the zone instead of public recursive DNS.

The managed OKE network includes DNS labels, Internet Gateway routing for
short-lived public-node smoke tests, endpoint ingress from worker CIDRs on
`6443` and `12250`, ICMP path discovery from worker CIDRs, and HTTP/HTTPS
ingress for public service load balancers. Keep these rules explicit because
missing worker registration paths can leave nodes in `UnknownNodeError` /
registration timeout. For private production nodes, use separate route tables
with NAT and Service Gateway patterns instead of the public smoke-test route.

The Terraform and Ansible runners print a friendly operator summary after plan
or apply. Use `terraform output operator_summary` when you want the same
resource names, URLs, Traffic Management status, and kubeconfig commands
outside Ansible.

## Terraform And Ansible Workflow

Use direct Terraform when you are iterating locally:

```bash
cd blueprints/extensions/eks-oke-active-passive
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform validate
terraform plan
```

Use the local Ansible wrapper when you want the same runner shape used across
the repo:

```bash
cd blueprints/extensions/eks-oke-active-passive
ansible-playbook -i localhost, ansible/plan.yml
CONFIRM_APPLY=true ansible-playbook -i localhost, ansible/apply.yml
CONFIRM_DESTROY=true ansible-playbook -i localhost, ansible/destroy.yml
```

`apply.yml` and `destroy.yml` are intentionally guarded. Keep that behavior for
customer-facing or shared environments.

AWS full deployment session (EKS secondary):

```bash
cd blueprints/extensions/eks-oke-active-passive
ansible-playbook -i localhost, ansible/aws-plan.yml
CONFIRM_AWS_APPLY=true ansible-playbook -i localhost, ansible/aws-apply.yml
CONFIRM_AWS_DESTROY=true ansible-playbook -i localhost, ansible/aws-destroy.yml
```

For required AWS variables and parameters, review `aws/README.md`.
AWS session playbooks use the shared role
`ansible/roles/aws_deployment_runner` for consistent behavior.

To run the real hello-world endpoint for this blueprint:

```bash
cd blueprints/extensions/eks-oke-active-passive
ansible-playbook -i localhost, ansible/serve-hello-world.yml
# open http://127.0.0.1:18080
ansible-playbook -i localhost, ansible/stop-hello-world.yml
```

## Deployment Order

This extension supports extension-only and base-plus-extension customer paths.
For extension-only use, supply existing compartment, OKE, interconnect, EKS,
and endpoint values in local tfvars and run this folder directly. For
base-plus-extension use, deploy core and networking first, then pass outputs
here.

1. Confirm compartment scope, OKE ownership, and EKS ownership boundaries.
2. Confirm interconnect ownership and partner circuit lifecycle.
3. Populate `terraform.tfvars` with cluster IDs, interconnect IDs, and endpoint values.
4. Run plan and review OCI-primary failover and contract outputs.
5. Apply only after platform, network, and operations owners approve the hand-off contract.

## Architecture

The full detailed Architecture is local to this deployment:

```text
architecture/README.md
```

That file documents the ownership boundary, Terraform components, request flow,
state and output contract, operational boundaries, review checklist, and the
expected Terraform + Ansible output at the end of the deployment.

## Review Before Apply

- Confirm OCI remains primary (`oci_is_primary=true`) and IPSec backup is disabled.
- Confirm interconnect IDs map to the intended Direct Connect + FastConnect pair.
- Review OKE endpoint exposure and node subnet reachability.
- Confirm GitOps repository ownership and branch promotion workflow.
- Confirm DNS failover endpoint names, health checks, and policy attachment are intentional.
- Confirm the local `architecture/README.md` still matches `main.tf`, `variables.tf`, and `outputs.tf`.
- Confirm no generated Terraform files, state files, plans, or local tfvars are committed.

## Validation

From the repository root:

```bash
./scripts/validate-all.sh
```

The validator checks Terraform formatting, required deployment README files,
required architecture README sections, `terraform init -backend=false`,
`terraform validate`, root Ansible syntax, blueprint-local Ansible syntax,
optional scanners when installed, and cleanup of generated Terraform artifacts.
