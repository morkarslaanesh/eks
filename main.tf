# Terraform for the DCOS Messosphere

provider "aws" {
  # Change your default region here
  region = "us-east-1"
}

# Used to determine your public IP for forwarding rules
data "http" "whatismyip" {
  url = "http://whatismyip.akamai.com/"
}

module "dcos" {
  source  = "dcos-terraform/dcos/aws"
  version = "~> 0.2.0"

  providers = {
    aws = "aws"
  }

  cluster_name        = "my-dcos-demo"
  ssh_public_key_file = "<path-to-public-key-file>"
  admin_ips           = ["${data.http.whatismyip.body}/32"]

  num_masters        = 3
  num_private_agents = 2
  num_public_agents  = 1

  dcos_version = "1.13.3"

  # dcos_variant              = "ee"
  # dcos_license_key_contents = "${file("./license.txt")}"
  # Make sure to set your credentials if you do not want the default EE
  # dcos_superuser_username      = "superuser-name"
  # dcos_superuser_password_hash = "${file("./dcos_superuser_password_hash.sha512")}"
  dcos_variant = "open"

  dcos_instance_os             = "centos_7.5"
  bootstrap_instance_type      = "t2.medium"
  masters_instance_type        = "t2.medium"
  private_agents_instance_type = "t2.medium"
  public_agents_instance_type  = "t2.medium"
}

output "masters-ips" {
  value = "${module.dcos.masters-ips}"
}

output "cluster-address" {
  value = "${module.dcos.masters-loadbalancer}"
}

output "public-agents-loadbalancer" {
  value = "${module.dcos.public-agents-loadbalancer}"
}