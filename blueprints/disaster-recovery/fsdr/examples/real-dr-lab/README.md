# FSDR Real DR Lab

This optional lab creates disposable workload resources that can be attached to the
`blueprints/disaster-recovery/fsdr` protection groups for a real switchover drill.
It is intentionally separate from the production FSDR blueprint state.

## What It Creates

| Capability | Lab Resources |
| --- | --- |
| Compute | One small primary-region instance with a private VNIC. |
| Block Volume | A volume group that protects the instance boot volume and replicates it to the standby region. |
| Network | Primary and standby VCNs and subnets for movable-compute destination mapping. |
| Object Storage | Primary and standby buckets for replication and FSDR object-storage member tests. |

The lab does not execute FSDR plans and does not change IAM. It only creates the
workload resources and outputs the IDs needed by an operator or runbook.

## Run

```bash
cd blueprints/disaster-recovery/fsdr/examples/real-dr-lab
mkdir -p .work
cp *.tf.example .work/
cp terraform.tfvars.example .work/
for file in .work/*.tf.example; do mv "$file" "${file%.example}"; done
cd .work
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
```

The checked-in files use the `.tf.example` suffix so this lab is documented as an
example harness, not as another repository-managed blueprint. Keep generated `.tf`
files and local Terraform working data under `.work/` or another ignored local folder.

Use the outputs to register FSDR members. For a compute switchover, add both the
movable compute instance and the replicated volume group. The movable compute member
also needs a destination subnet mapping; use `standby_subnet_id` when the primary DRPG
is primary, and use `primary_subnet_id` when switching back.

## Drill Order

1. Apply the main FSDR blueprint and associate the primary and standby DRPGs.
2. Apply this lab.
3. Add the lab volume group and compute instance to the current primary DRPG.
4. Confirm the volume-group replica is `AVAILABLE`.
5. Generate a switchover plan on the current standby DRPG.
6. Run precheck.
7. Execute switchover.
8. Generate and execute the reverse switchover from the new standby DRPG.
9. Remove the lab members from the DRPGs.
10. Destroy this lab.

## Field Notes

- FSDR plans are generated and executed from the DRPG that is currently standby.
- Movable compute requires every attached boot and block volume to be protected by a
  replicated volume group that is also an FSDR member.
- Object Storage bucket members require Object Storage replication to be configured
  before FSDR plan generation.
- Hostname labels must be available in the destination subnet. If a stopped source
  instance still owns a hostname label during switchback, rename or terminate the stale
  VNIC before retrying the failed precheck.
- Replication teardown can preserve boot volumes after instance termination. Disable
  boot-volume replicas before deleting preserved boot volumes.

## Cleanup

Remove FSDR members and any generated DR plans first. Then run:

```bash
terraform destroy
```

If Terraform cannot delete a volume or volume group because replication is still enabled,
wait for replication updates to settle, disable the replica configuration, and retry.
