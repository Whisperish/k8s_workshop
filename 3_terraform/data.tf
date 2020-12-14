# Fetch k8s base Centos 8 Machine and North South Router AMI identifiers

data "aws_ami" "k8s-base-machine" {
  most_recent = true
  owners      = ["self"]
  filter {
    name = "tag:Name"
    values = [
      "workshop0001.k8s-base-machine",
    ]
  }
}

data "aws_ami" "north-south-router" {
  most_recent = true
  owners      = ["self"]
  filter {
    name = "tag:Name"
    values = [
      "workshop0001.north-south-router",
    ]
  }
}

# Locate the correct zone from Route53

data "aws_route53_zone" "selected" {
  name         = "nginxdemo.net"
  private_zone = false
}

data "local_file" "foo" {
    filename = "k8s-key.pem"
}