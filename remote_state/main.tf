locals {
  aws_region    = "ap-southeast-2"
  random_string = "rnhvgvat"
  prefix        = "demo-eks-terraform-remote-state-${local.random_string}"
  ssm_prefix    = "/org/demo-eks/terraform"
  common_tags = {
    Project   = "demo-eks"
    ManagedBy = "Terraform"
  }
}
