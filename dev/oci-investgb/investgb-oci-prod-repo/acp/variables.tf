variable "region" {
  description = "OCI region"
  type        = string
}


variable "compartment_id" {
  description = "The ID of the compartment in which to create the instance."
  type        = string
}

variable "availability_domain" {
  description = "The name of the availability domain in which to create the instance."
  type        = string
}
/*
variable "defined_tags" {
  description = "Defined tags for this resource."
  type        = map(string)

  validation {
    condition     = length(var.defined_tags) > 0 ? true : false
    error_message = "Defined Tags must not be empty. Please configure the needed tags."
  }
}

variable "freeform_tags" {
  description = "Free-form tags for this resource."
  type        = map(string)
  default     = {}
} */

variable "name" {
  description = "A user-friendly name."
  type        = string
}

variable "display_name" {
  description = "Display name"
  type        = string
}

variable "instance_config" {
  type = object({
    instance_shape       = string
    instance_image       = string
    memory               = string
    ocpus                = string
    boot_volume_size     = string
    instance_source_type = optional(string, "image")
  })
}

variable "subnet_id" {
  description = "The unique identifiers (OCID) of the subnet in which the instance primary VNICs are created."
  type        = string
}

variable "nsg_ids" {
  description = "Additional NSG ids to be attached to the instance"
  type        = list(string)
  default     = []
}

variable "baseline_ocpu_utilization" {
  description = "(Updatable) The baseline OCPU utilization for a subcore burstable VM instance"
  type        = string
  default     = null
}

variable "public_ip" {
  description = "Whether to create a Public IP to attach to primary vnic and which lifetime. Valid values are NONE, RESERVED or EPHEMERAL."
  type        = string
  default     = "NONE"

  validation {
    condition     = contains(["NONE", "RESERVED", "EPHEMERAL"], var.public_ip)
    error_message = "Accepted values are NONE, RESERVED or EPHEMERAL."
  }
}

variable "assign_public_ip" {
  #! Deprecation notice: will be removed at next major release. Use `var.public_ip` instead.
  description = "Deprecated: use `var.public_ip` instead. Whether the VNIC should be assigned a public IP address (Always EPHEMERAL)."
  type        = bool
  default     = false
}

variable "ssh_authorized_keys" {
  #! Deprecation notice: Please use `ssh_public_keys` instead
  description = "DEPRECATED: use ssh_public_keys instead. Public SSH keys path to be included in the ~/.ssh/authorized_keys file for the default user on the instance."
  type        = string
  default     = null
}

variable "ssh_public_keys" {
  description = "Public SSH keys to be included in the ~/.ssh/authorized_keys file for the default user on the instance. To provide multiple keys, see docs/instance_ssh_keys.adoc."
  type        = string
  default     = null
}

variable "user_data" {
  description = "Provide your own base64-encoded data to be used by Cloud-Init to run custom scripts or provide custom Cloud-Init configuration."
  type        = string
  default     = null
}


variable "cloud_agent_config" {
  description = "Whether enable or disable all Oracle Cloud Agent plugins"
  type = list(object({
    are_all_plugins_disabled = optional(bool)
    is_management_disabled   = optional(bool)
    is_monitoring_disabled   = optional(bool)
  }))
  default = []
}

variable "cloud_agent_plugins" {
  description = "Whether each Oracle Cloud Agent plugins should be ENABLED or DISABLED."
  type        = list(map(string))
  default     = []
}

variable "platform_config" {
  description = "The platform configuration requested for the instance."
  type = list(object({
    is_secure_boot_enabled             = optional(bool)
    is_trusted_platform_module_enabled = optional(bool)
    is_measured_boot_enabled           = optional(bool)
    type                               = optional(string, null)
  }))
  default = []
}

variable "instance_options" {
  description = "Mutable instance options"
  type = list(object({
    are_legacy_imds_endpoints_disabled = optional(bool)
  }))
  default = []
}

variable "kms_key_id" {
  description = "The OCID of the Vault service key to assign as the master encryption key for the boot volume."
  type        = string
  validation {
    condition     = length(var.kms_key_id) > 0 ? true : false
    error_message = "Boot Volumes must be encrypted with a KMS Key. Please provide a KMS Key OCID."
  }
}

variable "assign_private_dns_record" {
  type    = bool
  default = true
}
