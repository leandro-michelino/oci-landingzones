# Secure Desktops Landing Zone

Use this blueprint when contractors, regulated-data workers, or remote teams
need managed desktops in OCI without sensitive data landing on unmanaged end
user devices. It gives desktop pools the same landing-zone treatment as other
workloads: private networking, device policy, session policy, storage, alarms,
and IAM.

## At A Glance

| Item | Details |
| --- | --- |
| Folder | `blueprints/industry/secure-desktops` |
| Best fit | Managed VDI for contractors, regulated users, or private administrative workstations. |
| Terraform shape | Secure Desktops pool, device policy, image, network config, private access, alarms, IAM policy. |
| Default posture | Desktop pool creation is disabled until image, subnet, backup policy, and access rules are approved. |
| Customer paths | Extension-only with existing VCN/image controls, or base-plus-extension after Core and Networking. |

## What This Deploys

| Resource | Enable Flag |
| --- | --- |
| Secure Desktops pool | `create_desktop_pool` |
| Private access details | `private_access_subnet_id` set |
| Session lifecycle actions | `enable_session_lifecycle_actions` |
| Monitoring alarms | `alarms` map |
| IAM policy shell | `policy_statements` not empty |

## Good Use Cases

- Contractors who need access to private apps without copying data to their own
  devices.
- Regulated desktop sessions where clipboard, printing, audio, drives, and
  video input need explicit decisions.
- Admin workstations for database, network, or platform teams that should stay
  inside OCI private networking.
- Temporary desktop pools for projects where storage preservation, schedules,
  and alarms matter from day one.

## Deployment Modes

| Mode | How It Works |
| --- | --- |
| Review-only | Keep `create_desktop_pool = false`, populate safe metadata, and validate Terraform plus Ansible wrappers. |
| Low-cost control path | Keep desktop creation disabled and create only approved alarms or IAM policy statements. |
| Full desktop pool | Set `create_desktop_pool = true` after image, subnet, NSG, backup, license, and capacity approvals are complete. |

## Inputs To Decide

| Input | What To Decide |
| --- | --- |
| `image_id`, `image_name` | Approved Windows or Linux desktop image. |
| `vcn_id`, `subnet_id`, `nsg_ids` | Private placement and access boundaries. |
| `device_policy` | Clipboard, drive mapping, audio, printing, and video controls. |
| `storage_backup_policy_id` | User storage backup and preservation posture. |
| `maximum_size`, `standby_size` | Pool capacity and warm capacity. |
| `windows_10_11_byol_acknowledged` | Required acknowledgement before using Windows 10/11 images. |

## Windows 10/11 BYOL Note

As of 2026-05-14, Oracle documents that it provides general-purpose Windows
base images for Secure Desktops, but OCI does not provide Windows 10 or Windows
11 images or licenses. Customers must bring their own Windows 10/11 license and
comply with their Microsoft license agreement before using those desktop images.
When this blueprint creates a Windows 10/11 pool through Terraform, set
`windows_10_11_byol_acknowledged = true`; the blueprint then adds the immutable
Secure Desktops pool tag `oci:desktops:enable_byol = true` required for
API/CLI-style BYOL pool creation.

## Deployment Order

1. Confirm desktop user population and data classification.
2. Approve the desktop image, patching ownership, and Windows 10/11 BYOL rights when applicable.
3. Confirm VCN, subnet, NSG, and private access model.
4. Review device redirection, session lifecycle, and storage rules.
5. Run `terraform plan` or `ansible-playbook ansible/plan.yml`.
6. Apply after IAM groups and user onboarding flow are approved.

## Operator Notes

- Start with `create_desktop_pool = false` unless the image and subnet are
  already approved. It keeps validation cheap and avoids creating desktops
  before access rules are ready.
- `defined_tags = {}` is treated as no defined tags, which avoids drift from
  tenancy-managed system tags.
- A Windows 10/11 pool needs both customer license approval and
  `windows_10_11_byol_acknowledged = true`.
- Monitoring alarms and IAM policy statements are useful early checks because
  they validate provider access and naming without needing desktop capacity.
- Destroy disposable validation resources when the test is complete. Keep only
  long-lived desktop pools that have an owner, support contact, and schedule.

## Outputs

| Output | Meaning |
| --- | --- |
| `desktop_pool_id` | Secure Desktops pool OCID. |
| `desktop_pool_state` | Pool lifecycle state when Terraform creates it. |
| `desktop_pool_active_desktops` | Active desktop count when available. |
| `alarm_ids` | Monitoring alarm OCIDs. |
| `access_policy_id` | Optional IAM policy OCID. |

## Validation

```bash
terraform fmt -check
terraform init -backend=false
terraform validate
ansible-playbook ansible/plan.yml
```

For a disposable control-path check, create a local ignored `terraform.tfvars`
with `create_desktop_pool = false` and one disabled alarm or policy statement,
then run plan/apply/readback/destroy from this folder.

Review `architecture/README.md` before onboarding end users.
