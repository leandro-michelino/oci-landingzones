# OCI Container Instances Architecture

This is the deployment architecture for `blueprints/extensions/container-instances`. It keeps the design reviewable in GitHub, terminals, pull requests, runbooks, and customer-safe notes without a diagramming tool.

## Deployment Purpose

Defines an optional OCI Container Instance runtime with VNIC, container definitions, optional pull secrets, optional volumes, and optional scoped IAM policy.

## Architecture At A Glance

| Item | Details |
|---|---|
| Boundary | `blueprints/extensions/container-instances` owns this deployment folder and its Terraform + Ansible runners. |
| Purpose | Runs one or more approved container images without an OKE cluster. |
| Terraform components | `oci_container_instances_container_instance.this`, `oci_identity_policy.access` |
| Primary architecture view | The diagram shows source-defined components and configuration associations; it is not runtime evidence. |

## Architecture

![Source-bounded container-instances architecture](architecture.png)

[Editable overview and native detail pages](architecture.drawio) · [Source resource inventory](resource-inventory.json)

Native pages enumerate every conditional declaration and existing identifier input.
They describe declaration coverage, not expanded deployed resource counts.

## Terraform Components

| Kind | Name | Source Or Role |
|---|---|---|
| Resource | `oci_container_instances_container_instance.this` | Declared directly in `main.tf` |
| Resource | `oci_identity_policy.access` | Optional scoped IAM policy declared directly in `main.tf` |

## Request And Deployment Flow

1. Supply the required compartment, service/network identifiers and per-resource configuration.
2. Review each conditional resource and the disabled default result before enabling creation.
3. Review source-defined ID bindings and optional action/target selections against existing dependencies.
4. Implement external image, application, producer/consumer and permissions work where applicable.
5. Test actual service access, data handling and runtime behavior separately from this diagram review.

## Traffic And Trust Boundaries

- Plain lines represent declared IDs or nested configuration. Solid arrows represent configured invocation/delivery intent only.
- Dashed lines identify external work or conditional event-source matching. No connector proves a successful request or working network path.
- Existing network and service identifiers do not imply ownership adoption, permission grants, private DNS, Internet egress or end-to-end connectivity.
- IAM policies use supplied statements; their provider and compartment/tenancy scope require separate review where present.
- Keep credentials, secrets, OCIDs and customer-specific configurations in ignored local inputs or approved secure pipeline stores.

## Detailed Architecture Notes

- No cloud resources by default: `enable_container_instance=false` and `policy_statements=[]`. Two resource declarations cover the instance and an independent optional IAM policy.
- Default instance settings are `CI.Standard.E4.Flex`, one OCPU, 2 GB memory, ALWAYS restart and a 30-second graceful shutdown timeout. Availability domain is supplied explicitly; defaults are not regional availability or capacity evidence.
- The instance has a nested VNIC in a supplied existing subnet with `is_public_ip_assigned=false`, `nsg_ids=[]`, optional private IP and source/destination checks enabled by default. No subnet, NSG, route or gateway is created.
- `containers[]` must be nonempty when enabling the instance. Image URLs, commands, arguments, environment/configuration, limits, mounts and optional health checks are nested creation-time settings.
- Image-pull secrets, custom DNS and volumes are nested instance blocks. Existing registry/Vault references do not create a registry, secret, DNS server or independent durable-storage resource.
- The IAM policy uses the regional provider and an explicit policy compartment or tenancy fallback. Arbitrary policy statements do not establish working access to images, secrets or application resources.

Diagram/source review: 2026-10-28. Historical infrastructure/provider validation metadata is unchanged. No provisioning or runtime test was run for this conversion.

## Operational Boundaries

- This extension can run extension-only with supplied brownfield OCI IDs, or as
  base-plus-extension using outputs from core, networking, ownership, or
  operations blueprints.
- Keep customer-specific OCIDs, CIDRs, DNS names, endpoints, contacts, and secrets in ignored local tfvars or approved pipeline variables.
- Run plan from this blueprint folder so relative module paths, provider files, and local Ansible runners resolve predictably.
- Treat apply and destroy as approval-gated operations; use the guarded Ansible playbooks or a reviewed Terraform workflow.
- Re-check route exposure, IAM scope, compartment boundaries, tags, and output hand-offs whenever inputs change.

## Review Checklist

- Confirm the diagram matches `main.tf`: `oci_container_instances_container_instance.this`, `oci_identity_policy.access`.
- Confirm the described traffic or control path is the path you want in OCI before apply.
- Confirm public exposure, private endpoint access, DNS behavior, DRG routing, and inspection points are intentional where present.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.
