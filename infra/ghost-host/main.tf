## -------------------------------------------------------------------------------------------------------------------
## GHOST-HOST
## -------------------------------------------------------------------------------------------------------------------
## -------------------------------------------------------------------------------------------------------------------

## -------------------------------------------------------------------------------------------------------------------
## Terraform settings & provider configurations
## -------------------------------------------------------------------------------------------------------------------
##
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 4.20.1"
    }
  }
}

provider "aws" {
  alias  = "ghost_host"
}

## -------------------------------------------------------------------------------------------------------------------
## Ghost Host deployment
## -------------------------------------------------------------------------------------------------------------------
## Use module for creating the network infrastructure
## -------------------------------------------------------------------------------------------------------------------
##
## TODO
