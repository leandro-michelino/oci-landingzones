# Telco Cloud-Native Landing Zone

This blueprint is for telco-oriented cloud-native platforms where OKE, segmented
networking, private connectivity, and operational telemetry are part of the landing zone
baseline.

## What It Does

This blueprint shapes OCI for telco-style cloud-native workloads. It combines OKE,
private connectivity, segmentation, observability, image/security scanning, operations
hooks, and platform controls into a baseline that fits CNF and telco application
conversations.

## Why Use It

Use this when the platform is for telco-style cloud-native workloads, where OKE,
segmentation, private connectivity, and operations telemetry are all part of the
baseline conversation.

## When To Use It

- Cloud-native network functions or telco apps are in scope.
- Private connectivity and segmentation are mandatory.
- OKE and observability are platform requirements, not later add-ons.

## Fit

- Cloud-native network functions.
- Telco application platforms on OKE.
- Strict segmentation and private connectivity requirements.

## Expected Composition

- Core compartments, IAM, and governance.
- OKE extension with private cluster options.
- Hub-spoke or private endpoint networking.
- Network security groups and ZPR where appropriate.
- Logging, metrics, events, and runbook hooks.
- Vault and image/security scanning controls.

## Deployment Notes

Use this after core and a selected networking pattern. It can compose OKE, streaming,
WAF, API Gateway, and private data platform pieces as needed.
