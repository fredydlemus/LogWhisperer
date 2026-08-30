output "lambda_function_name" {
  value = aws_lambda_function.function.function_name
}

output "lambda_function_arn" {
  value = aws_lambda_function.function.arn
}

output "api_endpoint" {
  description = "Base invoke URL for the REST API stage"
  value = aws_api_gateway_stage.this.invoke_url
}

output "rest_api_id" {
  value = aws_api_gateway_rest_api.this.id
}