# provider
provider "aws" {
  region = "eu-west-2"

  default_tags {
    tags = {
      project = "jil-estate-sync"
    }
  }
}
