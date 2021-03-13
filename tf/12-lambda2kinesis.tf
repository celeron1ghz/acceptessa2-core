data "aws_iam_policy_document" "assume-log-aggregate" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["logs.ap-northeast-1.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "policy-log-aggregate" {
  statement {
    sid = "1"
    actions = [
      "firehose:PutRecord",
      "firehose:PutRecordBatch"
    ]

    resources = [
      module.log-database.kinesis_arn
    ]
  }
}

resource "aws_iam_role" "log-aggregate" {
  name               = "${local.appid}-log-aggregate"
  assume_role_policy = data.aws_iam_policy_document.assume-log-aggregate.json
}

resource "aws_iam_policy" "log-aggregate" {
  name   = "${local.appid}-log-aggregate"
  policy = data.aws_iam_policy_document.policy-log-aggregate.json
}

resource "aws_iam_role_policy_attachment" "attach-log-aggregate" {
  role       = aws_iam_role.log-aggregate.name
  policy_arn = aws_iam_policy.log-aggregate.arn
}

# resource "aws_cloudwatch_log_subscription_filter" "test_lambdafunction_logfilter" {
#   name            = "test111111"
#   role_arn        = aws_iam_role.log-aggregate.arn
#   log_group_name  = "/aws/lambda/gomitter-dev-main"
#   filter_pattern  = ""
#   destination_arn = aws_kinesis_firehose_delivery_stream.log.arn
#   distribution    = "Random"
# }
