# github repo
variable "repo_url" {
  description = "GitHub repository URL"
  type        = string
}


# github PAT arn
variable "github_pat_secret_arn" {
  description = "Secrets Manager ARN for GitHub PAT"
  type        = string
}


# aws region
variable "aws_region" {
  description = "AWS region"
  type        = string
}


# project name
variable "project_name" {
  description = "Project name prefix"
  type        = string
}


# S3 lifecycle
variable "s3_lifecycle_days" {
  description = "Days before JIL files expire"
  type        = number
}



# reviewers for PR
variable "reviewers" {
  description = "Comma-separated GitHub reviewers"
  type        = string
  default     = ""
}
