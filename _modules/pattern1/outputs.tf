output "lambda_function_arns" {
  value = aws_lambda_function.pattern1_lambdas[*].arn
  description = "ARNs of all Pattern-1 Lambda functions."
}

output "input_bucket" {
  value = aws_s3_bucket.input.bucket
  description = "Name of the input S3 bucket."
}

output "output_bucket" {
  value = aws_s3_bucket.output.bucket
  description = "Name of the output S3 bucket."
}

output "logs_bucket" {
  value = aws_s3_bucket.logs.bucket
  description = "Name of the logs S3 bucket."
}

output "step_function_arn" {
  value = aws_sfn_state_machine.main[0].arn
  description = "ARN of the Step Functions state machine."
  condition = length(aws_sfn_state_machine.main) > 0
} 