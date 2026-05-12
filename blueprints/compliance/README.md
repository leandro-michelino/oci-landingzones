# Compliance Blueprints

Compliance blueprints compose core, identity, networking, logging, and security controls
for regulated landing zone profiles that need more than a generic CIS toggle.

## What It Does

This is the place for landing-zone shapes where compliance is not a footnote. These
folders combine core, IAM, logging, networking, inspection, and operating model
decisions so the design can survive a real security or risk conversation.

## Why Use It

Use this folder when controls and auditability drive the architecture more than the
basic landing zone shape. These patterns are for customers who need to explain the
design to security, risk, or regulators.

## When To Use It

- Use SCCA cloud-native for regulated inspected workloads.
- Use Zero Trust when segmentation and identity-aware access are central.
- Keep CIS as its own explicit choice, not an accidental default.

## Blueprints

| Blueprint | Path | Purpose |
|---|---|---|
| SCCA cloud native | `scca-cloud-native/` | Regulated cloud-native landing zone with strong ingress, egress, logging, and inspection boundaries. |
| Zero Trust | `zero-trust/` | Identity-aware, least-privilege, segmented landing zone pattern using ZPR and inspected traffic paths. |
