# AWS GenAI Intelligent Document Processing (IDP) Accelerator - Terraform

This repository contains the Terraform codebase for deploying the AWS GenAI IDP Accelerator Pattern-1 across multiple regions (us-east-1 and us-east-2).

## Prerequisites

### 1. CI/CD IAM Role Setup

Before deploying, you need to set up a CI/CD IAM role that Terraform will assume to create AWS resources.

#### Create the CI/CD IAM Role

```bash
# Create the CI/CD role with necessary permissions
aws iam create-role \
  --role-name AWS1234-lab-cicd-role \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::YOUR-ACCOUNT-ID:root"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }'

# Attach necessary policies for Terraform operations
aws iam attach-role-policy \
  --role-name AWS1234-lab-cicd-role \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
```

#### Update Configuration

1. Update `env/common.tfvars` with your CI/CD role ARN:
   ```hcl
   cicd_role_arn = "arn:aws:iam::YOUR-ACCOUNT-ID:role/AWS1234-lab-cicd-role"
   ```

2. Set the GitLab CI variable:
   - Go to your GitLab project → Settings → CI/CD → Variables
   - Add variable: `CICD_GITLAB_RUNNER_IAM_ROLE` = `arn:aws:iam::YOUR-ACCOUNT-ID:role/AWS1234-lab-cicd-role`

### 2. Existing VPC and Subnets

Ensure you have existing VPCs and subnets in both regions:

- **us-east-1**: VPC named `vpc-1-us-east-1` with subnets `subnet-1-us-east-1`, `subnet-2-us-east-1`, `subnet-3-us-east-1`, `subnet-4-us-east-1`
- **us-east-2**: VPC named `vpc-1-us-east-2` with subnets `subnet-1-us-east-2`, `subnet-2-us-east-2`, `subnet-3-us-east-2`, `subnet-4-us-east-2`

## Project Structure

```
genai/
├── _modules/                    # Reusable Terraform modules
│   ├── base/                   # Base resources (KMS, etc.)
│   ├── iam_roles_and_policies/ # IAM roles and policies
│   └── pattern1/               # Pattern-1 specific resources
├── useast1/                    # us-east-1 region deployment
├── useast2/                    # us-east-2 region deployment
├── src/                        # Source code
│   ├── lambda/                 # Lambda function source code
│   └── webui/                  # Web UI source code
├── template/                   # AppSync schema and resolvers
├── env/                        # Environment variables
│   └── common.tfvars          # Common configuration
└── gitlab-ci.yaml             # GitLab CI/CD pipeline
```

## Deployment

### Local Deployment

1. **Initialize Terraform**:
   ```bash
   cd useast1
   terraform init
   terraform plan -var-file=../env/common.tfvars -var="cicd_role_arn=arn:aws:iam::YOUR-ACCOUNT-ID:role/AWS1234-lab-cicd-role"
   terraform apply -var-file=../env/common.tfvars -var="cicd_role_arn=arn:aws:iam::YOUR-ACCOUNT-ID:role/AWS1234-lab-cicd-role"
   ```

2. **Repeat for us-east-2**:
   ```bash
   cd ../useast2
   terraform init
   terraform plan -var-file=../env/common.tfvars -var="cicd_role_arn=arn:aws:iam::YOUR-ACCOUNT-ID:role/AWS1234-lab-cicd-role"
   terraform apply -var-file=../env/common.tfvars -var="cicd_role_arn=arn:aws:iam::YOUR-ACCOUNT-ID:role/AWS1234-lab-cicd-role"
   ```

### GitLab CI/CD Deployment

The GitLab CI pipeline will automatically:
1. Run Terraform validate, plan, and apply (which handles Lambda function creation, AppSync schema/resolvers, Web UI build/upload, and all other infrastructure deployment)

## Resources Created

### Base Resources
- KMS Key for encryption
- CloudWatch Log Groups

### Pattern-1 Resources
- S3 Buckets (input, output, logs)
- SQS Queue for document processing
- Lambda Functions (8 functions distributed across 4 subnets)
- Step Functions State Machine
- Security Groups
- Subnet Groups

### IAM Resources
- Lambda execution roles
- Service-specific policies

## Configuration

Update `env/common.tfvars` to customize:
- Resource prefix
- Tags
- VPC and subnet names
- CI/CD role ARN

## Security

- All resources are tagged with appropriate security tags
- Lambda functions run in VPC with security groups
- KMS encryption for sensitive data
- IAM roles with least privilege access

## Support

For issues or questions, please refer to the AWS GenAI IDP Accelerator documentation or create an issue in this repository.

---

## 🚀 **Environment Setup Guide**

### **What You Need to Change to Make This Work**

This section provides a comprehensive checklist of all the changes required to deploy this Terraform code in your environment.

### **1. GitLab CI/CD Variables Setup**

Go to your GitLab project → **Settings → CI/CD → Variables** and add:

| Variable Name | Value | Protected | Masked | Description |
|---------------|-------|-----------|---------|-------------|
| `CICD_GITLAB_RUNNER_IAM_ROLE` | `arn:aws:iam::YOUR-ACCOUNT-ID:role/YOUR-CICD-ROLE-NAME` | ✅ | ❌ | IAM role for CI/CD operations |
| `KMS_KEY_ARN` | `arn:aws:kms:us-east-1:YOUR-ACCOUNT-ID:key/YOUR-KEY-ID` | ✅ | ❌ | Existing KMS key ARN |

### **2. Update Environment Configuration File**

Update the environment configuration file with your actual infrastructure details:

#### **Environment Configuration (`env/dev1_intelligence/lab.tfvars`):**
```hcl
# Lab environment configuration for GenAI IDP Accelerator
# This file contains all variables for both us-east-1 and us-east-2 regions

# Common variables for both regions
prefix = "YOUR-PROJECT-PREFIX"  # Change from "AWS1234-lab" to your prefix

tags = {
  Environment = "YOUR-ENVIRONMENT"  # Change from "lab" to "dev", "staging", "prod"
  Project     = "YOUR-PROJECT-NAME"  # Change from "genai-idp" to your project name
  Owner       = "YOUR-TEAM-NAME"     # Change from "AWS1234" to your team/owner
  ManagedBy   = "terraform"
}

# Feature flags - Set these based on your needs
enable_cognito = true   # Set to false if you don't need Cognito authentication
enable_appsync = true   # Set to false if you don't need AppSync GraphQL API
enable_webui = true     # Set to false if you don't need Web UI deployment

# us-east-1 configuration - UPDATE THESE TO MATCH YOUR EXISTING INFRASTRUCTURE
useast1 = {
  enable_pattern1 = true
  selected_vpc_name = "YOUR-VPC-NAME-US-EAST-1"  # Must match existing VPC Name tag
  selected_subnet_names = ["YOUR-SUBNET-1", "YOUR-SUBNET-2", "YOUR-SUBNET-3", "YOUR-SUBNET-4"]  # Must match existing subnet Name tags
}

# us-east-2 configuration - UPDATE THESE TO MATCH YOUR EXISTING INFRASTRUCTURE
useast2 = {
  enable_pattern1 = true
  selected_vpc_name = "YOUR-VPC-NAME-US-EAST-2"  # Must match existing VPC Name tag
  selected_subnet_names = ["YOUR-SUBNET-1", "YOUR-SUBNET-2", "YOUR-SUBNET-3", "YOUR-SUBNET-4"]  # Must match existing subnet Name tags
}
```

> **Note:**
> Use the correct branch folder (e.g., `env/dev1_intelligence/`) for your environment. If you are working on a different branch, create a corresponding folder and update the `lab.tfvars` file.

### **3. Create CI/CD IAM Role**

If you don't have a CI/CD role yet, create one:

```bash
# Create the CI/CD role
aws iam create-role \
  --role-name YOUR-PROJECT-PREFIX-cicd-role \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::YOUR-ACCOUNT-ID:root"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }'

# Attach necessary policies (adjust permissions based on your security requirements)
aws iam attach-role-policy \
  --role-name YOUR-PROJECT-PREFIX-cicd-role \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
```

### **4. Verify Existing Infrastructure**

Ensure these resources exist in your AWS account:

- **VPCs** with the exact Name tags specified in `common.tfvars`
- **Subnets** with the exact Name tags specified in `common.tfvars`
- **KMS Key** with the ARN specified in GitLab CI variables

### **5. GitLab CI Integration**

Choose one of these integration methods:

#### **Option A: Include External Template (Recommended)**
Add this to your main `.gitlab-ci.yml`:
```yaml
include: 'terraform-ci.yml'
```

#### **Option B: Copy Individual Jobs**
Use the job templates from `job-templates.md` to copy specific jobs into your existing pipeline.

### **6. Add Source Code**

#### **Lambda Functions**
Add your Python code to the `src/lambda/` directories:

```
src/lambda/
├── custom_resource_helper/
│   ├── index.py
│   └── requirements.txt
├── cognito_custom_message/
│   ├── index.py
│   └── requirements.txt
├── webui_custom_resource/
│   ├── index.py
│   └── requirements.txt
├── document_queue_handler/
│   ├── index.py
│   └── requirements.txt
├── textract_async_handler/
│   ├── index.py
│   └── requirements.txt
├── comprehend_async_handler/
│   ├── index.py
│   └── requirements.txt
├── bedrock_data_automation_handler/
│   ├── index.py
│   └── requirements.txt
└── post_processing_hook/
    ├── index.py
    └── requirements.txt
```

#### **Web UI**
Add your React/Angular/Vue.js application to `src/webui/`:
```
src/webui/
├── package.json
├── src/
├── public/
└── build/ (will be generated)
```

#### **AppSync Schema and Resolvers**
Add your GraphQL schema and resolvers:
```
template/
├── schema.graphql
└── resolvers/
    ├── Query.resolver.vtl
    ├── Mutation.resolver.vtl
    └── Subscription.resolver.vtl
```

### **7. Update Step Functions State Machine**

Replace the placeholder in `_modules/pattern1/pattern1_state_machine.json` with your actual workflow definition.

### **8. Test Deployment**

#### **Local Testing**
```bash
# Test us-east-1
cd useast1
terraform init
terraform plan -var-file=../env/dev1_intelligence/lab.tfvars

# Test us-east-2
cd ../useast2
terraform init
terraform plan -var-file=../env/dev1_intelligence/lab.tfvars
```

#### **GitLab CI Testing**
The GitLab CI pipeline uses the `TFVARS_PATH` environment variable to determine which tfvars file to use:
- Default: `TFVARS_PATH=env/dev1_intelligence/lab.tfvars`
- The same tfvars file is used for both regions since it contains all variables

#### **GitLab CI Testing**
1. Push your code to GitLab
2. The pipeline will automatically run validation and planning
3. Manually approve the apply stage for production deployment

### **9. Post-Deployment Configuration**

After successful deployment:

1. **Update AppSync Data Sources**: Replace `<YOUR_DATA_SOURCE_NAME>` in the GitLab CI pipeline with actual data source names
2. **Configure Lambda Environment Variables**: Set any required environment variables for your Lambda functions
3. **Set up Monitoring**: Configure CloudWatch alarms and dashboards
4. **Security Review**: Review IAM permissions and adjust as needed

### **10. Troubleshooting**

#### **Common Issues:**

1. **VPC/Subnet Not Found**: Ensure the Name tags in AWS match exactly with `common.tfvars`
2. **KMS Key Access Denied**: Verify the CI/CD role has permissions to access the KMS key
3. **Lambda Function Errors**: Check that all required Python packages are in `requirements.txt`
4. **AppSync Schema Errors**: Validate your GraphQL schema syntax

#### **Debug Commands:**
```bash
# Check Terraform configuration
terraform validate

# Check what resources will be created
terraform plan -var-file=env/common.tfvars

# Check existing VPCs and subnets
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=*"
aws ec2 describe-subnets --filters "Name=tag:Name,Values=*"
```

### **11. Security Considerations**

- **IAM Permissions**: Review and restrict the CI/CD role permissions based on your security requirements
- **KMS Key Policy**: Ensure the KMS key allows the CI/CD role to use it
- **VPC Security Groups**: Review and adjust security group rules as needed
- **Data Encryption**: Verify all sensitive data is encrypted at rest and in transit

### **12. Cost Optimization**

- **Lambda Memory**: Adjust Lambda function memory allocation based on your workload
- **DynamoDB Capacity**: Monitor DynamoDB usage and adjust capacity as needed
- **S3 Lifecycle**: Set up S3 lifecycle policies for cost optimization
- **CloudWatch Logs**: Configure log retention policies

---

**🎉 You're now ready to deploy the AWS GenAI IDP Accelerator with Terraform!** 