resource "aws_sns_topic" "mail" {
  name = "${local.appid}-mail-status"
}

resource "aws_sns_topic_subscription" "mail" {
  topic_arn = aws_sns_topic.mail.arn
  endpoint  = aws_lambda_function.mail-status.arn
  protocol  = "lambda"
}

resource "aws_lambda_permission" "mail" {
  function_name = aws_lambda_function.mail-status.function_name
  action        = "lambda:InvokeFunction"
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.mail.arn
}
