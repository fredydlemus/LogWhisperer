resource "aws_sns_topic" "bedrock_alarms" {
  name = "equipment_sme_assistant"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.bedrock_alarms.arn
  protocol = "email"
  endpoint = var.email_address
}