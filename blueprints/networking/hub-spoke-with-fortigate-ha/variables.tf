# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
variable "tenancy_ocid" {
  description = "OCI tenancy OCID."
  type        = string
}

variable "current_user_ocid" {
  description = "OCI user OCID used for local execution or bootstrap."
  type        = string
}

variable "region" {
  description = "OCI region name."
  type        = string
}

variable "home_region" {
  description = "OCI tenancy home region."
  type        = string
  default     = null
}

variable "oci_config_profile" {
  description = "Optional OCI CLI config profile for local execution."
  type        = string
  default     = null
}

variable "org" {
  description = "Short organization prefix used in names."
  type        = string
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
}

variable "region_key" {
  description = "Short OCI region key used in resource names."
  type        = string
}

variable "compartment_ocid" {
  description = "Compartment OCID where networking resources are deployed. Defaults to tenancy_ocid for simple tests."
  type        = string
  default     = null
}

variable "hub_vcn_dns_label" {
  description = "DNS label for the hub VCN."
  type        = string
  default     = "hub"
}

variable "hub_vcn_cidr_block" {
  description = "CIDR block for the hub VCN."
  type        = string
  default     = "10.0.0.0/16"
}

variable "hub_subnets" {
  description = "Hub subnet map for FortiGate management, untrust, trust, and HA sync interfaces."
  type = map(object({
    cidr_block                 = string
    display_name               = optional(string)
    dns_label                  = optional(string)
    route_table_key            = optional(string, "private")
    security_list_keys         = optional(set(string), ["baseline"])
    prohibit_internet_ingress  = optional(bool, true)
    prohibit_public_ip_on_vnic = optional(bool, true)
  }))
  default = {
    dmz = {
      cidr_block                 = "10.0.0.0/24"
      dns_label                  = "dmz"
      route_table_key            = "public"
      prohibit_internet_ingress  = false
      prohibit_public_ip_on_vnic = false
    }
    mgmt = {
      cidr_block                 = "10.0.1.0/24"
      dns_label                  = "mgmt"
      route_table_key            = "public"
      prohibit_internet_ingress  = false
      prohibit_public_ip_on_vnic = false
    }
    trust = {
      cidr_block = "10.0.2.0/24"
      dns_label  = "trust"
    }
    ha = {
      cidr_block = "10.0.3.0/24"
      dns_label  = "ha"
    }
  }
}

variable "spoke_vcns" {
  description = "Spoke VCNs keyed by workload or team name."
  type = map(object({
    cidr_block = string
    dns_label  = string
    subnets = map(object({
      cidr_block                 = string
      display_name               = optional(string)
      dns_label                  = optional(string)
      route_table_key            = optional(string, "private")
      security_list_keys         = optional(set(string), ["baseline"])
      prohibit_internet_ingress  = optional(bool, true)
      prohibit_public_ip_on_vnic = optional(bool, true)
    }))
  }))
  default = {
    app1 = {
      cidr_block = "10.1.0.0/16"
      dns_label  = "appone"
      subnets = {
        web = {
          cidr_block = "10.1.0.0/24"
          dns_label  = "web"
        }
        app = {
          cidr_block = "10.1.1.0/24"
          dns_label  = "app"
        }
        db = {
          cidr_block = "10.1.2.0/24"
          dns_label  = "db"
        }
      }
    }
  }
}

variable "spoke_route_tables" {
  description = "Route tables applied to all spokes."
  type = map(object({
    display_name = optional(string)
    route_rules = optional(list(object({
      description        = optional(string)
      destination        = optional(string)
      destination_key    = optional(string)
      destination_type   = optional(string, "CIDR_BLOCK")
      network_entity_id  = optional(string)
      network_entity_key = optional(string)
    })), [])
  }))
  default = {
    private = {
      route_rules = [
        {
          description        = "Send non-local traffic to the hub DRG."
          destination        = "0.0.0.0/0"
          network_entity_key = "drg"
        },
        {
          description        = "Private OCI service access."
          destination_key    = "all-services"
          destination_type   = "SERVICE_CIDR_BLOCK"
          network_entity_key = "sgw"
        }
      ]
    }
  }
}

variable "spoke_security_lists" {
  description = "Security lists applied to all spokes."
  type = map(object({
    display_name = optional(string)
    ingress_rules = optional(list(object({
      description  = optional(string)
      protocol     = string
      source       = string
      source_type  = optional(string, "CIDR_BLOCK")
      stateless    = optional(bool, false)
      tcp_options  = optional(object({ min = number, max = number }))
      udp_options  = optional(object({ min = number, max = number }))
      icmp_options = optional(object({ type = number, code = optional(number) }))
    })), [])
    egress_rules = optional(list(object({
      description      = optional(string)
      protocol         = string
      destination      = string
      destination_type = optional(string, "CIDR_BLOCK")
      stateless        = optional(bool, false)
      tcp_options      = optional(object({ min = number, max = number }))
      udp_options      = optional(object({ min = number, max = number }))
      icmp_options     = optional(object({ type = number, code = optional(number) }))
    })), [])
  }))
  default = {
    baseline = {
      ingress_rules = []
      egress_rules = [
        {
          description = "Allow outbound traffic to hub and OCI services."
          protocol    = "all"
          destination = "0.0.0.0/0"
        }
      ]
    }
  }
}

variable "enable_fortigate_ha" {
  description = "Create the FortiGate active-passive HA pair."
  type        = bool
  default     = false
}

variable "fortigate_image_id" {
  description = "FortiGate marketplace or custom image OCID used by nodes that do not set image_id."
  type        = string
  default     = null
}

variable "fortigate_interface_subnet_keys" {
  description = "Hub subnet keys used by default for FortiGate interfaces."
  type = object({
    mgmt    = string
    untrust = string
    trust   = string
    ha_sync = string
  })
  default = {
    mgmt    = "mgmt"
    untrust = "dmz"
    trust   = "trust"
    ha_sync = "ha"
  }
}

variable "fortigate_nodes" {
  description = "FortiGate HA nodes keyed by logical name, normally active and standby."
  type = map(object({
    availability_domain = string
    display_name        = optional(string)
    image_id            = optional(string)
    shape               = optional(string, "VM.Standard.E4.Flex")
    ocpus               = optional(number, 4)
    memory_in_gbs       = optional(number, 16)
    bootstrap_user_data = optional(string)
    interfaces = optional(map(object({
      subnet_key             = optional(string)
      private_ip             = optional(string)
      hostname_label         = optional(string)
      assign_public_ip       = optional(bool, false)
      nsg_ids                = optional(list(string), [])
      skip_source_dest_check = optional(bool, true)
    })), {})
  }))
  default = {}

  validation {
    condition     = length(var.fortigate_nodes) == 0 || length(var.fortigate_nodes) == 2
    error_message = "fortigate_nodes must be empty or contain exactly two nodes for HA."
  }
}

variable "enable_fortigate_floating_ips" {
  description = "Create reserved private IPs for FortiGate HA failover and route-table next hops."
  type        = bool
  default     = false
}

variable "fortigate_floating_ips" {
  description = "Secondary or reserved private IPs keyed by purpose, such as untrust or trust route targets."
  type = map(object({
    subnet_key      = string
    active_node_key = optional(string)
    interface_name  = optional(string)
    ip_address      = optional(string)
    hostname_label  = optional(string)
    display_name    = optional(string)
  }))
  default = {}
}

variable "enable_fortigate_instance_principal_policy" {
  description = "Create a dynamic group and OCI policy for FortiGate HA private IP failover automation."
  type        = bool
  default     = false
}

variable "fortigate_dynamic_group_name" {
  description = "Optional dynamic group name override for FortiGate HA nodes."
  type        = string
  default     = null
}

variable "fortigate_policy_name" {
  description = "Optional IAM policy name override for FortiGate HA nodes."
  type        = string
  default     = null
}

variable "additional_fortigate_policy_statements" {
  description = "Additional policy statements appended to the default FortiGate HA instance-principal policy."
  type        = list(string)
  default     = []
}

variable "defined_tags" {
  description = "Defined tags applied to resources."
  type        = map(string)
  default     = {}
}

variable "freeform_tags" {
  description = "Freeform tags applied to resources."
  type        = map(string)
  default     = {}
}
