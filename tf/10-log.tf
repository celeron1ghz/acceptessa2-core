resource "aws_s3_bucket" "log" {
  bucket = "${local.appid}-log"
  acl    = "private"
}

data "aws_iam_policy_document" "assume-log" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "policy-log" {
  statement {
    sid = "1"
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
    ]

    resources = [
      aws_s3_bucket.log.arn,
    ]
  }

  statement {
    sid = "2"
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetObject",
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.log.arn}/*",
    ]
  }
}

resource "aws_iam_role" "log" {
  name               = "${local.appid}-log"
  assume_role_policy = data.aws_iam_policy_document.assume-log.json
}

resource "aws_iam_policy" "log" {
  name   = "${local.appid}-log"
  policy = data.aws_iam_policy_document.policy-log.json
}

resource "aws_iam_role_policy_attachment" "attach-log" {
  role       = aws_iam_role.log.name
  policy_arn = aws_iam_policy.log.arn
}

resource "aws_kinesis_firehose_delivery_stream" "log" {
  name        = "${local.appid}-log"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn        = aws_iam_role.log.arn
    bucket_arn      = aws_s3_bucket.log.arn
    buffer_size     = 1
    buffer_interval = 60
  }
}
