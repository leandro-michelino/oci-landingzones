# WAF Extension

Use this extension when internet-facing applications need web application firewall
protection.

## What It Does

This extension puts a policy layer in front of public web traffic. It ties WAF rules,
protected hostnames, origins, DNS, TLS certificates, logs, and alerting back to the
landing-zone controls instead of treating internet exposure as an application-only
concern.

## Why Use It

Use this when public web traffic needs a proper protective layer before it reaches the
app. WAF belongs in the design when internet exposure is intentional and needs policy.

## When To Use It

- Internet-facing applications are in scope.
- Layer 7 protection and rule ownership are required.
- WAF needs to align with load balancer, API Gateway, or ingress design.

## Pattern

- OCI WAF policy.
- Origin application or load balancer.
- DNS and certificate integration.
- Managed and custom protection rules.
- Logging and monitoring.

## Prerequisites

- `blueprints/core` deployed.
- Internet-facing application endpoint identified.
- DNS and TLS certificate ownership confirmed.

## Inputs To Decide

- Protected application hostname.
- Origin endpoint.
- TLS certificate approach.
- Managed rule sets.
- Custom access rules.
- Logging destination and alerting.

## Deployment Flow

1. Confirm public application endpoint and DNS ownership.
2. Complete the local architecture diagram.
3. Populate local ignored tfvars.
4. Run Terraform validation and plan.
5. Apply after WAF policy and origin behavior are reviewed.

## Architecture Artifacts

- Source diagram: `architecture/waf.excalidraw`
- Exported image: `architecture/waf.png`
