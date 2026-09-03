variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "equipment-sme-assistant"
}

variable "model_id" {
  description = "The model id of Amazon Bedrock"
  type = string
  default = "amazon.nova-pro-v1:0"
}

variable "email_address" {
  description = "Email address to send alarms to"
  type = string
  default = "fredyflemus@gmail.com"
}