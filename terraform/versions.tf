terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "= 3.0.1"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "= 6.72.0"
    }
  }

  required_version = ">= 0.15"

  backend "remote" {
    organization = "Alesia1"

    workspaces {
      name = "CA2"
    }
  }

}