# random 
resource "random_id" "suffix" {
  byte_length = 3
}

locals {
  jil_bucket_name = "jil-estate-sync-${random_id.suffix.hex}"
}
