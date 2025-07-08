output "enabled" { value = var.enabled }
output "vpc_id" { value = var.vpc_id }
output "subnet_ids" { value = var.subnet_ids }
output "kms_key_arn" { value = var.kms_key_arn }
output "prefix" { value = var.prefix }
output "tags" { value = var.tags }
output "lambda_exec_role_arn" { value = var.lambda_exec_role_arn }

output "input_bucket" {
  value = var.enabled ? aws_s3_bucket.input[0].id : null
}

output "output_bucket" {
  value = var.enabled ? aws_s3_bucket.output[0].id : null
}

output "logs_bucket" {
  value = var.enabled ? aws_s3_bucket.logs[0].id : null
}

output "lambda_artifacts_bucket" {
  value = var.enabled ? aws_s3_bucket.lambda_artifacts[0].id : null
}

output "document_queue" {
  value = var.enabled ? aws_sqs_queue.document[0].id : null
}

output "lambda_functions" {
  value = var.enabled ? aws_lambda_function.pattern1_lambdas[*].function_name : []
}

output "lambda_security_group" {
  value = var.enabled ? aws_security_group.lambda[0].id : null
}

output "subnet_group" {
  value = var.enabled ? aws_db_subnet_group.main[0].id : null
}

output "state_machine" {
  value = var.enabled ? aws_sfn_state_machine.main[0].id : null
} 