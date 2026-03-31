#!/bin/bash
set -e


# Retrieves the GitHub Personal Access Token stored securely in AWS Secrets Manager
PAT=$(aws secretsmanager get-secret-value \
  --secret-id $SECRET_ARN \
  --query SecretString \
  --output text | jq -r .AJG_GITHUB_TOKEN)



# Pulls all .jil files from the S3 bucket into a local directory
mkdir -p jil_files
aws s3 cp s3://$BUCKET/jil_files/ jil_files/ --recursive --exclude "*" --include "*.jil"


# Creates a uniquely named branch using a timestamp
BRANCH="jil-update-$(date +%s)"
git checkout -b $BRANCH


# Sets bot identity for commit attribution
git config user.name "ajg-bot"
git config user.email "bot@local"


# Stages files and exits early if nothing has changed
git add jil_files/*.jil

if git diff --cached --quiet; then
  echo "No changes detected, exiting"
  exit 0
fi


# Commits updated JIL files
git commit -m "Automated JIL update"


# Pushes the new branch to the remote repository
git push origin $BRANCH


git fetch origin master:master || true

# Opens a PR from the new branch into master using GitHub API
REPO_PATH=${REPO_URL#https://github.com/}
REPO_PATH=${REPO_PATH%.git}

PR_RESPONSE=$(curl -s -X POST https://api.github.com/repos/$REPO_PATH/pulls \
  -H "Authorization: token $PAT" \
  -H "Accept: application/vnd.github+json" \
  -d "{
    \"title\": \"Automated JIL update\",
    \"head\": \"$BRANCH\",
    \"base\": \"master\"
  }")

PR_NUMBER=$(echo $PR_RESPONSE | jq -r .number)


# Ensures PR was successfully created before continuing
if [ "$PR_NUMBER" = "null" ]; then
  echo "PR creation failed"
  echo "$PR_RESPONSE"
  exit 1
fi


# Adds reviewers to the PR if REVIEWERS variable is set
if [ -n "$REVIEWERS" ]; then
  IFS=',' read -ra REVIEWER_ARRAY <<< "$REVIEWERS"

  JSON_REVIEWERS=$(printf '"%s",' "${REVIEWER_ARRAY[@]}")
  JSON_REVIEWERS="[${JSON_REVIEWERS%,}]"

  curl -s -X POST https://api.github.com/repos/$REPO_PATH/pulls/$PR_NUMBER/requested_reviewers \
    -H "Authorization: token $PAT" \
    -H "Accept: application/vnd.github+json" \
    -d "{
      \"reviewers\": $JSON_REVIEWERS
    }"
fi

# COMPLETE
echo "PR #$PR_NUMBER created successfully"