output "lambda_exec_role_arn" {
  value       = aws_iam_role.lambda_exec.arn
  description = "ARN of the Lambda execution role."
}

output "stepfunctions_exec_role_arn" {
  value       = aws_iam_role.stepfunctions_exec.arn
  description = "ARN of the Step Functions execution role."
} 