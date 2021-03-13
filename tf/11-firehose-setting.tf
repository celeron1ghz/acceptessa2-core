module "log-database" {
  source = "./module/kinesis_firehose"
  name   = "acceptessa2-log-database"
}

module "log-application" {
  source = "./module/kinesis_firehose"
  name   = "acceptessa2-log-application"
}

module "log-mail" {
  source = "./module/kinesis_firehose"
  name   = "acceptessa2-log-mail"
}
