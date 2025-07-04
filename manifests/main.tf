variable "tags" { type = map(string) }
variable "prefix" { type = string }
variable "vpc_id" { type = string }
variable "subnet_id" { type = string }
variable "kms_key_arn" { type = string }
variable "pattern" { type = string }
variable "vpc_name" { type = string }
variable "subnet_name" { type = string }

provider "aws" {
  region = "us-east-1"
}

data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

data "aws_subnet" "selected" {
  filter {
    name   = "tag:Name"
    values = [var.subnet_name]
  }
}

module "useast1" {
  source      = "../useast1"
  vpc_id      = data.aws_vpc.selected.id
  subnet_id   = data.aws_subnet.selected.id
  kms_key_arn = var.kms_key_arn
  prefix      = var.prefix
  tags        = var.tags
  pattern     = var.pattern
}

module "useast2" {
  source      = "../useast2"
  vpc_id      = data.aws_vpc.selected.id
  subnet_id   = data.aws_subnet.selected.id
  kms_key_arn = var.kms_key_arn
  prefix      = var.prefix
  tags        = var.tags
  pattern     = var.pattern
} 