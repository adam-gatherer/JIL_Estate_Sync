# create S3 bucket
resource "aws_s3_bucket" "jil_exports" {
  bucket = local.jil_bucket_name

  force_destroy = true
}

# setup public access blocking
resource "aws_s3_bucket_public_access_block" "jil_exports" {
  bucket = aws_s3_bucket.jil_exports.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


# versioning
resource "aws_s3_bucket_versioning" "jil_exports" {
  bucket = aws_s3_bucket.jil_exports.id

  versioning_configuration {
    status = "Enabled"
  }
}


# lifecycle rules
resource "aws_s3_bucket_lifecycle_configuration" "jil_exports" {
  bucket = aws_s3_bucket.jil_exports.id

  rule {
    id     = "expire-old-jil"
    status = "Enabled"

    filter {
      prefix = ""
    }

    expiration {
      days = var.s3_lifecycle_days
    }
  }
}
