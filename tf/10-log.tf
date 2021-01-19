resource "aws_s3_bucket" "log" {
  bucket = "${local.appid}-log"
  acl    = "private"
}

data "aws_iam_policy_document" "log" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "log" {
  name               = "${local.appid}-log"
  assume_role_policy = data.aws_iam_policy_document.log.json
}

resource "aws_kinesis_firehose_delivery_stream" "log" {
  name        = "${local.appid}-log"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = aws_iam_role.log.arn
    bucket_arn = aws_s3_bucket.log.arn
  }
}
