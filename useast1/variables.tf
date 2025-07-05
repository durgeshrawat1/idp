variable "prefix" {
  type        = string
  description = "Resource name prefix"
  default     = "AWS1234-lab"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default = {
    Environment = "lab"
    Project     = "genai-idp"
    Owner       = "AWS1234"
  }
}

variable "useast1" {
  type = object({
    enable_pattern1 = bool
    selected_vpc_name = string
    selected_subnet_names = list(string)
  })
  description = "us-east-1 region configuration"
}

variable "cicd_role_arn" {
  type        = string
  description = "ARN of the CI/CD IAM role to assume"
  default     = ""
}

variable "kms_key_arn" {
  type        = string
  description = "KMS Key ARN for encryption"
  default     = ""
}

variable "enable_cognito" {
  type        = bool
  default     = true
  description = "Whether to create Cognito resources"
}

variable "enable_appsync" {
  type        = bool
  default     = true
  description = "Whether to create AppSync GraphQL API"
}

 