# provider
provider "aws" {
  region = "eu-west-2"

  default_tags {
    tags = {
      project = "jil-estate-sync"
    }
  }
}


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
      Resource = "*"
    }]
  })
}


# attach policy to EC2 role
resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_s3_policy.arn
}


# instance profile to attach IAM role to EC2
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "jil-ec2-profile"
  role = aws_iam_role.ec2_role.name
}


# EC2 instance
resource "aws_instance" "jil_ec2" {
  ami           = "ami-0c76bd4bd302b30ec" # Amazon Linux 2023 (eu-west-2)
  instance_type = "t3.micro"

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  associate_public_ip_address = true

  tags = {
    Name = "jil-ec2"
  }
}


# enable SSM
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}