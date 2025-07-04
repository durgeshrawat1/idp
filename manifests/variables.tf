variable "vpc_name" { type = string; description = "Name of the existing VPC to reference." }
variable "subnet_name" { type = string; description = "Name of the existing subnet to reference." }
variable "kms_key_arn" { type = string; description = "KMS Key ARN for encryption." }
variable "prefix" { type = string; description = "Resource name prefix." }
variable "tags" { type = map(string); description = "Tags to apply to all resources." }
variable "pattern" { type = string; description = "Pattern to deploy in all regions." } 