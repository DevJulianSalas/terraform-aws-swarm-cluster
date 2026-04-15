locals {
  name_prefix = join("-", compact([
    var.tenant,
    var.environment,
    var.name
  ]))
}
resource "aws_instance" "this" {
  for_each               = var.instances
  ami                    = each.value.ami_id
  instance_type          = each.value.instance_type
  subnet_id              = each.value.subnet_id
  iam_instance_profile   = lookup(each.value, "iam_instance_profile", null)
  user_data              = lookup(each.value, "user_data", null)
  user_data_base64       = lookup(each.value, "user_data_base64", null)
  vpc_security_group_ids = each.value.security_group_ids

  dynamic "root_block_device" {
    for_each = lookup(each.value, "root_block_device", null) != null ? [each.value.root_block_device] : []
    content {
      volume_size           = root_block_device.value.volume_size
      volume_type           = root_block_device.value.volume_type
      delete_on_termination = lookup(root_block_device.value, "delete_on_termination", true)
    }
  }
  dynamic "metadata_options" {
    for_each = lookup(each.value, "metadata_options", null) != null ? each.value.metadata_options : {}
    content {
      http_endpoint          = lookup(metadata_options.value, "http_endpoint", "enabled")
      http_tokens            = lookup(metadata_options.value, "http_tokens", "optional")
      instance_metadata_tags = lookup(metadata_options.value, "instance_metadata_tags", "disabled")
    }
  }

  tags = merge(
    {
      Name        = coalesce(lookup(each.value, "name", null), "${local.name_prefix}-${each.key}")
      Environment = var.environment
      Tenant      = var.tenant
      Role        = lookup(each.value, "role", "node")
    },
    var.tags,
    lookup(each.value, "tags", {})
  )
}