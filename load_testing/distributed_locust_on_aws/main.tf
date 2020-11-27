
module "distributed_locust" {
  source = "./locust"

  master_instance_type = "t3.micro"
  worker_instance_type  = "t3.micro"
  workers_per_region    = 3
  locust_image         = "entigoandrke/locust-tasks:latest"
  locust_params        = "-l locustfile-tcp.py -t http://localhost"
}

output "locust_master_url" {
  value = module.distributed_locust.master_url
}

