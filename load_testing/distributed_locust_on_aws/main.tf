
module "distributed_locust" {
  source = "./locust"

  master_instance_type = "t3.micro"
  worker_instance_type  = "t3.micro"
  workers_per_region    = 3
  locust_image         = "entigoandrke/locust-tasks:latest"
  locust_params        = "-e '--web-auth kala:maja' -l https://raw.githubusercontent.com/andrke/blog/master/load_testing/locustfile-simple-index.py"
}

output "locust_master_url" {
  value = module.distributed_locust.master_url
}

