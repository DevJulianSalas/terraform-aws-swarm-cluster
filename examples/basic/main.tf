module "swarm" {
  source = "../../"
  iam_instance_profile = "iam_instance_profile"
  name        = "example"
  environment = "dev"
  instances = {}
}