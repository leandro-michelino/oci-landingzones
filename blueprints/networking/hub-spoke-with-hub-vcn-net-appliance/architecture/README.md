# Hub-Spoke With Network Appliance Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This architecture page documents the `blueprints/networking/hub-spoke-with-hub-vcn-net-appliance` deployment. It is intentionally text-first and ASCII-only so it can be reviewed in terminals, pull requests, and customer notes without a diagramming tool.

## Deployment Purpose

This blueprint provides networking landing-zone pattern for the hub-spoke with network
appliance.

## Files In This Deployment

```text
blueprints/networking/hub-spoke-with-hub-vcn-net-appliance/
|-- README.md                         Human-friendly deployment notes
|-- architecture/README.md            This detailed ASCII architecture
|-- main.tf                           Terraform resource and module wiring
|-- variables.tf                      Input contract and defaults
|-- outputs.tf                        Hand-off values for dependent blueprints
|-- providers.tf                      OCI provider configuration
|-- versions.tf                       Terraform and provider constraints
|-- terraform.tfvars.example          Example local variable shape
`-- ansible/
    |-- plan.yml                      Local guarded plan runner
    |-- apply.yml                     Local guarded apply runner
    `-- destroy.yml                   Local guarded destroy runner
```

## ASCII Architecture

```text
+-------------------------------------------------------------------------------------------+
| Hub-Spoke With Network Appliance                                                          |
| blueprints/networking/hub-spoke-with-hub-vcn-net-appliance                                |
+-------------------------------------------------------------------------------------------+
| Operator / CI / local shell                                                               |
|   |                                                                                       |
|   v                                                                                       |
+-------------------------------------------------------------------------------------------+
| Blueprint folder contract                                                                 |
|   README.md                                                                               |
|   architecture/README.md                                                                  |
|   main.tf + variables.tf + outputs.tf + providers.tf + versions.tf                        |
|   ansible/plan.yml + apply.yml + destroy.yml                                              |
+-------------------------------------------------------------------------------------------+
|   |                                                                                       |
|   v                                                                                       |
+-------------------------------------------------------------------------------------------+
| Terraform composition and OCI resources                                                   |
|  01. module   network                                          (main.tf)                  |
|  02. module   net_appliance                                    (main.tf)                  |
+-------------------------------------------------------------------------------------------+
|   |                                                                                       |
|   v                                                                                       |
+-------------------------------------------------------------------------------------------+
| Architecture layers                                                                       |
|   - Control plane: Terraform provider and blueprint variables                             |
|   - Network plane: VCNs, DRG, gateways, route tables, subnets, and optional inspection    |
|   - Security plane: security lists, NSGs where used, private DNS, ZPR, or appliance contro|
|   - Operations plane: outputs consumed by service extensions, monitoring, and runbooks    |
+-------------------------------------------------------------------------------------------+
|   |                                                                                       |
|   v                                                                                       |
+-------------------------------------------------------------------------------------------+
| Outputs and hand-off                                                                      |
|   resource_ids plus blueprint-specific IDs                                                |
|   tfvars reviewed before apply                                                            |
|   generated Terraform artifacts cleaned after validation                                  |
+-------------------------------------------------------------------------------------------+
```

## Terraform Components

- `module network` in `main.tf`: composes the reusable network module or child blueprint.
- `module net_appliance` in `main.tf`: composes the reusable net appliance module or child blueprint.

## Request And Deployment Flow

- Operator reviews CIDR, subnet, DNS, inspection, and connectivity inputs.
- Terraform creates or references the VCN foundation.
- Gateways, route tables, DRG attachments, DNS, inspection, or private access resources are composed.
- Outputs expose VCN, subnet, gateway, attachment, and policy IDs for workload and extension blueprints.

## State, Inputs, And Outputs

```text
Input sources
|-- terraform.tfvars.example documents expected values
|-- local *.tfvars files provide tenancy, compartment, CIDR, endpoint, and OCID values
|-- environment variables may provide OCI authentication and guarded Ansible confirms
|
Terraform state
|-- backend is disabled for local validation and plan runners by default
|-- production backends should be configured outside this reusable blueprint folder
|-- generated .terraform directories, lock files, plans, and state files are cleaned by validation
|
Output contract
|-- blueprint_name and name_prefix identify the deployment
|-- resource_ids summarizes primary resources in a machine-friendly map
`-- blueprint-specific outputs expose compartment, VCN, subnet, key, policy, service, or DR IDs
```

## Operational Boundaries

- Keep apply/destroy behind the guarded Ansible runners or equivalent review gates.
- Use local ignored tfvars for OCIDs, notification endpoints, customer CIDRs, and secrets.
- Run ./scripts/validate-all.sh before commits or hand-off.
- Confirm route tables, inspection hops, and public/private subnet flags before apply.
- Confirm DNS behavior and service-gateway routes for private OCI access.

## Review Checklist

- Confirm the `README.md` story matches this ASCII architecture.
- Confirm every module/resource listed above is intentional for this deployment.
- Confirm required external IDs are documented before `terraform plan`.
- Confirm enable flags are set deliberately, especially for tenancy-wide, paid, or destructive resources.
- Confirm logging, IAM, security, networking, and operational hand-offs are visible in the diagram.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.

## Validation

```bash
./scripts/validate-all.sh
```

The repository validator checks Terraform formatting, initializes and validates every blueprint without a backend, syntax-checks the root Ansible playbooks, syntax-checks every blueprint-local Ansible runner, and removes generated Terraform artifacts afterward.

## When To Update This Architecture

- Terraform modules, resources, data sources, or provider aliases change.
- A subnet, route, trust boundary, region, compartment, or access path changes.
- A new enable flag changes what the deployment can create.
- README usage notes describe behavior that is not represented here.
- A customer review turns an assumption into a reusable pattern.
