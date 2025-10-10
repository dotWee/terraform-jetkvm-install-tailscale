terraform {
  required_version = ">= 1.6.0, < 2.0.0"

  required_providers {
    null = {
      source  = "hashicorp/null"
      version = ">= 3.2.2, < 4.0.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.4.0, < 3.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.1, < 4.0.0"
    }
  }
}


