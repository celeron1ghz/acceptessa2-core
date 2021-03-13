variable "name" {
  type = string
}

data "aws_iam_policy_document" "policy-assume-kinesis" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "policy-s3" {
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

resource "aws_iam_role" "role" {
  name               = var.name
  assume_role_policy = data.aws_iam_policy_document.policy-assume-kinesis.json
}

resource "aws_iam_policy" "policy" {
  name   = var.name
  policy = data.aws_iam_policy_document.policy-s3.json
}

resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_s3_bucket" "log" {
  bucket = var.name
  acl    = "private"
}

resource "aws_kinesis_firehose_delivery_stream" "log" {
  name        = var.name
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn           = aws_iam_role.role.arn
    bucket_arn         = aws_s3_bucket.log.arn
    buffer_size        = 1
    buffer_interval    = 60
    compression_format = "GZIP"
  }
}

output "firehose_name" {
  value = aws_kinesis_firehose_delivery_stream.log.name
}

output "firehose_arn" {
  value = aws_kinesis_firehose_delivery_stream.log.arn
}
