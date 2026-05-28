# Windows AD Domain-Joined Compute Runbook

Use this runbook when an OCI Full Stack Disaster Recovery plan protects a Windows
compute instance that is joined to an Active Directory domain.

## Scope

This blueprint creates the FSDR control plane. Active Directory, DNS, NTP, routing,
security rules, and application validation remain workload responsibilities. Capture
those dependencies in the drill or switchover runbook before executing the plan.

The guidance below applies to Windows member servers. Domain controllers need an
AD-specific disaster recovery design and should not be treated as ordinary movable
compute members.

## Before Any Drill, Switchover, Or Failover

- Confirm the VM is a member server, not a domain controller.
- Confirm the compute instance and every attached boot or block volume are protected
  by the replicated volume group registered with FSDR.
- Confirm the destination subnet, route tables, NSGs, security lists, and any
  firewall rules allow the Windows VM to reach domain controllers and DNS servers.
- Confirm the destination VCN or subnet DNS configuration points to AD-capable DNS
  resolvers when the workload requires domain name resolution.
- Confirm Kerberos time tolerance is protected by reliable time sync in both regions.
- Confirm the destination hostname label and private IP plan will not conflict with
  an existing VNIC, stale source VNIC, or another drill copy.
- Confirm Windows services, listeners, scheduled tasks, agents, and application
  bindings are not hardcoded to the source-region private IP address.
- Confirm service accounts, SPNs, certificates, and licensing controls are valid in
  the standby region.
- Add FSDR user-defined plan groups or manual runbook steps for any hostname, DNS,
  service, load balancer, monitoring, backup, or application actions that FSDR cannot
  infer from the compute and volume-group members.

Recommended Windows checks before execution:

```powershell
nltest /dsgetdc:yourdomain.example
nltest /sc_verify:yourdomain.example
Test-ComputerSecureChannel -Verbose
w32tm /query /status
nslookup yourdomain.example
```

## Drill-Specific Controls

Start Drill creates a test copy while the production VM can remain online. A domain
joined drill copy must not boot onto the same production AD network with the same
hostname and computer account unless that duplicate identity is explicitly planned.

For drills, use one of these patterns:

- Isolated drill network with no path to production AD.
- Isolated drill network with a lab or restored AD environment.
- FSDR custom steps that keep the drill copy offline from production AD until it is
  renamed, disjoined, or otherwise made unique.

During Stop Drill, verify that drill copies, temporary DNS records, monitoring
objects, backup jobs, and any custom drill artifacts are removed.

## Switchover Or Failover Controls

For a real switchover or failover of a Windows member server, do not Sysprep the VM
and do not unjoin or rejoin the domain as a routine action. The recovered boot volume
carries the Windows computer identity. The normal goal is to boot the same server
identity in the recovery region after the source role has stopped or failed.

After the recovered VM starts, validate:

```powershell
Test-ComputerSecureChannel -Verbose
nltest /dsgetdc:yourdomain.example
ipconfig /registerdns
gpupdate /force
```

If the secure channel is broken, repair it deliberately instead of creating a new
computer identity:

```powershell
Test-ComputerSecureChannel -Repair -Credential YOURDOMAIN\AdminUser
```

## Switchback

- Generate and run the reverse switchover from the DR protection group that is
  currently standby.
- Recheck that the original destination hostname label and private IP are available.
- Remove or rename stale VNICs that still hold the intended hostname label.
- Reconfirm the AD secure channel, DNS registration, GPO processing, monitoring, and
  backup policy after the VM returns to the original region.

## Do Not Do This For Domain Controllers

If the protected Windows VM is a domain controller, stop and use an AD-specific
recovery pattern. Prefer domain controllers in both regions with normal AD replication
and validated FSMO, DNS, time, backup, and restore procedures. Snapshot-style rollback
or ordinary movable-compute recovery can create directory replication problems.
