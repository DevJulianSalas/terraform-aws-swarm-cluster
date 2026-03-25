# terraform-aws-ec2-swarm

Terraform module to create EC2 instances for a Docker Swarm cluster.

---

## Usage

```
module "swarm_ec2" {
  source = "your-org/ec2-swarm/aws"

  name        = "swarm"
  environment = "prod"
  tenant      = "acme"

  create_iam_instance_profile = true

  instances = {
    manager-1 = {
      ami_id             = "ami-123456"
      instance_type      = "t3.medium"
      subnet_id          = "subnet-abc"
      security_group_ids = ["sg-123"]

      role = "manager"
    }

    worker-1 = {
      ami_id             = "ami-123456"
      instance_type      = "t3.medium"
      subnet_id          = "subnet-def"
      security_group_ids = ["sg-123"]

      role = "worker"
    }
  }
}
```

## Inputs
Required
| Name          | Description                      | Type          |
| ------------- | -------------------------------- | ------------- |
| `name`        | Base name for resources          | `string`      |
| `environment` | Environment (dev, staging, prod) | `string`      |
| `instances`   | Map of EC2 instances             | `map(object)` |

Optional

| Name                          | Description                  | Type          | Default |
| ----------------------------- | ---------------------------- | ------------- | ------- |
| `tenant`                      | Tenant or project identifier | `string`      | `null`  |
| `tags`                        | Global tags                  | `map(string)` | `{}`    |
| `create_iam_instance_profile` | Enable SSM access            | `bool`        | `false` |


### Instances Structure
```hcl
instances = {
  node-name = {
    ami_id             = string
    instance_type      = string
    subnet_id          = string
    security_group_ids = list(string)

    role = optional(string) # manager | worker

    key_name             = optional(string)
    iam_instance_profile = optional(string)

    associate_public_ip = optional(bool)

    user_data        = optional(string)
    user_data_base64 = optional(string)

    enable_monitoring = optional(bool)
    ebs_optimized     = optional(bool)

    root_block_device = optional(object({
      volume_size = number
      volume_type = string
      delete_on_termination = optional(bool, true)
    }))

    tags = optional(map(string))
  }
}
```
### Outputs

| Name                  | Description                  |
| --------------------- | ---------------------------- |
| `instance_ids`        | Map of EC2 instance IDs      |
| `private_ips`         | Map of private IPs           |
| `public_ips`          | Map of public IPs            |


### Notes
- This module creates EC2 instances only.
- Docker Swarm bootstrap must be handled via user_data or external tooling.
- Security groups must allow:
  - TCP 2377
  - TCP/UDP 7946
  - UDP 4789

### Licence
MIT