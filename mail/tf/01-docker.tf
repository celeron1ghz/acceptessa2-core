resource "aws_ecr_repository" "mail" {
  name                 = "${local.appid}-mail"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
