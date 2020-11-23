
module "distributed_locust" {
  source = "./locust"

  master_region = "eu-north-1"
  #slave_region = "eu-north-1 eu-central-1 eu-west-1 eu-west-2 us-east-1 us-west-1"
  slave_region         = "eu-north-1"
  master_instance_type = "t3.micro"
  slave_instance_type  = "t3.micro"
  slaves_per_region    = 3
  locust_image         = "entigoandrke/locust-tasks:latest"
  locust_params        = "-e '--web-auth kala:maja' -l https://raw.githubusercontent.com/andrke/blog/master/load_testing/locustfile-simple-index.py"
}

output "locust_master_url" {
  value = module.distributed_locust.master_url
}

