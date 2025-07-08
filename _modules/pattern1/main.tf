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

resource "aws_s3_bucket" "lambda_artifacts" {
  count  = var.enabled ? 1 : 0
  bucket = "${var.prefix}-lambda-artifacts"
  tags   = var.tags
}

resource "aws_sqs_queue" "document" {
  count = var.enabled ? 1 : 0
  name  = "${var.prefix}-document-queue"
  tags  = var.tags
}

# Lambda function definitions
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

# Create Lambda function zip artifacts using Terraform
data "archive_file" "lambda_zip" {
  count       = var.enabled ? length(local.lambda_functions) : 0
  type        = "zip"
  source_dir  = "${path.root}/src/lambda/${local.lambda_functions[count.index]}"
  output_path = "${path.root}/src/lambda/${local.lambda_functions[count.index]}.zip"
  
  depends_on = [aws_s3_bucket.lambda_artifacts]
}

# Upload Lambda artifacts to S3
resource "aws_s3_object" "lambda_artifact" {
  count  = var.enabled ? length(local.lambda_functions) : 0
  bucket = aws_s3_bucket.lambda_artifacts[0].id
  key    = "${local.lambda_functions[count.index]}.zip"
  source = data.archive_file.lambda_zip[count.index].output_path
  etag   = data.archive_file.lambda_zip[count.index].output_md5
  
  depends_on = [data.archive_file.lambda_zip]
}

# Create Lambda functions distributed across subnets
resource "aws_lambda_function" "pattern1_lambdas" {
  count         = var.enabled ? length(local.lambda_functions) : 0
  function_name = "${var.prefix}-${local.lambda_functions[count.index]}"
  s3_bucket     = aws_s3_bucket.lambda_artifacts[0].id
  s3_key        = aws_s3_object.lambda_artifact[count.index].key
  handler       = "index.handler"
  runtime       = "python3.12"
  role          = var.lambda_exec_role_arn
  
  # Distribute Lambda functions across subnets for high availability
  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [aws_security_group.lambda[0].id]
  }
  
  tags = var.tags
  
  depends_on = [aws_s3_object.lambda_artifact]
}

# Security group for Lambda functions
resource "aws_security_group" "lambda" {
  count       = var.enabled ? 1 : 0
  name        = "${var.prefix}-lambda-sg"
  description = "Security group for Lambda functions"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

# Subnet group for resources that support multiple subnets
resource "aws_db_subnet_group" "main" {
  count      = var.enabled ? 1 : 0
  name       = "${var.prefix}-subnet-group"
  subnet_ids = var.subnet_ids
  tags       = var.tags
}

resource "aws_sfn_state_machine" "main" {
  count = var.enabled ? 1 : 0
  name  = "${var.prefix}-textract-state-machine"
  role_arn = var.lambda_exec_role_arn
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