terraform {
  backend "s3" {
    # bucket = var.bucket
    # key    = "terraform-state"
    # region = var.aws_region
    # dynamodb_table = var.dynamodb
  }
}