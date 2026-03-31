# output EC2 public IP
output "ec2_public_ip" {
  value = aws_instance.jil_ec2.public_ip
}


# output bucket name
output "jil_bucket_name" {
  value = aws_s3_bucket.jil_exports.bucket
}


# output codebuild
output "codebuild_project_name" {
  value = aws_codebuild_project.jil_sync.name
}
