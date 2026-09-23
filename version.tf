terraform {
  required_version = ">= 1.1.0"

  required_providers {
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">=4.8.0"
    }
  }
}
