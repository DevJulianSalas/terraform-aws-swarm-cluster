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