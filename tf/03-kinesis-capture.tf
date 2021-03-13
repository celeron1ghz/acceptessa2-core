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
    sid = "1"
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents"
    ]

    resources = [
      "arn:aws:logs:*:*:*",
    ]
  }

  statement {
    sid = "2"
    actions = [
      "firehose:PutRecord",
      "firehose:PutRecordBatch"
    ]

    resources = [
      module.log-database.firehose_arn
    ]
  }

  statement {
    sid = "3"
    actions = [
      "dynamodb:GetRecords",
      "dynamodb:GetShardIterator",
      "dynamodb:DescribeStream",
      "dynamodb:ListStreams"
    ]

    resources = [
      aws_dynamodb_table.token.stream_arn
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

  environment {
    variables = {
      FIREHOSE_DELIVERY_STREAM_NAME = module.log-database.firehose_name
    }
  }
}

resource "aws_lambda_event_source_mapping" "example" {
  event_source_arn  = aws_dynamodb_table.token.stream_arn
  function_name     = aws_lambda_function.dynamodb-capture.arn
  starting_position = "LATEST"
}
