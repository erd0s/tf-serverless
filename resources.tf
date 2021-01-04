provider "aws" {
  region = "eu-west-2"
}

module "functions" {
  for_each = {for func in var.functions: func.handler => func}

  source = "./function"
  api_exec_arn = aws_apigatewayv2_api.api.execution_arn
  api_id = aws_apigatewayv2_api.api.id
  func_handler = each.value.handler
  func_name = each.value.name
  method = each.value.method
  path = each.value.path
  output_path = data.archive_file.payload.output_path
  env_vars = each.value.env_vars
}

data "archive_file" "payload" {
  output_path = "payload.zip"
  source_dir = var.source_dir
  type = "zip"
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_apigatewayv2_api" "api" {
  name = var.microservice_name
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "stage" {
  api_id = aws_apigatewayv2_api.api.id
  name = "$default"
  auto_deploy = true
}

output "zip_path" {
  value = data.archive_file.payload.output_path
}

output "api_url" {
  value = aws_apigatewayv2_api.api.api_endpoint
}