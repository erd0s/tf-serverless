variable "api_id" {}
variable "method" {}
variable "path" {}
variable "api_exec_arn" {}
variable "func_name" {}
variable "func_handler" {}
variable "output_path" {}

resource "aws_apigatewayv2_integration" "integration" {
  api_id = var.api_id
  integration_type = "AWS_PROXY"
  integration_uri = aws_lambda_function.function.invoke_arn
}

resource "aws_apigatewayv2_route" "route" {
  api_id = var.api_id
  route_key = "${var.method} ${var.path}"
  target         = "integrations/${aws_apigatewayv2_integration.integration.id}"
}


resource "aws_lambda_permission" "perm" {
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.function.function_name
  principal = "apigateway.amazonaws.com"
  source_arn = "${var.api_exec_arn}/*/*/*"
}

resource "aws_lambda_function" "function" {
  function_name = var.func_name
  handler = var.func_handler
  role = aws_iam_role.function.arn
  runtime = "nodejs12.x"
  filename = "payload.zip"
  source_code_hash = filebase64sha256(var.output_path)
}

resource "aws_cloudwatch_log_group" "logs" {
  name = "/aws/lambda/${var.func_name}"
}


resource "aws_iam_role" "function" {
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
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

resource "aws_iam_role_policy" "function" {
  policy = data.aws_iam_policy_document.func_policy.json
  role = aws_iam_role.function.id
}

data "aws_iam_policy_document" "func_policy" {
  statement {
    actions = ["logs:CreateLogStream", "logs:CreateLogGroup", "logs:PutLogEvents"]
    resources = [aws_cloudwatch_log_group.logs.arn]
  }
}
