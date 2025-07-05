# GitLab CI Job Templates for GenAI IDP Accelerator

## Integration Options

### Option 1: Include External Template
Add this to your main `.gitlab-ci.yml`:
```yaml
include: 'terraform-ci.yml'
```

### Option 2: Copy Individual Jobs
Copy the jobs you need from the templates below into your existing pipeline.

## Job Templates

### 1. Lambda Build Job
```yaml
build_lambdas:
  stage: build  # or your existing build stage name
  variables:
    TF_VAR_cicd_role_arn: $CICD_GITLAB_RUNNER_IAM_ROLE
    TF_VAR_kms_key_arn: $KMS_KEY_ARN
  before_script:
    - apk add --no-cache zip python3 py3-pip nodejs npm
    - pip3 install awscli
    - export AWS_ROLE_ARN=$CICD_GITLAB_RUNNER_IAM_ROLE
    - export AWS_WEB_IDENTITY_TOKEN_FILE=$CI_JOB_JWT_FILE
  script:
    - cd src/lambda
    - for d in */ ; do cd "$d" && zip -r9 "../../${d%/}.zip" . && cd .. ; done
    - cd ../..
  artifacts:
    paths:
      - src/lambda/*.zip
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
```

### 2. Lambda Upload Job
```yaml
upload_lambdas:
  stage: upload  # or your existing upload stage name
  variables:
    TF_VAR_cicd_role_arn: $CICD_GITLAB_RUNNER_IAM_ROLE
    TF_VAR_kms_key_arn: $KMS_KEY_ARN
  before_script:
    - apk add --no-cache zip python3 py3-pip nodejs npm
    - pip3 install awscli
    - export AWS_ROLE_ARN=$CICD_GITLAB_RUNNER_IAM_ROLE
    - export AWS_WEB_IDENTITY_TOKEN_FILE=$CI_JOB_JWT_FILE
  script:
    - LAMBDA_BUCKET=$(terraform output -raw lambda_artifacts_bucket_name 2>/dev/null || echo "AWS1234-lab-lambda-artifacts")
    - aws s3 mb s3://$LAMBDA_BUCKET || true
    - for f in src/lambda/*.zip; do aws s3 cp "$f" s3://$LAMBDA_BUCKET/ ; done
  dependencies:
    - build_lambdas
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
```

### 3. Web UI Build Job
```yaml
build_ui:
  stage: build_ui  # or your existing UI build stage name
  variables:
    TF_VAR_cicd_role_arn: $CICD_GITLAB_RUNNER_IAM_ROLE
    TF_VAR_kms_key_arn: $KMS_KEY_ARN
  before_script:
    - apk add --no-cache zip python3 py3-pip nodejs npm
    - pip3 install awscli
    - export AWS_ROLE_ARN=$CICD_GITLAB_RUNNER_IAM_ROLE
    - export AWS_WEB_IDENTITY_TOKEN_FILE=$CI_JOB_JWT_FILE
  script:
    - cd src/webui
    - npm install
    - npm run build
    - cd ../..
  artifacts:
    paths:
      - src/webui/build
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
```

### 4. Web UI Upload Job
```yaml
upload_ui:
  stage: upload_ui  # or your existing UI upload stage name
  variables:
    TF_VAR_cicd_role_arn: $CICD_GITLAB_RUNNER_IAM_ROLE
    TF_VAR_kms_key_arn: $KMS_KEY_ARN
  before_script:
    - apk add --no-cache zip python3 py3-pip nodejs npm
    - pip3 install awscli
    - export AWS_ROLE_ARN=$CICD_GITLAB_RUNNER_IAM_ROLE
    - export AWS_WEB_IDENTITY_TOKEN_FILE=$CI_JOB_JWT_FILE
  script:
    - WEBUI_BUCKET=$(terraform output -raw webui_bucket_name 2>/dev/null || echo "AWS1234-lab-webui")
    - aws s3 mb s3://$WEBUI_BUCKET || true
    - aws s3 sync src/webui/build s3://$WEBUI_BUCKET/
  dependencies:
    - build_ui
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
```

### 5. Terraform Validate Job
```yaml
terraform_validate:
  stage: validate  # or your existing validation stage name
  variables:
    TF_VAR_cicd_role_arn: $CICD_GITLAB_RUNNER_IAM_ROLE
    TF_VAR_kms_key_arn: $KMS_KEY_ARN
  before_script:
    - apk add --no-cache zip python3 py3-pip nodejs npm
    - pip3 install awscli
    - export AWS_ROLE_ARN=$CICD_GITLAB_RUNNER_IAM_ROLE
    - export AWS_WEB_IDENTITY_TOKEN_FILE=$CI_JOB_JWT_FILE
  script:
    - terraform init
    - terraform validate
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
```

### 6. Terraform Plan Job
```yaml
terraform_plan:
  stage: plan  # or your existing plan stage name
  variables:
    TF_VAR_cicd_role_arn: $CICD_GITLAB_RUNNER_IAM_ROLE
    TF_VAR_kms_key_arn: $KMS_KEY_ARN
  before_script:
    - apk add --no-cache zip python3 py3-pip nodejs npm
    - pip3 install awscli
    - export AWS_ROLE_ARN=$CICD_GITLAB_RUNNER_IAM_ROLE
    - export AWS_WEB_IDENTITY_TOKEN_FILE=$CI_JOB_JWT_FILE
  script:
    - terraform plan -var-file=env/common.tfvars
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
```

### 7. Terraform Apply Job
```yaml
terraform_apply:
  stage: apply  # or your existing apply stage name
  variables:
    TF_VAR_cicd_role_arn: $CICD_GITLAB_RUNNER_IAM_ROLE
    TF_VAR_kms_key_arn: $KMS_KEY_ARN
  before_script:
    - apk add --no-cache zip python3 py3-pip nodejs npm
    - pip3 install awscli
    - export AWS_ROLE_ARN=$CICD_GITLAB_RUNNER_IAM_ROLE
    - export AWS_WEB_IDENTITY_TOKEN_FILE=$CI_JOB_JWT_FILE
  script:
    - terraform apply -auto-approve -var-file=env/common.tfvars
  when: manual
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
```

### 8. AppSync Deployment Job
```yaml
deploy_appsync:
  stage: deploy_appsync  # or your existing deployment stage name
  variables:
    TF_VAR_cicd_role_arn: $CICD_GITLAB_RUNNER_IAM_ROLE
    TF_VAR_kms_key_arn: $KMS_KEY_ARN
  before_script:
    - apk add --no-cache zip python3 py3-pip nodejs npm
    - pip3 install awscli
    - export AWS_ROLE_ARN=$CICD_GITLAB_RUNNER_IAM_ROLE
    - export AWS_WEB_IDENTITY_TOKEN_FILE=$CI_JOB_JWT_FILE
  script:
    - |
      export APPSYNC_API_ID=$(terraform output -raw appsync_api_id 2>/dev/null || echo "")
      export AWS_REGION=$AWS_DEFAULT_REGION
      
      if [ -n "$APPSYNC_API_ID" ]; then
        aws appsync start-schema-creation --api-id $APPSYNC_API_ID --definition fileb://template/schema.graphql --region $AWS_REGION
        for resolver in template/resolvers/*.vtl; do
          [ -e "$resolver" ] || continue
          TYPE_NAME=$(basename "$resolver" | cut -d'.' -f1)
          FIELD_NAME=$(basename "$resolver" | cut -d'.' -f2)
          aws appsync create-resolver --api-id $APPSYNC_API_ID --type-name $TYPE_NAME --field-name $FIELD_NAME --request-mapping-template fileb://$resolver --response-mapping-template fileb://$resolver --data-source-name <YOUR_DATA_SOURCE_NAME> --region $AWS_REGION || true
        done
      else
        echo "AppSync API ID not found, skipping schema deployment"
      fi
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
```

## Required GitLab CI Variables

Set these in your GitLab project → Settings → CI/CD → Variables:

| Variable Name | Value | Protected | Masked |
|---------------|-------|-----------|---------|
| `CICD_GITLAB_RUNNER_IAM_ROLE` | `arn:aws:iam::YOUR-ACCOUNT-ID:role/YOUR-CICD-ROLE-NAME` | ✅ | ❌ |
| `KMS_KEY_ARN` | `arn:aws:kms:us-east-1:YOUR-ACCOUNT-ID:key/YOUR-KEY-ID` | ✅ | ❌ |

## Customization Tips

1. **Stage Names**: Change the `stage:` values to match your existing pipeline stages
2. **Rules**: Modify the `rules:` section to match your branching strategy
3. **Dependencies**: Adjust `dependencies:` based on your job dependencies
4. **Image**: Add `image: alpine:latest` if you need a specific base image
5. **Tags**: Add `tags: [your-runner-tags]` if you have specific runners 