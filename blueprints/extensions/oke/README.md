# OKE Extension

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this extension when Kubernetes workloads should run on OCI Container Engine for
Kubernetes.

## What It Does

This extension brings OKE into the landing zone as a platform service, not an
afterthought. It calls out cluster placement, private nodes, endpoint exposure, ingress,
registry access, IAM integration, logging, and the choices platform and application
teams need to agree on.

## Why Use It

Use this when Kubernetes is the workload platform, not a side feature. It brings OKE
into the landing zone with the network, IAM, ingress, and logging decisions called out
up front.

## When To Use It

- Applications will run on OKE.
- Private nodes, endpoint visibility, and ingress need design review.
- Platform and app teams need a repeatable cluster pattern.

## Pattern

- OKE cluster.
- Node pools in private subnets.
- Optional public or private API endpoint.
- Load balancer integration.
- IAM, network, and logging integration.

## Prerequisites

- `blueprints/core` deployed.
- Networking blueprint with cluster, node, and load balancer subnets.
- Container image registry and ingress approach defined.

## Inputs To Decide

- Cluster endpoint visibility.
- Kubernetes version.
- Node pool shape and size.
- Pod and service networking model.
- Ingress controller.
- Logging and monitoring requirements.

## Deployment Flow

1. Confirm subnet and security requirements.
2. Complete the local architecture diagram.
3. Populate local ignored tfvars.
4. Run Terraform validation and plan.
5. Apply after platform and application teams review.

## Architecture Artifacts

- Source diagram: `architecture/oke.excalidraw`
- Exported image: `architecture/oke.png`
