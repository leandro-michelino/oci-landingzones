# Hub-Spoke With ZPR Micro-Segmentation

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this deployment when multiple VCNs need segmentation intent using Zero Packet
Routing attributes.

## What It Does

This blueprint adds ZPR-based segmentation intent to a multi-VCN hub-spoke network. It
keeps ZPR namespaces, application attributes, allowed flows, inspection paths, and
exception handling close to the network design instead of hiding segmentation in subnet
names.

## Why Use It

Use this when segmentation spans more than one VCN and subnet-based thinking is not
enough. ZPR lets the design talk about workload intent, not only IP ranges.

## When To Use It

- East-west control is a major requirement.
- Applications need segmentation metadata across VCNs.
- Security wants an explicit communication matrix.

## Pattern

- Hub VCN.
- Spoke VCNs.
- DRG attachments.
- ZPR attributes for services or tiers.
- Security controls aligned with micro-segmentation rules.
- Optional inspection path through firewall or appliance.

## Best Fit

- Multi-application environments.
- Strict east-west control.
- Customers standardizing segmentation metadata.
- Designs where application identity matters as much as subnet location.

## Inputs To Decide

- ZPR namespaces and attributes.
- Application or tier segmentation model.
- Allowed communication matrix.
- Hub and spoke CIDRs.
- Inspection requirement.
- Exception handling process.

## Deployment Flow

1. Deploy `blueprints/core`.
2. Complete the architecture notes with ZPR attributes and allowed flows.
3. Review the communication matrix with application and security owners.
4. Populate local tfvars.
5. Run Terraform validation and plan.
6. Apply after segmentation rules are approved.

## Architecture Artifacts

- Architecture notes: `architecture/README.md`

## Notes

Keep the segmentation model readable. This folder should explain what each ZPR attribute
means for the customer.
