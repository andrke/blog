variable "create_master" {
  type    = bool
  default = false
}

variable "create_workers" {
  type    = bool
  default = false
}

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
  default = 0
}

variable "locust_image" {
  type    = string
  default = "locustio/locust"
}

variable "locust_params" {
  type    = string
  default = ""
}

variable "locust_master" {
  type    = string
  default = ""
}
