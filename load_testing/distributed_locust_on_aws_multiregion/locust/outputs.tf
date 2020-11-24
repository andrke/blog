output "master_dns_name" {
  value = var.create_master ? module.locust_master.public_dns[0] : ""
}

output "master_url" {
  value = var.create_master ? "http://${module.locust_master.public_dns[0]}:8089/" : ""
}
