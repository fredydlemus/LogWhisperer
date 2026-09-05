data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_cloudwatch_log_group" "bedrock_logs" {
  name              = "/aws/bedrock/log-whisperer-logs"
  retention_in_days = 14
}

resource "aws_iam_role" "bedrock_logging_role" {
  name = "log-whisperer"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "bedrock.amazonaws.com"
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
          ArnLike = {
            "aws:SourceArn" = "arn:aws:bedrock:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:*"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "bedrock_logging_policy" {
  name = "bedrock-logging-policy"
  role = aws_iam_role.bedrock_logging_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ]
        Resource = "${aws_cloudwatch_log_group.bedrock_logs.arn}:*"
      }
    ]
  })
}

resource "aws_bedrock_model_invocation_logging_configuration" "this" {
  logging_config {
    embedding_data_delivery_enabled = true
    image_data_delivery_enabled     = true
    text_data_delivery_enabled      = true


    cloudwatch_config {
      log_group_name = aws_cloudwatch_log_group.bedrock_logs.name
      role_arn       = aws_iam_role.bedrock_logging_role.arn
    }
  }

  depends_on = [aws_iam_role_policy.bedrock_logging_policy]
}

resource "aws_cloudwatch_metric_alarm" "bedrock_client_errors" {
  alarm_name        = "InvocationClientErrors"
  alarm_description = "Bedrock returned 5+ client errors in a 5-minute window"

  namespace   = "AWS/Bedrock"
  metric_name = "InvocationClientErrors"
  statistic   = "Sum"
  period      = 300

  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = 5
  evaluation_periods  = 1

  treat_missing_data = "notBreaching"

  alarm_actions = [aws_sns_topic.bedrock_alarms.arn]

  dimensions = {
    ModelId = var.model_id
  }
}