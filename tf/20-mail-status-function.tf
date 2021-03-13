locals {
  mail_status_function_name = "acceptessa2-core-mail-status"
}

data "archive_file" "mail-status" {
  type        = "zip"
  source_dir  = "function/mail-status/src/"
  output_path = "function/mail-status/function.zip"
}

data "aws_iam_policy_document" "mail-status-assume-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "mail-status-policy" {
  statement {
    sid = "1"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
    ]

    resources = [
      "${aws_cloudwatch_log_group.mail-status.arn}*:*"
    ]
  }

  statement {
    sid = "2"
    actions = [
      "logs:PutLogEvents"
    ]

    resources = [
      "${aws_cloudwatch_log_group.mail-status.arn}*:*:*"
    ]
  }

  statement {
    sid = "3"
    actions = [
      "firehose:PutRecord",
      "firehose:PutRecordBatch"
    ]

    resources = [
      module.log-mail.firehose_arn
    ]
  }
}

resource "aws_cloudwatch_log_group" "mail-status" {
  name              = "/aws/lambda/${local.mail_status_function_name}"
  retention_in_days = 7
}

resource "aws_iam_role_policy" "mail-status" {
  name   = local.mail_status_function_name
  role   = aws_iam_role.mail-status.id
  policy = data.aws_iam_policy_document.mail-status-policy.json
}

resource "aws_iam_role" "mail-status" {
  name               = local.mail_status_function_name
  assume_role_policy = data.aws_iam_policy_document.mail-status-assume-policy.json
}

resource "aws_lambda_function" "mail-status" {
  function_name    = local.mail_status_function_name
  handler          = "handler.main"
  filename         = data.archive_file.mail-status.output_path
  runtime          = "nodejs12.x"
  timeout          = 10
  role             = aws_iam_role.mail-status.arn
  source_code_hash = data.archive_file.mail-status.output_base64sha256

  environment {
    variables = {
      FIREHOSE_DELIVERY_STREAM_NAME = module.log-mail.firehose_name
    }
  }
}
