module "pattern1" {
  source      = "../_modules/pattern1"
  enabled     = var.pattern == "pattern1"
  vpc_id      = var.vpc_id
  subnet_id   = var.subnet_id
  kms_key_arn = var.kms_key_arn
  prefix      = var.prefix
  tags        = var.tags
} 