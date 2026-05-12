# API Gateway Extension

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this extension when applications need managed API ingress, routing, and policy
enforcement.

## What It Does

This extension gives APIs a managed front door. It captures the gateway, routes, backend
reachability, authentication choices, certificates, DNS, logging, and policy decisions
so every application team is not inventing API exposure from scratch.

## Why Use It

Use this when APIs need a managed front door instead of every team inventing their own
exposure model. API Gateway gives you a standard place for routes, auth, and backend
access.

## When To Use It

- Applications expose APIs to users, partners, or internal consumers.
- Authentication and routing should be centralized.
- Backends live in private workloads or service networks.

## Pattern

- API Gateway deployment.
- Routes to private or public backends.
- Optional authentication and authorization policies.
- Logging and metrics integration.

## Prerequisites

- `blueprints/core` deployed.
- Networking blueprint with backend reachability.
- DNS and certificate approach defined if public ingress is required.

## Inputs To Decide

- Gateway compartment.
- Public or private endpoint.
- Backend services.
- Routes and methods.
- Authentication policy.
- TLS certificate ownership.

## Deployment Flow

1. Confirm backend reachability.
2. Complete the local architecture diagram.
3. Populate local ignored tfvars.
4. Run Terraform validation and plan.
5. Apply after API routes and security policy are reviewed.

## Architecture Artifacts

- Source diagram: `architecture/apigw.excalidraw`
- Exported image: `architecture/apigw.png`
