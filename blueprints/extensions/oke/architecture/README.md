# OKE Extension Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This page is the deployment architecture for `blueprints/extensions/oke`. It is intentionally ASCII-first so it
is easy to review in GitHub, terminals, pull requests, runbooks, and customer notes without a
diagramming tool.

## Deployment Purpose

Creates an OCI Container Engine for Kubernetes cluster and optional node pool attached to supplied VCN and subnet IDs.

## Architecture At A Glance

| Item | Details |
| --- | --- |
| Boundary | `blueprints/extensions/oke` owns this deployment folder and its Terraform + Ansible runners. |
| Purpose | Creates an OCI Container Engine for Kubernetes cluster and optional node pool attached to supplied VCN and subnet IDs. |
| Terraform components | `oci_containerengine_cluster.this`, `oci_containerengine_node_pool.this` |
| Primary architecture view | The ASCII diagram below shows the OCI components, dependency order, and traffic flow for this exact deployment. |
| Output contract | `blueprint_name`, `name_prefix`, `resource_ids`, `cluster_id`, `node_pool_id` |


## ASCII Architecture

```text
+--------------------------------------------------------------------------------------------------+
| OKE Extension                                                                                     |
|                                                                                                  |
|  kubectl / CI / platform operators                                                                |
|        |                                                                                         |
|        v                                                                                         |
|  +----------------------------- Existing VCN ----------------------------+                       |
|  | VCN ID is supplied by var.vcn_id                                     |                       |
|  |                                                                      |                       |
|  |  endpoint subnet + endpoint NSGs                                      |                       |
|  |       ^                                                              |                       |
|  |       | Kubernetes API endpoint, public or private per variable        |                       |
|  |       v                                                              |                       |
|  |  +----------------------- OKE Cluster -----------------------+        |                       |
|  |  | Kubernetes version, CNI option, cluster endpoint config    |        |                       |
|  |  +-------------------+-------------------+------------------+        |                       |
|  |                      |                   |                           |                       |
|  |                      v                   v                           |                       |
|  |          service LB subnets             node pool subnets             |                       |
|  |          LoadBalancers for Services     worker nodes per subnet       |                       |
|  +----------------------+-------------------+---------------------------+                       |
|                         | workload pod traffic and service traffic                               |
|                         v                                                                       |
|                 Applications running on worker nodes                                              |
|                                                                                                  |
|  Traffic: operators -> API endpoint; clients -> service load balancers; pods -> VCN routes.       |
|  Control: Terraform creates the cluster first, then node pools against the cluster ID.             |
+--------------------------------------------------------------------------------------------------+
```

## Terraform Components

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Resource | `oci_containerengine_cluster.this` | `Declared directly in main.tf` |
| Resource | `oci_containerengine_node_pool.this` | `Declared directly in main.tf` |

## Request And Deployment Flow

- Operator supplies the existing network, compartment, service, or backend IDs required by the extension.
- Terraform creates the optional service resource graph declared in main.tf.
- Outputs expose service IDs, endpoint names, or attachment IDs for applications and runbooks.

## Traffic And Trust Boundaries

- Control plane traffic is local operator or CI authentication into the OCI provider and the Ansible Terraform runner.
- Data plane traffic is the packet or service path shown in the ASCII diagram; if this deployment only creates identity or governance resources, the data plane is intentionally permission and signal flow instead of network packets.
- Trust boundaries are the tenancy, compartment, VCN, subnet, DRG, private endpoint, identity domain, or managed service edges shown in the diagram.
- Secrets, OCIDs, customer CIDRs, endpoint URLs, and contact data belong in ignored local tfvars or a secure pipeline variable store, not in committed files.

## Detailed Architecture Notes

These notes expand the diagram with the design details that usually matter during review, plan, and hand-off.

- The cluster depends on an existing VCN ID and optional endpoint/service load balancer subnet IDs supplied by the caller.
- Endpoint subnet, public endpoint flag, and endpoint NSGs define the operator access path to the Kubernetes API.
- Node pools depend on the created or referenced cluster ID and use the supplied node subnet IDs, shape, image, SSH key, and sizing inputs.
- Service load balancer subnet choices decide where Kubernetes Service traffic enters the VCN.

## Review Checklist

- Confirm the diagram matches `main.tf`: `oci_containerengine_cluster.this`, `oci_containerengine_node_pool.this`.
- Confirm the described traffic path is the path you want in OCI before apply.
- Confirm public exposure, private endpoint access, DNS behavior, DRG routing, and inspection points are intentional where present.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `terraform output` will expose the hand-off values expected by downstream teams: `blueprint_name`, `name_prefix`, `resource_ids`, `cluster_id`, `node_pool_id`.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.
