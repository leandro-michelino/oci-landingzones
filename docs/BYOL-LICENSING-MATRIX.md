# BYOL And License Model Matrix

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This page records where this landing zone exposes Bring Your Own License,
license-included, BYOI, or BYOS decisions. It is an operator guide, not a legal
license opinion. Always confirm customer entitlement, support status, regional
availability, and the current Oracle or vendor contract before apply.

Oracle licensing language changes over time. Re-check the current Oracle
documentation before adding new license flags or changing defaults.

## Implementation Rule

Do not add a generic `byol = true` flag to every blueprint. Use the service's
real OCI API field when it exists, and document image/subscription workflows
when the service is driven by customer-provided images rather than a license
model enum.

```text
service has OCI license field  -> expose that field with conservative defaults
image/subscription workflow    -> document the image, tag, and support contract
no Oracle-documented BYOL path -> do not add a BYOL variable
```

## Current Repo Coverage

| Service Area | OCI Model | Repo Surface | Status |
| --- | --- | --- | --- |
| Autonomous Database | `LICENSE_INCLUDED` or `BRING_YOUR_OWN_LICENSE` | `blueprints/data-platform/autonomous-database` `license_model` | Wired with validation. |
| Oracle Analytics Cloud | `LICENSE_INCLUDED` or `BRING_YOUR_OWN_LICENSE` | `blueprints/extensions/oac` `license_type` | Wired with validation. |
| Oracle Integration Cloud | BYOL boolean on integration instance | `blueprints/extensions/oic` `is_byol` | Wired and documented. |
| OCI Compute Windows VMs | OCI-provided or Microsoft BYOL licensing config where supported | `modules/networking/net-appliance` per-appliance `licensing_configs` | Wired for NVA compute use cases. |
| OCI Secure Desktops Windows 10/11 | Customer BYOL acknowledgement and required pool tag | `blueprints/industry/secure-desktops` `windows_10_11_byol_acknowledged` | Wired with validation and tag injection. |
| Red Hat Enterprise Linux on OCI Compute | BYOI/BYOS image and subscription workflow | NVA and future compute blueprints use customer image OCIDs | Documented; no generic Terraform license enum. |
| Exadata Database Service | BYOL applies at VM cluster/database service layer | `blueprints/extensions/exadata` creates infrastructure only | Documented as follow-on DB platform decision. |
| Base Database Service | BYOL applies to DB system/database service resources | No dedicated Base DB blueprint yet | Track for future database blueprint. |
| Oracle WebLogic Server for OCI | Marketplace / service BYOL model | No WebLogic blueprint yet | Track for future industry or extension blueprint. |
| OCI GoldenGate | License-included or BYOL model | No GoldenGate blueprint yet | Track for future data-platform blueprint. |
| Oracle Content Management | BYOL model for eligible WebCenter licenses | No OCM blueprint yet | Track for future extension blueprint. |
| Oracle Cloud VMware Solution | Broadcom BYOL model where available | No OCVS blueprint yet | Track for future industry blueprint. |

## Blueprint Notes

### Autonomous Database

Use `license_model = "LICENSE_INCLUDED"` by default. Change to
`BRING_YOUR_OWN_LICENSE` only after the DBA and commercial owners confirm
eligible Oracle Database licenses for the selected workload and compute model.

```hcl
license_model = "BRING_YOUR_OWN_LICENSE"
```

### Oracle Analytics Cloud

Use `license_type = "LICENSE_INCLUDED"` by default. Change to
`BRING_YOUR_OWN_LICENSE` only after the analytics owner confirms eligible
Oracle Analytics licensing for the selected feature set and capacity model.

```hcl
license_type = "BRING_YOUR_OWN_LICENSE"
```

### Oracle Integration Cloud

Use `is_byol = false` by default. Set it only after confirming the customer has
eligible Oracle Integration licensing for the edition and message pack plan.

```hcl
is_byol = true
```

### OCI Compute Windows VMs

For NVA patterns that create `oci_core_instance`, use per-appliance
`licensing_configs` only when the image and customer agreement support the
selected model.

```hcl
appliances = {
  firewall_a = {
    availability_domain = "example:EU-FRANKFURT-1-AD-1"
    subnet_id           = "ocid1.subnet.oc1.eu-frankfurt-1.example"
    image_id            = "ocid1.image.oc1.eu-frankfurt-1.example"

    licensing_configs = [
      {
        type         = "WINDOWS"
        license_type = "BRING_YOUR_OWN_LICENSE"
      }
    ]
  }
}
```

### Red Hat Enterprise Linux

Treat RHEL as an image and subscription decision unless the selected Oracle
Marketplace image documents another model. For customer-owned RHEL images,
capture the approved image OCID, support contract, and patching owner in local
tfvars or deployment notes. Do not use a generic BYOL flag for RHEL.

### Exadata And Base Database

The current Exadata extension creates Exadata Cloud Infrastructure only. BYOL
is a database platform decision at the VM cluster or database service layer, so
do not add a license flag to the infrastructure-only resource. Add license
model inputs when this repo grows VM cluster, Base Database, or dedicated
database deployment blueprints.

## Oracle Documentation To Re-Check

- OCI Compute Microsoft BYOL:
  `https://docs.oracle.com/en-us/iaas/Content/Compute/References/bring-your-own-license.htm`
- OCI custom Linux image import:
  `https://docs.oracle.com/iaas/Content/Compute/Tasks/importingcustomimagelinux.htm`
- Autonomous Database license selection:
  `https://docs.oracle.com/en-us/iaas/autonomous-database-serverless/doc/autonomous-choose-license.html`
- Base Database licenses:
  `https://docs.oracle.com/en/cloud/paas/base-database/licenses-dbs/`
- Exadata Database Service creation and license options:
  `https://docs.oracle.com/en-us/iaas/exadatacloud/doc/ecs-create-instance.html`
- Oracle Analytics Cloud service creation:
  `https://docs.oracle.com/en/cloud/paas/analytics-cloud/acmgb/create-your-service-oracle-cloud-infrastructure.html`
- Oracle WebLogic Server for OCI licensing:
  `https://docs.oracle.com/en/cloud/paas/weblogic-cloud/user/oracle-weblogic-server-oracle-cloud-infrastructure.html`
- Oracle GoldenGate service catalog and licensing:
  `https://docs.oracle.com/en/cloud/paas/goldengate-service/cstlg/index.html`
- Oracle Content Management service management:
  `https://docs.oracle.com/en-us/iaas/content-management/doc/manage-service.html`
- Oracle Cloud VMware Solution BYOL release note:
  `https://docs.oracle.com/iaas/releasenotes/oracle-cloud-vmware-solution/byol.htm`
