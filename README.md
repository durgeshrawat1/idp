# GenAI Intelligent Document Processing on AWS (Terraform)

This project provides a production-grade, multi-region, modular Terraform codebase for deploying the AWS GenAI IDP Accelerator (Pattern-1) with CI/CD automation using GitLab.

## Project Structure

```
app-account/                  # (Optional) Account-level resources
iam_roles_and_policies/       # (Optional) Shared/custom IAM roles and policies
_modules/                     # Reusable Terraform modules
  ├── base/                   # Core/shared resources (Cognito, AppSync, DynamoDB, S3, SNS)
  └── pattern1/               # Pattern-1 specific resources (S3, Lambda, SQS, Step Functions, etc.)
useast1/                      # Region-specific resources for us-east-1
useast2/                      # Region-specific resources for us-east-2
manifests/                    # Main entry point for Terraform (calls region modules)
template/                     # AppSync schema, resolvers, and reference templates
src/
  ├── lambda/                 # Lambda function source code (one folder per function)
  └── webui/                  # Web UI source code (e.g., React app)
env/
  └── common.tfvars           # Centralized variable values
.gitignore
README.md
.gitlab-ci.yaml               # GitLab CI pipeline for build, upload, and deployment
```

## What is Included
- All required S3 buckets for core and Pattern-1
- All required Lambda function folders (place your code in `src/lambda/<function_name>/`)
- AppSync, Cognito, DynamoDB, SNS, SQS, Step Functions, CloudWatch, IAM
- Multi-region support (useast1, useast2)
- Data sources for VPC and subnet (no hardcoding)
- All variables and outputs declared
- GitLab CI pipeline for Lambda, UI, and AppSync deployment

## What You Need to Do

1. **Set Your VPC and Subnet Names**
   - Edit `env/common.tfvars`:
     ```hcl
     vpc_name    = "my-existing-vpc-name"      # Set to your actual VPC Name tag
     subnet_name = "my-existing-subnet-name"   # Set to your actual Subnet Name tag
     kms_key_arn = "arn:aws:kms:..."           # Set to your KMS Key ARN
     prefix      = "AWS1234-lab"               # Or your preferred prefix
     pattern     = "pattern1"                  # Or another pattern if supported
     ```

2. **Place Your Lambda Code**
   - Add your Python code for each Lambda in `src/lambda/<function_name>/` (e.g., `index.py`, `requirements.txt`).

3. **Place Your Web UI Code**
   - Add your React (or other) UI code in `src/webui/`.
   - The pipeline will build and upload it to the S3 webui bucket.

4. **Add Your AppSync Schema and Resolvers**
   - Place your GraphQL schema in `template/schema.graphql`.
   - Place your resolver mapping templates in `template/resolvers/`.
   - Update the GitLab CI pipeline with your actual AppSync API ID and data source names.

5. **Set Required GitLab CI/CD Variables**
   - `CICD_GITLAB_RUNNER_IAM_ROLE` (IAM role for deployment)
   - `LAMBDA_ARTIFACTS_BUCKET` (if using S3 for Lambda zips, otherwise not needed)
   - `WEBUI_BUCKET` (set to the name output by Terraform, e.g., `${prefix}-webui`)
   - `APPSYNC_API_ID` (output by Terraform, or set manually)

6. **Run the Pipeline**
   - The pipeline will build, package, and deploy all resources and code.
   - Outputs (bucket names, ARNs, etc.) are available via `terraform output`.

7. **(Optional) Add More Patterns or Regions**
   - Copy the pattern module and region folder, update as needed.

## Troubleshooting
- Ensure all variables are set in `env/common.tfvars` and passed correctly.
- Make sure your VPC and subnet names match the Name tags in AWS.
- Check the pipeline logs for missing variables or deployment errors.
- Use `terraform output` to get resource names and ARNs for integration.

## References
- [AWS GenAI IDP Accelerator](https://github.com/aws-solutions-library-samples/accelerated-intelligent-document-processing-on-aws)
- [Terraform AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AppSync Documentation](https://docs.aws.amazon.com/appsync/latest/devguide/what-is-appsync.html)

---

**You are now ready to deploy a scalable, production-grade GenAI IDP Accelerator on AWS using Terraform and GitLab CI!** 