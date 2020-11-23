output "master_dns_name" {
  value = module.locust_master.public_dns[0]
}

output "master_url" {
  value = "http://${module.locust_master.public_dns[0]}:8089/"
}
