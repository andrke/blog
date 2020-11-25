
variable "master_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "worker_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "workers_per_region" {
  type    = number
  default = 1
}

variable "locust_image" {
  type    = string
  default = "locustio/locust"
}

variable "locust_params" {
  type    = string
  default = ""
}

