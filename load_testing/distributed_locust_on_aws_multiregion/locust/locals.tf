locals {

  user_data_master = base64encode(templatefile("${path.module}/user_data_master.tpl", {
    name   = "Master"
    image  = var.locust_image
    params = "-m master ${var.locust_params}"
  }))
  user_data_worker = base64encode(templatefile("${path.module}/user_data_worker.tpl", {
    name   = "worker"
    image  = var.locust_image
    params = "-m worker -M ${var.locust_master} ${var.locust_params}"
  }))

  management_key_name = "management-key-${random_uuid.suffix.result}"
}

resource "local_file" "user_data_master_debug" {
  content = templatefile("${path.module}/user_data_master.tpl", {
    name   = "Master"
    image  = var.locust_image
    params = "-m master ${var.locust_params}"
  })
  filename = "${path.module}/user_data_master.rendered"
}

resource "local_file" "user_data_worker_debug" {
  content = templatefile("${path.module}/user_data_worker.tpl", {
    name   = "worker"
    image  = var.locust_image
    params = "-m worker -M ${var.locust_master} ${var.locust_params}"
  })
  filename = "${path.module}/user_data_worker.rendered"
}

