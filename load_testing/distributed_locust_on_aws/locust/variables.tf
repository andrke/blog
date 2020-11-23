variable "master_region" {
  type    = string
  default = "eu-north-1"
}

variable "slave_region" {
  type    = string
  default = "eu-north-1"
}

variable "master_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "slave_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "slaves_per_region" {
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

