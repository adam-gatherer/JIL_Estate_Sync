# random 
resource "random_id" "suffix" {
  byte_length = 3
}

locals {
  jil_bucket_name = "${var.project_name}-${random_id.suffix.hex}"
}
