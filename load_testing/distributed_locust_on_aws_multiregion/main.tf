
module "distributed_locust_master" {
  source = "./locust"

  providers = {
    aws = aws.eu-north-1
  }
  create_master        = true
  create_slaves        = false
  master_instance_type = "t3.micro"
  locust_image         = "entigoandrke/locust-tasks:latest"
  locust_params        = "-e '--web-auth kala:maja' -l https://raw.githubusercontent.com/andrke/blog/master/load_testing/locustfile-simple-index.py"
}

module "distributed_locust_slave_eu-north-1" {
  source = "./locust"

  providers = {
    aws = aws.eu-north-1
  }

  create_master       = false
  create_slaves       = true
  slave_instance_type = "t3.micro"
  slaves_per_region   = 3
  locust_image        = "entigoandrke/locust-tasks:latest"
  locust_params       = "-l https://raw.githubusercontent.com/andrke/blog/master/load_testing/locustfile-simple-index.py"
  locust_master       = module.distributed_locust_master.master_dns_name
}

module "distributed_locust_slave_eu-central-1" {
  source = "./locust"

  providers = {
    aws = aws.eu-central-1
  }

  create_master       = false
  create_slaves       = true
  slave_instance_type = "t3.micro"
  slaves_per_region   = 2
  locust_image        = "entigoandrke/locust-tasks:latest"
  locust_params       = "-l https://raw.githubusercontent.com/andrke/blog/master/load_testing/locustfile-simple-index.py"
  locust_master       = module.distributed_locust_master.master_dns_name
}

output "locust_master_url" {
  value = module.distributed_locust_master.master_url
}
