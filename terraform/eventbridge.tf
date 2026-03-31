# eventbridge to trigger codebuild
resource "aws_cloudwatch_event_rule" "s3_jil_upload" {
  name = "jil-s3-upload-trigger"

  event_pattern = jsonencode({
    source      = ["aws.s3"],
    detail-type = ["Object Created"],
    detail = {
      bucket = {
        name = [local.jil_bucket_name]
      },
      object = {
        key = [{
          suffix = ".jil"
        }]
      }
    }
  })

}


# eventbridge target
resource "aws_cloudwatch_event_target" "codebuild_target" {
  rule      = aws_cloudwatch_event_rule.s3_jil_upload.name
  target_id = "codebuild"
  arn       = aws_codebuild_project.jil_sync.arn
  role_arn  = aws_iam_role.eventbridge_role.arn
}
