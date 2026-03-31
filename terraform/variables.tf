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
