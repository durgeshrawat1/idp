variable "prefix" {
  type        = string
  description = "Resource name prefix"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
} 