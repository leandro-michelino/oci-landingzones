# Generic VMware Workload Proposals

These examples apply to the [OCVS foundation](../../blueprints/industry/ocvs/),
[on-premises HCX migration](../../blueprints/industry/ocvs-onprem-hcx/),
[AVS/OCVS interconnect](../../blueprints/industry/azure-avs-ocvs-interconnect/)
and [three-site triangle](../../blueprints/industry/azure-avs-ocvs-onprem-triangle/).
They are industry-neutral proposals. No application, guest VM or database has
been deployed, migrated, benchmarked or verified running by these blueprints.

## Example Application

Use a generic internal customer/order portal with three separately managed
Linux guest VMs: NGINX web proxy, Spring Boot API and PostgreSQL database.
The VMware cluster provides guest compute/storage/network placement; it does
not install packages, configure database consistency or make the application HA.
Select supported guest OS, Java/application/database releases and VMware tools
before preparing golden images. Match the actual Spring Boot release to its
[Java and dependency requirements](https://docs.spring.io/spring-boot/system-requirements.html).
No version combination or VM sizing is certified by this repository.

| Guest role | Application responsibility | Illustrative connection policy | Operational dependencies |
| --- | --- | --- | --- |
| Web VM | NGINX TLS termination and reverse proxy | Private clients to TCP 443; web to API TCP 8443 | Reviewed DNS, certificates, identity integration and upstream health |
| API VM | Spring Boot REST endpoints and business logic | API to PostgreSQL TCP 5432 with TLS; no client-to-DB access | Secret distribution, application schema, connection pooling and authorization |
| Database VM | PostgreSQL persistent data | Only approved API/admin/backup sources | Storage sizing, patching, backup, WAL archive, restore and integrity testing |

The ports are design choices, not opened rules. Configure scoped NSX segments
and distributed/gateway firewall policies, existing OCI VLAN/subnet security
and approved client access. Cross-cloud database RTT, packet loss and transaction
rate require a load test before accepting a split application. Use transport and
application encryption deliberately; a private circuit alone is not encryption.

## Placement By Blueprint

| Blueprint | Suggested placement | Migration/continuity approach | Required acceptance |
| --- | --- | --- | --- |
| OCVS foundation | All three tiers inside its WORKLOAD cluster | Guest deployment after SDDC/network readiness | HTTPS request, API transaction, SQL persistence and restore |
| On-premises + OCVS HCX | Start with the complete stack on-premises; move one reviewed wave into OCVS | Per-pair HCX service mesh, dependency mapping, controlled cutover | DNS/TLS/identity checks, data consistency and source rollback |
| AVS + OCVS | Demonstration: web/API guests in AVS and database guest in OCVS | Split tiers only after vendor-approved connectivity and measured application latency | End-to-end transaction over the real intercloud path; colocate all tiers if latency is unsuitable |
| On-premises + AVS + OCVS triangle | Initial stack on-premises, isolated pilot in AVS, final stack on OCVS | Select one active home for the whole stack per migration wave; do not run cloned production DB primaries simultaneously | Test each independent leg, migration/rollback and application cutover separately |

The triangle is connectivity between three sites, not application active-active
or automatic three-site DR. HCX service meshes are pairwise. Validate licensing,
version interoperability and cloud-to-cloud HCX support before configuring the
AVS/OCVS pair. Do not infer migration eligibility from a working IP connection.

## Other Candidate Applications

| Candidate | Guest-level implementation example | Additional work before claiming it runs |
| --- | --- | --- |
| Internal portal or document API | Linux web/API guests and PostgreSQL | User authorization, schema, storage, TLS, backup and functional tests |
| Legacy business application | Existing Windows/IIS or Java application VMs | Vendor support matrix, OS/database licensing, dependencies and migration rehearsal |
| Development/test copy | Isolated sanitized copy of the three-tier stack | Non-production DNS/segments, data sanitization and external integration isolation |
| Recovery rehearsal | Restore the stack into an isolated target site | Consistent backups, WAL handling, recovery runbook and measured recovery test |

These are workload candidates, not statements of vendor certification for ERP,
SAP, Oracle E-Business Suite, SQL Server or any particular VMware offering.
A vendor-approved combination and license review are required before selecting
a proprietary workload. No VM count, capacity, production SLA or cost is assumed.

## Application Deployment And Cutover Runbook

1. Define the actual application artifact, supported versions, guest images and owners.
2. Size CPU/RAM/storage using a representative workload; no host count implies guest capacity.
3. Configure NSX networks, scoped rules, DNS/NTP, private access, TLS and secrets.
4. Install PostgreSQL, create the application database/least-privilege role and load synthetic test data.
5. Install/configure the API with its actual schema and DB TLS/identity settings; deploy NGINX and certificates.
6. Exercise HTTPS login, create/read/update operations and persistence after an API restart.
7. Validate full backup and point-in-time/restore procedures against PostgreSQL's [backup guidance](https://www.postgresql.org/docs/current/backup.html).
8. Take a consistent cutover backup/checkpoint; quiesce writes when required by the chosen migration method.
9. Execute the reviewed HCX wave, confirm target data/identity/network state and switch DNS only after tests pass.
10. Reconcile application records, test restore and retain a time-bounded source rollback plan.

Guest provisioning, package installation, application source code, credentials,
load-balancer configuration, replication and backup automation are external to
these infrastructure blueprints. HCX VM mobility or an optional L2 extension
does not replace database-consistent backups, application recovery procedures or
independent availability mechanisms. RPO/RTO must be measured in a real test.
