locals {
  name = "acceptessa2-mail-sender"
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "assume-sender" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "policy-sender" {
  statement {
    sid = "1"
    actions = [
      "logs:CreateLogStream"
    ]

    resources = [
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${local.name}:*"
    ]
  }

  statement {
    sid = "2"
    actions = [
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${local.name}:*:*"
    ]
  }
}

resource "aws_ecr_repository" "sender" {
  name                 = "${local.appid}-mail-sender"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_iam_role" "sender" {
  name               = "${local.appid}-mail-sender"
  assume_role_policy = data.aws_iam_policy_document.assume-sender.json
}

resource "aws_iam_policy" "sender" {
  name   = "${local.appid}-mail-sender"
  policy = data.aws_iam_policy_document.policy-sender.json
}

resource "aws_iam_role_policy_attachment" "attach-sender" {
  role       = aws_iam_role.sender.name
  policy_arn = aws_iam_policy.sender.arn
}

resource "aws_cloudwatch_log_group" "sender" {
  name              = "/aws/lambda/${local.name}"
  retention_in_days = 14
}

resource "aws_lambda_function" "sender" {
  function_name = local.name
  description   = "render template and send mail via SES"
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.sender.repository_url}:latest"
  role          = aws_iam_role.sender.arn
  timeout       = 60
  memory_size   = 1024

  lifecycle {
    ignore_changes = [image_uri]
  }
}
