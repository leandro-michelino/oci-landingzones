# Standalone Three-Tier Default VCN Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This standalone pattern deploys a default three-tier VCN with public web, private application, private database, internet gateway, NAT gateway, service gateway, routes, and security boundaries.

Keep architecture notes in this folder. Add rendered artifacts only when a review package needs them.

## ASCII Architecture

```text
Internet Users
      |
      v
+----------------------+
| Internet Gateway     |
+----------------------+
      |
      v
+---------+      +---------+      +---------+
| Web     | ---> | App     | ---> | DB      |
| public  |      | private |      | private |
+---------+      +---------+      +---------+
      |                |                |
      v                v                v
NAT Gateway      Service Gateway   Security boundaries
Outbound updates OCI private APIs   No public ingress
```

## Why This Diagram Matters

The diagram is the quick sanity check before anyone opens Terraform. It should make
traffic paths, ownership boundaries, dependencies, and operational hand-offs obvious
enough that a customer, network engineer, security reviewer, and platform engineer can
point at the same picture and agree on what is being built.

## Review Checklist

- Confirm the compartment, region, and ownership boundary shown here matches the tfvars.
- Confirm all external dependencies are named before `terraform plan`.
- Confirm ingress, egress, inspection, DNS, and private service paths are intentional.
- Confirm logging, monitoring, IAM, and break-glass responsibilities are represented.
- Keep rendered diagrams outside the blueprint unless they become the approved artifact.

## When To Update It

- The blueprint adds or removes a major resource type.
- A route, trust boundary, region, compartment, or access path changes.
- A customer-specific assumption becomes part of the reusable pattern.
- The README explains a behavior that is not visible in the diagram yet.
