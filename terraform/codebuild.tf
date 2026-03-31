resource "aws_codebuild_project" "jil_sync" {
  name         = "jil-estate-sync"
  service_role = aws_iam_role.codebuild_role.arn

  source {
    type      = "NO_SOURCE"
    buildspec = file("${path.module}/../buildspec.yml")
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "BUCKET"
      value = local.jil_bucket_name
    }

    environment_variable {
      name  = "REPO_URL"
      value = var.repo_url
    }

    environment_variable {
      name  = "SECRET_ARN"
      value = var.github_pat_secret_arn
    }
  }

  artifacts {
    type = "NO_ARTIFACTS"
  }

  tags = {
    Name = "jil-codebuild"
  }
}
