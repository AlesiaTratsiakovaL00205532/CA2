provider "aws" {
  region = var.region
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_vpc" "workload" {
  cidr_block = "10.20.0.0/16"
}

resource "aws_subnet" "workload" {
  vpc_id                          = aws_vpc.workload.id
  cidr_block                      = "10.20.1.0/24"
  map_public_ip_on_launch         = false
  assign_ipv6_address_on_creation = false
}

resource "aws_security_group" "workload" {
  name_prefix = "sentinel-workload-"
  description = "Private workload with no inbound access"
  vpc_id      = aws_vpc.workload.id
  ingress     = []
  egress      = []
}

resource "aws_instance" "ubuntu" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.workload.id
  vpc_security_group_ids      = [aws_security_group.workload.id]
  associate_public_ip_address = false
  ipv6_address_count          = 0

  root_block_device {
    encrypted = true
  }

  metadata_options {
    http_tokens = "required"
  }

  tags = {
    Name = var.instance_name
  }
}