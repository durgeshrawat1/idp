variable "enabled" { type = bool; default = true }
variable "vpc_id" {}
variable "subnet_id" {}
variable "kms_key_arn" {}
variable "prefix" {}
variable "tags" { type = map(string) }

resource "aws_s3_bucket" "input" {
  count  = var.enabled ? 1 : 0
  bucket = "${var.prefix}-textract-input"
  tags   = var.tags
}

resource "aws_s3_bucket" "output" {
  count  = var.enabled ? 1 : 0
  bucket = "${var.prefix}-textract-output"
  tags   = var.tags
}

resource "aws_s3_bucket" "logs" {
  count  = var.enabled ? 1 : 0
  bucket = "${var.prefix}-textract-logs"
  tags   = var.tags
}

resource "aws_sqs_queue" "document" {
  count = var.enabled ? 1 : 0
  name  = "${var.prefix}-document-queue"
  tags  = var.tags
}

# Lambda function packaging and deployment is assumed to be handled by CI/CD
locals {
  lambda_functions = [
    "custom_resource_helper",
    "cognito_custom_message",
    "webui_custom_resource",
    "document_queue_handler",
    "textract_async_handler",
    "comprehend_async_handler",
    "bedrock_data_automation_handler",
    "post_processing_hook"
  ]
}

resource "aws_lambda_function" "pattern1_lambdas" {
  count         = var.enabled ? length(local.lambda_functions) : 0
  function_name = "${var.prefix}-${local.lambda_functions[count.index]}"
  s3_bucket     = "<lambda-artifacts-bucket>" # Replace with your artifact bucket
  s3_key        = "${local.lambda_functions[count.index]}.zip"
  handler       = "index.handler"
  runtime       = "python3.12"
  role          = aws_iam_role.lambda_exec.arn
  tags          = var.tags
}

resource "aws_iam_role" "lambda_exec" {
  name = "${var.prefix}-lambda-exec"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  tags = var.tags
}

resource "aws_sfn_state_machine" "main" {
  count = var.enabled ? 1 : 0
  name  = "${var.prefix}-textract-state-machine"
  role_arn = aws_iam_role.lambda_exec.arn
  definition = file("${path.module}/pattern1_state_machine.json")
  tags  = var.tags
}

resource "aws_cloudwatch_log_group" "lambda" {
  count = var.enabled ? length(local.lambda_functions) : 0
  name  = "/aws/lambda/${var.prefix}-${local.lambda_functions[count.index]}"
  tags  = var.tags
}

resource "aws_cloudwatch_log_group" "stepfn" {
  count = var.enabled ? 1 : 0
  name  = "/aws/stepfunction/${var.prefix}-textract-state-machine"
  tags  = var.tags
}

# Bedrock Data Automation project (pseudo resource, as Bedrock is not yet natively supported in Terraform)
resource "null_resource" "bedrock_data_automation" {
  count = var.enabled ? 1 : 0
  provisioner "local-exec" {
    command = "echo 'Create or reference Bedrock Data Automation project here'"
  }
  triggers = {
    pattern = "pattern1"
  }
} 