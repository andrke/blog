##################################################################
# Data sources to get VPC, subnet, security group and AMI details
##################################################################
data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.default.id
}

data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name = "name"

    values = [
      "amzn-ami-hvm-*-x86_64-gp2",
    ]
  }

  filter {
    name = "owner-alias"

    values = [
      "amazon",
    ]
  }
}

module "security_group_master" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "locust master"
  description = "Security group for locust master instance"
  vpc_id      = data.aws_vpc.default.id

  ingress_cidr_blocks = ["185.46.20.32/28"]
  ingress_rules       = ["ssh-tcp", "all-icmp"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 5557
      to_port     = 5559
      protocol    = "tcp"
      description = "locust worker connections"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 8089
      to_port     = 8089
      protocol    = "tcp"
      description = "locust master web UI"
      cidr_blocks = "185.46.20.32/28"
    }
  ]
  egress_rules = ["all-all"]
}

module "security_group_worker" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "locust worker"
  description = "Security group for Locust worker instances"
  vpc_id      = data.aws_vpc.default.id

  ingress_cidr_blocks = ["185.46.20.32/28"]
  ingress_rules       = ["ssh-tcp", "all-icmp"]
  egress_rules        = ["all-all"]
}

resource "aws_key_pair" "managementhost" {
  key_name   = "management-key"
  public_key = file("${path.module}/management-key.pub")
}

module "locust_master" {
  source                      = "terraform-aws-modules/ec2-instance/aws"
  version                     = "~> 2.0"
  instance_type               = var.master_instance_type
  ami                         = data.aws_ami.amazon_linux.id
  name                        = "master"
  key_name                    = "management-key"
  associate_public_ip_address = true
  subnet_id                   = tolist(data.aws_subnet_ids.all.ids)[0]
  vpc_security_group_ids      = [module.security_group_master.this_security_group_id]
  user_data_base64            = base64encode(local.user_data_master)
}

module "locust_workers" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 2.0"

  instance_count = var.workers_per_region

  instance_type               = var.worker_instance_type
  ami                         = data.aws_ami.amazon_linux.id
  name                        = "worker"
  key_name                    = "management-key"
  associate_public_ip_address = true
  subnet_id                   = tolist(data.aws_subnet_ids.all.ids)[0]
  vpc_security_group_ids      = [module.security_group_worker.this_security_group_id]
  user_data_base64            = base64encode(local.user_data_worker)
}

