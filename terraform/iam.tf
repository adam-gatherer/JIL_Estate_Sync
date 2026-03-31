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


# IAM role for codebuild
resource "aws_iam_role" "codebuild_role" {
  name = "jil-codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "codebuild.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}


# codebuild policy to read bucket, get secrets
resource "aws_iam_policy" "codebuild_policy" {
  name = "jil-codebuild-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::${local.jil_bucket_name}/*"
      },
      {
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:secretsmanager:eu-west-2:278245794072:secret:jil-estate-sync/github-pat*"
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}


# attach policy to codebuild role
resource "aws_iam_role_policy_attachment" "codebuild_attach" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_policy.arn
}
