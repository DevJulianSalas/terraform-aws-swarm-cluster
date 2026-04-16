output "instance_ids" {
  description = "Map of instance IDs"
  value = {
    for k, v in aws_instance.this :
    k => v.id
  }
}
output "private_ips" {
  description = "Map of private IPs used for swarm communication"
  value = {
    for k, v in aws_instance.this :
    k => v.private_ip
  }
}

output "instance_manager_ids" {
  description = "Map of instance manager IDs filter by manager tag to associate as the manager role in the Docker Swarm"
  value = {
    for k, v in aws_instance.this :
    k => v.id
    if try(v.tags["Role"], "") == "manager"
  }
}