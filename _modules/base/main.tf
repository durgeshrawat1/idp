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
  schema = file("../template/schema.graphql")
  tags = var.tags
}

# AppSync Data Sources
resource "aws_appsync_datasource" "lambda" {
  count = var.enable_appsync ? 1 : 0
  name  = "${var.prefix}-lambda-datasource"
  type  = "AWS_LAMBDA"
  api_id = aws_appsync_graphql_api.main[0].id
  
  lambda_config {
    function_arn = "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:${var.prefix}-document-queue-handler"
  }
  
  depends_on = [aws_appsync_graphql_api.main]
}

resource "aws_appsync_datasource" "dynamodb" {
  count = var.enable_appsync ? 1 : 0
  name  = "${var.prefix}-dynamodb-datasource"
  type  = "AMAZON_DYNAMODB"
  api_id = aws_appsync_graphql_api.main[0].id
  
  dynamodb_config {
    table_name = aws_dynamodb_table.tracking.name
  }
  
  depends_on = [aws_appsync_graphql_api.main]
}

# AppSync Resolvers
locals {
  resolvers = [
    {
      type_name = "Query"
      field_name = "getDocument"
      data_source = "lambda"
    },
    {
      type_name = "Mutation"
      field_name = "processDocument"
      data_source = "lambda"
    },
    {
      type_name = "Subscription"
      field_name = "documentStatus"
      data_source = "dynamodb"
    }
  ]
}

# AppSync Resolvers - Simplified for now
# TODO: Add proper resolver mapping templates when needed

# Data sources for current region and account
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

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

# Web UI Build and Upload
resource "null_resource" "webui_build" {
  count = var.enable_webui ? 1 : 0
  
  provisioner "local-exec" {
    command = <<-EOT
      cd ../src/webui
      npm install
      npm run build
    EOT
  }
  
  triggers = {
    package_json_hash = filemd5("../src/webui/package.json")
  }
}

# Upload Web UI to S3
resource "aws_s3_object" "webui_files" {
  for_each = var.enable_webui ? fileset("../src/webui/build", "**/*") : toset([])
  
  bucket = aws_s3_bucket.webui.id
  key    = each.value
  source = "../src/webui/build/${each.value}"
  etag   = filemd5("../src/webui/build/${each.value}")
  
  depends_on = [null_resource.webui_build]
}

# Configure S3 bucket for static website hosting
resource "aws_s3_bucket_website_configuration" "webui" {
  count  = var.enable_webui ? 1 : 0
  bucket = aws_s3_bucket.webui.id
  
  index_document {
    suffix = "index.html"
  }
  
  error_document {
    key = "index.html"
  }
}

# S3 bucket policy for public read access (for static website hosting)
resource "aws_s3_bucket_policy" "webui" {
  count  = var.enable_webui ? 1 : 0
  bucket = aws_s3_bucket.webui.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.webui.arn}/*"
      }
    ]
  })
  
  depends_on = [aws_s3_bucket_website_configuration.webui]
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