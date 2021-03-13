module "log-database" {
  source = "./module/kinesis_firehose"
  name   = "acceptessa2-log-database"
}
