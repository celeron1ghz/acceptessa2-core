resource "aws_dynamodb_table" "exhibition" {
  name         = "${local.appid}-exhibition"
  hash_key     = "id"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "id"
    type = "S"
  }
}

resource "aws_dynamodb_table" "circle" {
  name         = "${local.appid}-circle"
  hash_key     = "id"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "id"
    type = "S"
  }
}
