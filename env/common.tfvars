# Common variables for both regions
prefix = "AWS1234-lab"

tags = {
  Environment = "lab"
  Project     = "genai-idp"
  Owner       = "AWS1234"
  ManagedBy   = "terraform"
}

# Feature flags
enable_cognito = true
enable_appsync = true

# us-east-1 configuration
useast1 = {
  enable_pattern1 = true
  selected_vpc_name = "vpc-1-us-east-1"
  selected_subnet_names = ["subnet-1-us-east-1", "subnet-2-us-east-1", "subnet-3-us-east-1", "subnet-4-us-east-1"]
}

# us-east-2 configuration  
useast2 = {
  enable_pattern1 = true
  selected_vpc_name = "vpc-1-us-east-2"
  selected_subnet_names = ["subnet-1-us-east-2", "subnet-2-us-east-2", "subnet-3-us-east-2", "subnet-4-us-east-2"]
} 