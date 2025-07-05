variable "enabled" {
  type        = bool
  default     = true
  description = "Whether to enable Pattern-1 resources"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID to use for Lambda networking"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs to use for resources"
}

variable "kms_key_arn" {
  type        = string
  description = "KMS Key ARN for encryption"
}

variable "prefix" {
  type        = string
  description = "Resource name prefix"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
}

variable "lambda_exec_role_arn" {
  type        = string
  description = "Lambda execution role ARN"
} 