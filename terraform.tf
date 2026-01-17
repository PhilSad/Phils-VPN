

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.28.0"
    }

    wireguard = {
      source = "OJFord/wireguard"
      version = "0.4.0"
    }
  }
}