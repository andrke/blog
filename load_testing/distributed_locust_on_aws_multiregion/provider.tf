provider "aws" {
  region      = "eu-north-1"
  max_retries = 2
}

provider "aws" {
  region      = "eu-north-1"
  alias       = "eu-north-1"
  max_retries = 2
}

provider "aws" {
  region      = "eu-central-1"
  alias       = "eu-central-1"
  max_retries = 2
}

provider "aws" {
  region      = "eu-west-1"
  alias       = "eu-west-1"
  max_retries = 2
}

provider "aws" {
  region      = "eu-west-2"
  alias       = "eu-west-2"
  max_retries = 2
}

provider "aws" {
  region      = "us-east-1"
  alias       = "us-east-1"
  max_retries = 2
}

