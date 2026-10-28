# GCP Private Network Foundation

Reusable private VPC, subnet with flow logs, Cloud Router and conditional scoped ingress for GCP counterparts. All cloud resources are disabled by default. Existing project, billing, Compute API and scoped ADC credentials are prerequisites; this module does not manage those resources.

Network creation requires `enabled=true` and `costs_approved=true`. Public default routes are deleted. An explicitly enabled Cloud NAT and default Internet route provide optional egress; otherwise API/artifact reachability and routes remain operator prerequisites. Private Google Access alone is not proof of service reachability. Firewall ingress requires both peer CIDRs and ports, and applies only to workload VMs with the output network tag. It does not automatically authorize GKE Pods, Cloud Run or private service networking.

GKE secondary subnet ranges are optional. Cloud Router is a BGP control plane and is not a packet-forwarding appliance. The default ASN 16550 is for Partner Interconnect; a VPN-specific design must choose a compatible separate router/ASN where required.

No cross-cloud circuit, VPN, workload, DNS, organization policy, KMS key or service IAM grant is implied. Companion blueprint roots add those resources or label external dependencies explicitly. The schema and mocked tests are local configuration evidence only.
