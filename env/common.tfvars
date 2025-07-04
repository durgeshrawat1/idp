tags = {
  Project     = "IDP"
  Environment = "dev"
  Owner       = "team-ml"
  CostCenter  = "12345"
  Application = "document-processing"
  ManagedBy   = "terraform"
}

prefix      = "AWS1234-lab"
vpc_name    = "my-existing-vpc-name"
subnet_name = "my-existing-subnet-name"
kms_key_arn = "arn:aws:kms:region:account-id:key/key-id"
pattern     = "pattern1" 