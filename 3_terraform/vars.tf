variable "region" {
  default = "eu-west-2"
}

provider "aws" {
  profile    = "664341837355_Users"
  region     = var.region
}

