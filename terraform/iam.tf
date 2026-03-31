# IAM role for EC2s
resource "aws_iam_role" "ec2_role" {
  name = "jil-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}


# policy to allow write to bucket
resource "aws_iam_policy" "ec2_s3_policy" {
  name = "jil-ec2-s3-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "s3:PutObject"
      ]
      Effect   = "Allow"
      Resource = "arn:aws:s3:::${local.jil_bucket_name}/*"
    }]
  })
}


# attach policy to EC2 role
resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_s3_policy.arn
}


# enable SSM
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


# instance profile to attach IAM role to EC2
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "jil-ec2-profile"
  role = aws_iam_role.ec2_role.name
}
