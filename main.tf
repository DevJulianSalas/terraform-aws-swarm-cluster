locals {
  name_prefix = join("-", compact([
    var.tenant,
    var.environment,
    var.name
  ]))
}
resource "aws_iam_role" "ssm" {
  count = var.create_iam_instance_profile ? 1 : 0

  name = "${local.name_prefix}-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  count = var.create_iam_instance_profile ? 1 : 0

  role       = aws_iam_role.ssm[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm" {
  count = var.create_iam_instance_profile ? 1 : 0

  name = "${local.name_prefix}-ssm-profile"
  role = aws_iam_role.ssm[0].name
}
resource "aws_instance" "this" {
  for_each             = var.instances
  ami                  = each.value.ami_id
  instance_type        = each.value.instance_type
  subnet_id            = each.value.subnet_id
  iam_instance_profile = var.create_iam_instance_profile ? aws_iam_instance_profile.ssm[0].name : lookup(each.value, "iam_instance_profile", null)
  user_data            = lookup(each.value, "user_data", null)
  user_data_base64     = lookup(each.value, "user_data_base64", null)

  dynamic "root_block_device" {
    for_each = lookup(each.value, "root_block_device", null) != null ? [each.value.root_block_device] : []
    content {
      volume_size           = root_block_device.value.volume_size
      volume_type           = root_block_device.value.volume_type
      delete_on_termination = lookup(root_block_device.value, "delete_on_termination", true)
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