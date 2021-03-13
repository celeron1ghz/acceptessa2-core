locals {
  function_name = "acceptessa2-core-dynamodb-capture"
}

data "archive_file" "function" {
  type        = "zip"
  source_dir  = "lambda/"
  output_path = "lambda/function.zip"
}

data "aws_iam_policy_document" "policy-lambda" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "policy-cloudwatch" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents"
    ]

    resources = [
      "arn:aws:logs:*:*:*",
    ]
  }
}

resource "aws_iam_role_policy" "lambda_access_policy" {
  name   = local.function_name
  role   = aws_iam_role.lambda_iam_role.id
  policy = data.aws_iam_policy_document.policy-cloudwatch.json
}

resource "aws_iam_role" "lambda_iam_role" {
  name               = local.function_name
  assume_role_policy = data.aws_iam_policy_document.policy-lambda.json
}

resource "aws_lambda_function" "dynamodb-capture" {
  function_name    = local.function_name
  handler          = "lambda/handler.main"
  filename         = data.archive_file.function.output_path
  runtime          = "nodejs12.x"
  timeout          = 10
  role             = aws_iam_role.lambda_iam_role.arn
  source_code_hash = data.archive_file.function.output_base64sha256

  lifecycle {
    ignore_changes = [
      source_code_hash
    ]
  }
}
