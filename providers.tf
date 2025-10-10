# Backend is local by default; see README for remote backend examples
terraform {
  backend "local" {}
}

provider "null" {}
provider "local" {}
provider "random" {}


