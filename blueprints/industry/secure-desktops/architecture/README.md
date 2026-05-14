# Secure Desktops Landing Zone Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

## Deployment Purpose

This blueprint creates an OCI Secure Desktops landing-zone pattern for managed
VDI use cases. It standardizes image selection, private network placement,
device redirection rules, storage backup posture, session lifecycle behavior,
alarms, and IAM.

## Architecture At A Glance

| Layer | Components |
| --- | --- |
| Access | End users connect through the approved Secure Desktops service path. |
| Desktop pool | Shape, capacity, image, storage, standby, and schedules. |
| Network | VCN, private subnet, NSGs, and optional private access endpoint. |
| Control | Device policy and session lifecycle actions. |
| Governance | IAM policy shell, alarms, tags, BYOL acknowledgement, and image ownership. |

## Windows 10/11 BYOL Note

As of 2026-05-14, Oracle documents that it provides general-purpose Windows
base images for Secure Desktops, but OCI does not provide Windows 10 or Windows
11 images or licenses. Customers must bring their own Windows 10/11 license and
comply with their Microsoft license agreement before using those desktop images.
For Terraform/API-created Windows BYOL pools, this blueprint adds the immutable free-form tag
`oci:desktops:enable_byol = true` when
`windows_10_11_byol_acknowledged` is set to `true`.

## ASCII Architecture

```text
+--------------------------------------------------------------------------------+
|                         Secure Desktops Landing Zone                            |
+--------------------------------------------------------------------------------+
|                                                                                |
|  End User                                                                      |
|      |                                                                         |
|      | approved desktop access path                                            |
|      v                                                                         |
|  OCI Secure Desktops Pool                                                      |
|      |                                                                         |
|      +--> Approved image                                                       |
|      +--> Windows 10/11 BYOL acknowledgement and pool tag when needed          |
|      +--> Shape and flex shape config                                          |
|      +--> Maximum and standby pool size                                        |
|      +--> Desktop storage and backup policy                                    |
|      |                                                                         |
|      v                                                                         |
|  Private VCN Placement                                                         |
|      |                                                                         |
|      +--> Desktop subnet                                                       |
|      +--> NSGs for corporate/VPN access                                        |
|      +--> Optional private access endpoint                                    |
|      |                                                                         |
|      v                                                                         |
|  Workload / Admin Targets                                                      |
|      |                                                                         |
|      +--> Private apps                                                         |
|      +--> Databases                                                            |
|      +--> Admin tools                                                          |
|      `--> Internal SaaS or integration endpoints                               |
|                                                                                |
|  Governance Lane                                                               |
|      |                                                                         |
|      +--> Device policy: clipboard, drives, audio, printing, video             |
|      +--> Session lifecycle: disconnect and inactivity actions                 |
|      +--> Monitoring alarms                                                    |
|      `--> IAM: pool admin, desktop user, read-only auditor                     |
+--------------------------------------------------------------------------------+
```

## Terraform Components

| File | Purpose |
| --- | --- |
| `main.tf` | Creates Secure Desktops pool, optional private access and session policy blocks, alarms, and IAM policy. |
| `variables.tf` | Defines image, network, shape, storage, device, session, alarm, and policy inputs. |
| `outputs.tf` | Exposes desktop pool, state, active count, alarm, and policy identifiers. |
| `terraform.tfvars.example` | Shows safe placeholder values for image and private network inputs. |

## Request And Deployment Flow

1. End-user population and data classification are confirmed.
2. Image owner provides an approved image OCID and name.
3. Network owner supplies VCN, subnet, NSG, and private access details.
4. Security owner reviews device and session policies.
5. Terraform creates or references the desktop pool.
6. IAM outputs are handed to desktop admins and user onboarding owners.

## Traffic And Trust Boundaries

- Desktops run inside customer-approved VCN/subnet placement.
- Device redirection controls prevent accidental data movement to unmanaged devices.
- Private access and NSGs should align with corporate VPN or zero-trust access.
- Desktop storage and backup policies define data persistence expectations.
- IAM should separate pool administrators from end users and auditors.

## Detailed Architecture Notes

- `create_desktop_pool` defaults to false because image, subnet, and backup
  policy choices are customer-specific.
- `windows_10_11_byol_acknowledged` documents the customer license decision and
  adds the required Secure Desktops BYOL pool tag during Terraform creation.
- `device_policy` is explicit so reviewers can see every redirection setting.
- Optional start/stop schedules help control cost in non-production pools.
- Session lifecycle actions are optional because customers vary on disconnect behavior.
- Monitoring alarms are map-driven to let operations teams choose supported metrics.
- The blueprint references image and backup policy OCIDs rather than creating them.

## Operational Boundaries

- Terraform does not build or patch desktop images.
- Terraform does not onboard individual users into identity groups.
- Domain join, endpoint security tooling, and profile management are customer workflows.
- Desktop software licensing must be reviewed outside Terraform.
- Session monitoring and user support processes belong in the operations runbook.

## Review Checklist

- Approved desktop image OCID and owner are documented.
- Windows 10/11 BYOL rights are confirmed when Windows 10/11 images are used.
- VCN, subnet, NSG, and private access path are approved.
- Device policy matches data-loss prevention expectations.
- Storage preservation and backup policy are reviewed.
- Capacity and standby settings match expected usage.
- IAM policy statements are group-based and least-privilege.
- End-user support and image patching owners are known.
