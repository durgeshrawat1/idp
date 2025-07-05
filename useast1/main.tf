terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

# Use environment variables for sensitive configuration
locals {
  cicd_role_arn = var.cicd_role_arn != "" ? var.cicd_role_arn : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/AWS1234-lab-cicd-role"
  kms_key_arn   = var.kms_key_arn != "" ? var.kms_key_arn : "arn:aws:kms:us-east-1:${data.aws_caller_identity.current.account_id}:key/default-key"
}

# Get current AWS account ID
data "aws_caller_identity" "current" {}

provider "aws" {
  region = "us-east-1"
  alias  = "useast1"
  
  # Assume CI/CD IAM role
  assume_role {
    role_arn = local.cicd_role_arn
  }
}

# Data sources for existing VPC and subnets
data "aws_vpc" "selected" {
  tags = {
    Name = var.useast1.selected_vpc_name
  }
}

data "aws_subnets" "selected" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
  
  filter {
    name   = "tag:Name"
    values = var.useast1.selected_subnet_names
  }
}

# Base module
module "base" {
  source = "../_modules/base"
  
  prefix = var.prefix
  tags   = var.tags
  kms_key_arn = local.kms_key_arn
  enable_cognito = var.enable_cognito
  enable_appsync = var.enable_appsync
}

# IAM roles and policies module
module "iam_roles_and_policies" {
  source = "../_modules/iam_roles_and_policies"
  
  prefix = var.prefix
  tags   = var.tags
}

# Pattern-1 module
module "pattern1" {
  source = "../_modules/pattern1"
  
  enabled = var.useast1.enable_pattern1
  vpc_id  = data.aws_vpc.selected.id
  subnet_ids = data.aws_subnets.selected.ids
  kms_key_arn = module.base.kms_key_arn
  prefix = var.prefix
  tags   = var.tags
  lambda_exec_role_arn = module.iam_roles_and_policies.lambda_exec_role_arn
} 