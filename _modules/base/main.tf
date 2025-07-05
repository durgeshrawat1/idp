# KMS Key for encryption (referenced, not created)
data "aws_kms_key" "main" {
  key_id = var.kms_key_arn
}

resource "aws_cognito_user_pool" "main" {
  count = var.enable_cognito ? 1 : 0
  name  = "${var.prefix}-user-pool"
}

resource "aws_cognito_user_pool_client" "main" {
  count        = var.enable_cognito ? 1 : 0
  name         = "${var.prefix}-user-pool-client"
  user_pool_id = aws_cognito_user_pool.main[0].id
}

resource "aws_cognito_identity_pool" "main" {
  count                           = var.enable_cognito ? 1 : 0
  identity_pool_name              = "${var.prefix}-identity-pool"
  allow_unauthenticated_identities = false
  cognito_identity_providers {
    client_id     = aws_cognito_user_pool_client.main[0].id
    provider_name = aws_cognito_user_pool.main[0].endpoint
  }
}

resource "aws_appsync_graphql_api" "main" {
  count               = var.enable_appsync ? 1 : 0
  name                = "${var.prefix}-appsync-api"
  authentication_type = "AMAZON_COGNITO_USER_POOLS"
  user_pool_config {
    user_pool_id   = var.enable_cognito ? aws_cognito_user_pool.main[0].id : null
    default_action = "ALLOW"
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