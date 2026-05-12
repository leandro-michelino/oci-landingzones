# Extension Deployment Blueprints

Extensions add platform services on top of the core landing zone and networking
baseline. Each extension folder documents its own prerequisites, deployment flow, and
architecture artifact locations.

## What It Does

This is the add-on catalog for services that workloads actually consume after core and
networking are in place. Think Kubernetes, databases, API ingress, event streaming, and
web protection: not the whole landing zone, but the useful platform pieces teams keep
asking for.

## Why Use It

Use this folder for platform services that sit on top of core and networking. These are
not the foundation; they are the services workloads actually consume.

## When To Use It

- Add OKE for Kubernetes platforms.
- Add Exadata for database-heavy estates.
- Add API Gateway, Streaming, or WAF when the workload shape needs them.

## Catalogue

| Extension | Folder | Use When |
|---|---|---|
| API Gateway | `apigw/` | APIs need managed ingress, routing, and policy controls. |
| Exadata | `exadata/` | Database workloads require Exadata infrastructure. |
| OKE | `oke/` | Kubernetes workloads run on OCI Container Engine for Kubernetes. |
| Streaming | `streaming/` | Event-streaming or decoupled messaging is required. |
| WAF | `waf/` | Internet-facing applications need web application firewall controls. |

## Folder Contract

Each extension folder should contain:

- `README.md` with purpose, prerequisites, inputs, and flow.
- `architecture/<extension>.excalidraw` for the editable diagram.
- `architecture/<extension>.png` for the exported image.
- Terraform code and safe example variables.
