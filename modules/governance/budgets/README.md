# Budget Ownership And Targets

Budget resources belong to the tenancy root (`tenancy_ocid`). The module compartment and per-budget compartment override identify spending targets when explicit `targets` are absent; they do not move budget ownership into a workload compartment. Configure the caller provider for the tenancy home region. Budget creation is an administrative action outside a workload-compartment-only lifecycle test. Budgets and alerts are soft spending controls, not a hard cap or automatic resource shutdown.

This scope follows [Oracle budget creation](https://docs.oracle.com/en-us/iaas/Content/Billing/Tasks/create-budget.htm) and [Oracle home-region service guidance](https://www.ateam-oracle.com/oci-home-region-explained-its-role-in-identity-domains-and-service-access).

The root-scope tests use mocked providers and verify ownership separately from spending targets. No live budget was created during the October 14, 2026 review.
