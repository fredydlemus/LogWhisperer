resource "aws_api_gateway_rest_api" "this" {
  name = "${var.function_name}-rest-api"
  description = "REST API backed by ${var.function_name} Lambda"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "resource" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id = aws_api_gateway_rest_api.this.root_resource_id
  path_part = "sme_assistant"
}

resource "aws_api_gateway_method" "method" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.resource.id
  http_method = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.resource.id
  http_method = "POST"
  integration_http_method = "POST"
  type = "AWS"
  uri = aws_lambda_function.function.invoke_arn

  passthrough_behavior = "WHEN_NO_TEMPLATES"

  request_templates = {
    "application/json" = <<EOF
    {"prompt": $input.json('$.prompt')}
    EOF
  }
}

resource "aws_api_gateway_method_response" "response_method" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.resource.id
  http_method = aws_api_gateway_method.method.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.resource.id
  http_method = aws_api_gateway_method.method.http_method
  status_code = aws_api_gateway_method_response.response_method.status_code

  depends_on = [ aws_api_gateway_integration.integration ]
}

resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.this.id

  triggers = {
    redeployment = sha1(jsonencode([
        aws_api_gateway_resource.resource.id,
        aws_api_gateway_method.method.id,
        aws_api_gateway_integration.integration.id,
        aws_api_gateway_method_response.response_method.id,
        aws_api_gateway_integration_response.response_200.id
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [ aws_api_gateway_integration.integration, aws_api_gateway_integration_response.response_200]
}

resource "aws_api_gateway_stage" "this" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id = aws_api_gateway_rest_api.this.id
  stage_name = "Production"
}

resource "aws_lambda_permission" "apigw" {
  statement_id = "AllowAPIGatewayInvoke"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.function.function_name
  principal = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.this.execution_arn}/*/${aws_api_gateway_method.method.http_method}/sme_assistant"
}