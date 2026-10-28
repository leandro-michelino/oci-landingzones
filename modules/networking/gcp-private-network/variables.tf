variable "project_id" {
  description = "Existing Google project ID; billing and required APIs are prerequisites."
  type        = string
}

variable "region" {
  description = "Approved Google region."
  type        = string
}

variable "name" {
  description = "Unique lowercase resource name prefix."
  type        = string
}

variable "enabled" {
  description = "Create the private network foundation only after reviewed approval."
  type        = bool
  default     = false
}

variable "costs_approved" {
  description = "Explicit acknowledgment of potential billed dependencies."
  type        = bool
  default     = false
}

variable "subnet_cidr" {
  description = "Private workload subnet; must not overlap peer, pod or service ranges."
  type        = string
  default     = "10.96.10.0/24"
}

variable "peer_cidrs" {
  description = "Approved remote workload CIDRs; ingress is empty unless ports also supplied."
  type        = set(string)
  default     = []
}

variable "allowed_tcp_ports" {
  description = "Explicit ingress ports scoped to peer CIDRs and target network tag."
  type        = set(number)
  default     = []
}

variable "enable_nat" {
  description = "Create explicit Internet route and Cloud NAT; incurs potential charges."
  type        = bool
  default     = false
}

variable "secondary_ranges" {
  description = "Named GKE pod/service secondary subnet ranges."
  type        = map(string)
  default     = {}
}
