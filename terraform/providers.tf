# provider & tags
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      project     = "jil-estate-sync"
      owner       = "adam-gatherer"
      environment = "lab"
      managed_by  = "terraform"
    }
  }
}
