variable "name" {
  description = "Base name for resources"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}

variable "tenant" {
  description = "Tenant or project identifier"
  type        = string
  default     = null
}

variable "tags" {
  description = "Map of tags to assign to resources"
  type        = map(string)
  default     = {}
}

variable "instances" {
  description = "EC2 instances to create (used for swarm cluster definition)"

  type = map(object({
    ami_id             = string
    instance_type      = string
    subnet_id          = string
    security_group_ids = list(string)

    role = optional(string) # manager | worker

    key_name                = optional(string)
    associate_public_ip     = optional(bool)
    iam_instance_profile    = optional(string)
    user_data               = optional(string)
    user_data_base64        = optional(string)
    enable_monitoring       = optional(bool)
    ebs_optimized           = optional(bool)

    root_block_device = optional(object({
      volume_size = number
      volume_type = string
      delete_on_termination = optional(bool)
    }))
    metadata_options = optional(object({
      http_endpoint = optional(string)
      http_tokens   = optional(string)
      instance_metadata_tags = optional(string)
    }))
    tags = optional(map(string))
  }))
}