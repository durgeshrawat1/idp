output "user_pool_id" {
  value = aws_cognito_user_pool.main.id
  description = "Cognito User Pool ID."
}

output "user_pool_client_id" {
  value = aws_cognito_user_pool_client.main.id
  description = "Cognito User Pool Client ID."
}

output "identity_pool_id" {
  value = aws_cognito_identity_pool.main.id
  description = "Cognito Identity Pool ID."
}

output "appsync_api_id" {
  value = aws_appsync_graphql_api.main.id
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