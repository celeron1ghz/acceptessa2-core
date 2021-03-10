data "aws_iam_policy_document" "assume-log-publish" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "policy-log-publish" {
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

resource "aws_iam_role" "log-publish" {
  name               = "${local.appid}-log-publish"
  assume_role_policy = data.aws_iam_policy_document.assume-log-publish.json
}

resource "aws_iam_policy" "log-publish" {
  name   = "${local.appid}-log-publish"
  policy = data.aws_iam_policy_document.policy-log-publish.json
}

resource "aws_iam_role_policy_attachment" "attach-log-publish" {
  role       = aws_iam_role.log-publish.name
  policy_arn = aws_iam_policy.log-publish.arn
}

resource "aws_s3_bucket" "log" {
  bucket = "${local.appid}-log"
  acl    = "private"
}

resource "aws_kinesis_firehose_delivery_stream" "log" {
  name        = "${local.appid}-log"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn        = aws_iam_role.log-publish.arn
    bucket_arn      = aws_s3_bucket.log.arn
    buffer_size     = 1
    buffer_interval = 60
  }
}
