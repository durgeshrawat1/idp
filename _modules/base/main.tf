variable "vpc_id" {}
variable "subnet_id" {}
variable "kms_key_arn" {}
variable "prefix" {}
variable "tags" { type = map(string) }

resource "aws_cognito_user_pool" "main" {
  name = "${var.prefix}-user-pool"
  tags = var.tags
}

resource "aws_cognito_user_pool_client" "main" {
  name         = "${var.prefix}-user-pool-client"
  user_pool_id = aws_cognito_user_pool.main.id
  tags         = var.tags
}

resource "aws_cognito_identity_pool" "main" {
  identity_pool_name               = "${var.prefix}-identity-pool"
  allow_unauthenticated_identities = false
  cognito_identity_providers {
    client_id   = aws_cognito_user_pool_client.main.id
    provider_name = aws_cognito_user_pool.main.endpoint
  }
  tags = var.tags
}

resource "aws_appsync_graphql_api" "main" {
  name                = "${var.prefix}-appsync-api"
  authentication_type = "AMAZON_COGNITO_USER_POOLS"
  user_pool_config {
    user_pool_id = aws_cognito_user_pool.main.id
  }
  tags = var.tags
}

resource "aws_dynamodb_table" "tracking" {
  name         = "${var.prefix}-tracking-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"
  attribute {
    name = "id"
    type = "S"
  }
  tags = var.tags
}

resource "aws_dynamodb_table" "concurrency" {
  name         = "${var.prefix}-concurrency-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"
  attribute {
    name = "id"
    type = "S"
  }
  tags = var.tags
}

resource "aws_dynamodb_table" "configuration" {
  name         = "${var.prefix}-configuration-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"
  attribute {
    name = "id"
    type = "S"
  }
  tags = var.tags
}

resource "aws_s3_bucket" "config" {
  bucket = "${var.prefix}-config"
  tags   = var.tags
}

resource "aws_s3_bucket" "webui" {
  bucket = "${var.prefix}-webui"
  tags   = var.tags
}

resource "aws_s3_bucket" "reporting" {
  bucket = "${var.prefix}-reporting"
  tags   = var.tags
}

resource "aws_s3_bucket" "evaluation" {
  bucket = "${var.prefix}-evaluation"
  tags   = var.tags
}

resource "aws_sns_topic" "alerts" {
  name = "${var.prefix}-alerts"
  tags = var.tags
} 