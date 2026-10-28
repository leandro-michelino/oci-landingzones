variable "project_id" {
  description = "Existing Google project with billing and required APIs pre-enabled."
  type        = string
}

variable "region" {
  description = "Explicit approved GCP region."
  type        = string
}

variable "name" {
  description = "Unique lowercase resource prefix; examples are not live destinations."
  type        = string
}

variable "enabled" {
  description = "Create GCP foundation only after reviewed approval."
  type        = bool
  default     = false
}

variable "costs_approved" {
  description = "Explicit approval of billed GCP dependencies."
  type        = bool
  default     = false
}

variable "subnet_cidr" {
  description = "Private workload subnet range."
  type        = string
  default     = "10.96.10.0/24"
}

variable "peer_cidrs" {
  description = "Reviewed OCI workload prefixes."
  type        = set(string)
  default     = ["10.95.10.0/24"]
}

variable "allowed_tcp_ports" {
  description = "Explicit VM ingress ports; applies only to tagged VM NICs."
  type        = set(number)
  default     = []
}

variable "enable_nat" {
  description = "Optional paid Cloud NAT and Internet route."
  type        = bool
  default     = false
}

variable "enable_workload" {
  description = "Create the pattern-specific workload resources; paid and disabled by default."
  type        = bool
  default     = false
}

variable "zone" {
  description = "Approved GCP zone for an optional standby VM."
  type        = string
}

variable "standby_image" {
  description = "Compatible explicit boot image; no OCI image conversion or data restore is automatic."
  type        = string
  default     = null
}
