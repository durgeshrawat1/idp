variable "vpc_id" { type = string; description = "VPC ID for shared resources." }
variable "subnet_id" { type = string; description = "Subnet ID for shared resources." }
variable "kms_key_arn" { type = string; description = "KMS Key ARN for encryption." }
variable "prefix" { type = string; description = "Resource name prefix." }
variable "tags" { type = map(string); description = "Tags to apply to all resources." } 