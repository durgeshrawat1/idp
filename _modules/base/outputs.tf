output "kms_key_arn" {
  value = data.aws_kms_key.main.arn
  description = "KMS Key ARN for encryption."
}

output "user_pool_id" {
  value       = var.enable_cognito ? aws_cognito_user_pool.main[0].id : null
  description = "Cognito User Pool ID."
}

output "user_pool_client_id" {
  value       = var.enable_cognito ? aws_cognito_user_pool_client.main[0].id : null
  description = "Cognito User Pool Client ID."
}

output "identity_pool_id" {
  value       = var.enable_cognito ? aws_cognito_identity_pool.main[0].id : null
  description = "Cognito Identity Pool ID."
}

output "appsync_api_id" {
  value       = var.enable_appsync ? aws_appsync_graphql_api.main[0].id : null
  description = "AppSync GraphQL API ID."
}

output "tracking_table_name" {
  value = aws_dynamodb_table.tracking.name
  description = "DynamoDB tracking table name."
}

output "concurrency_table_name" {
  value = aws_dynamodb_table.concurrency.name
  description = "DynamoDB concurrency table name."
}

output "configuration_table_name" {
  value = aws_dynamodb_table.configuration.name
  description = "DynamoDB configuration table name."
}

output "lambda_artifacts_bucket_name" {
  value = aws_s3_bucket.config.id
  description = "S3 bucket name for Lambda artifacts."
}

output "webui_bucket_name" {
  value = aws_s3_bucket.webui.id
  description = "S3 bucket name for Web UI."
} 