variable "prefix" {
  type        = string
  description = "Resource name prefix"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
}

variable "kms_key_arn" {
  type        = string
  description = "KMS Key ARN for encryption"
}

variable "enable_cognito" {
  type        = bool
  default     = true
  description = "Whether to create Cognito resources (User Pool, User Pool Client, Identity Pool)"
}

variable "enable_appsync" {
  type        = bool
  default     = true
  description = "Whether to create AppSync GraphQL API"
} 