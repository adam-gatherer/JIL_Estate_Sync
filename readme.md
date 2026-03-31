## 1. Overview

This project implements an AWS-native, event-driven pipeline to automate the publishing of Autosys JIL exports to GitHub, removing manual intervention and improving auditability.

Autosys is simulated exporting JIL files as normal and uploads them to S3. This triggers a CodeBuild job which commits the files to a GitHub repository via a secure, decoupled workflow.

All infrastructure and runtime configuration is defined via Terraform, with key deployment variables (e.g. repository URL, AWS region, secrets, reviewers) managed through `terraform.tfvars` to enable environment-specific customisation without code changes.


## 2. Problem Statement

Autosys JIL exports are currently committed to GitHub manually, creating:

* Operational overhead and inefficiency
* Risk of human error and missed updates
* Lack of real-time visibility into scheduler state

This project eliminates the manual step by introducing a secure, automated pipeline using AWS managed services, aligning with cloud migration and improving reliability, traceability, and consistency.

## 3. Architecture

Autosys (EC2) uploads JIL files to S3, which acts as a landing zone.
An event trigger (EventBridge monitoring S3) starts a CodeBuild job.
CodeBuild retrieves the files, creates a branch, and raises a PR in GitHub.


```mermaid
flowchart TD
    A[Autosys EC2\n(JIL Export)] --> B[S3 Bucket\n(jil_files/)]
    B --> C[EventBridge Trigger]
    C --> D[CodeBuild Project]
    D --> E[Clone GitHub Repo]
    D --> F[Commit & Push Branch]
    F --> G[Create Pull Request]
    G --> H[GitHub Repository]
```

## 4. How It Works

1. Autosys generates JIL export files (simulated in EC2)
2. EC2 uploads files to S3 (`jil_files/` prefix)
3. S3 event triggers EventBridge rule
4. EventBridge starts CodeBuild job
5. CodeBuild:

   * Pulls JIL files from S3
   * Clones GitHub repo
   * Creates new branch
   * Commits changes (if any)
   * Pushes branch
   * Opens Pull Request
6. Optional reviewers are automatically added (configured via Terraform)
7. Repo reflects latest scheduler state via PR workflow

## 5. Tech Stack

* AWS S3 (file landing zone)
* AWS EventBridge (event trigger)
* AWS CodeBuild (automation layer)
* AWS IAM (access control)
* AWS Secrets Manager (GitHub PAT storage)
* EC2 (Autosys host simulation)
* GitHub (target repository)
* Terraform (infrastructure as code)
* Bash (automation scripting)

---

## 6. Repository Structure

```text
.
├── buildspec.yml
├── scripts/
│   └── sync_jil_to_github.sh
├── jil_files/
│   ├── TEST.jil
│   ├── PPE.jil
│   └── PROD.jil
├── terraform/
│   ├── main.tf
│   ├── s3.tf
│   ├── iam.tf
│   ├── ec2.tf
│   ├── codebuild.tf
│   ├── eventbridge.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars
```

## 7. Setup / Deployment (Terraform)

**Prerequisites**

* AWS account + credentials configured
* Terraform installed

**Steps**

1. Configure `terraform.tfvars` with environment-specific values:

   * `aws_region` (deployment region)
   * `project_name` (resource naming prefix)
   * `repo_url` (target GitHub repository)
   * `github_pat_secret_arn` (Secrets Manager ARN for GitHub token)
   * `reviewers` (optional, comma-separated GitHub usernames)
   * `s3_lifecycle_days` (optional retention policy)

2. Navigate to terraform directory

3. Initialise Terraform

4. Apply infrastructure

Example:

```
cd terraform
terraform init
terraform apply
```

**What gets created**

* S3 bucket (JIL storage)
* EC2 instance (Autosys simulation)
* IAM roles/policies (least privilege)
* CodeBuild project
* EventBridge trigger
* Secrets Manager secret (GitHub PAT reference)

## 8. Example Output (PR + JIL files)

**Example JIL (PROD.jil)**

```
/* Generated at: 2026-01-01 10:00:00 */
insert_job: P01_TEST_JOB
job_type: CMD
command: echo hello
machine: localhost
```

**Example PR**

* Title: `Automated JIL update`
* Branch: `jil-update-<timestamp>`
* Changes: Updated `.jil` files under `jil_files/`
* Reviewers: Auto-assigned (if configured via tfvars)

This results in a consistent, auditable history of scheduler state via GitHub pull requests.

## 9. Security Considerations

* **No credentials on EC2** - uses IAM role for S3 access
* **Secrets Manager** - stores GitHub PAT securely
* **Least privilege IAM** - scoped access per service
* **No direct EC2 -> GitHub access** - fully decoupled via AWS
* **Private S3 bucket** - public access blocked
* **Auditability** - all changes tracked via GitHub PRs

## 10. Limitations / Future Improvements

* **Single repo target** - extend to multi-repo / multi-branch support
* **Basic change detection** - could improve diff visibility or notifications
* **No validation of JIL content** - add linting or schema checks
* **No retry/alerting mechanism** - integrate CloudWatch alarms / SNS
* **Scalability considerations** - optimise for very large JIL estates
* **PR auto-merge option** - optional workflow for fully hands-off updates
