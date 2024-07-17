terraform {
  backend "s3" {
    # bucket = var.bucket
    # key    = var.bucket_key
    # region = var.aws_region
    # dynamodb_table = var.dynamodb
  }
}