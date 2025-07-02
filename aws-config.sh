#!/bin/bash

# AWS Configuration Script for SisChampions2022
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🔧 AWS Configuration Script for SisChampions2022${NC}"

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo -e "${RED}❌ AWS CLI is not installed.${NC}"
    echo -e "${YELLOW}📥 Please install AWS CLI from: https://aws.amazon.com/cli/${NC}"
    exit 1
fi

echo -e "${GREEN}✅ AWS CLI is installed${NC}"

# Configure AWS credentials
echo -e "${YELLOW}🔐 Configuring AWS credentials...${NC}"
echo -e "${YELLOW}Please enter your AWS credentials:${NC}"

read -p "AWS Access Key ID: " AWS_ACCESS_KEY_ID
read -s -p "AWS Secret Access Key: " AWS_SECRET_ACCESS_KEY
echo
read -p "AWS Region (default: us-east-1): " AWS_REGION
AWS_REGION=${AWS_REGION:-"us-east-1"}

# Configure AWS CLI
aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
aws configure set default.region $AWS_REGION
aws configure set default.output json

echo -e "${GREEN}✅ AWS credentials configured${NC}"

# Test AWS credentials
echo -e "${YELLOW}🧪 Testing AWS credentials...${NC}"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ AWS credentials are valid${NC}"
    echo -e "${YELLOW}📋 AWS Account ID: ${AWS_ACCOUNT_ID}${NC}"
else
    echo -e "${RED}❌ AWS credentials are invalid${NC}"
    exit 1
fi

# Create S3 bucket for Terraform state
echo -e "${YELLOW}🪣 Creating S3 bucket for Terraform state...${NC}"
BUCKET_NAME="sischampions2022-terraform-state-${AWS_ACCOUNT_ID}"

aws s3api create-bucket \
    --bucket $BUCKET_NAME \
    --region $AWS_REGION \
    --create-bucket-configuration LocationConstraint=$AWS_REGION 2>/dev/null || true

echo -e "${GREEN}✅ S3 bucket created: ${BUCKET_NAME}${NC}"

# Enable versioning on S3 bucket
aws s3api put-bucket-versioning \
    --bucket $BUCKET_NAME \
    --versioning-configuration Status=Enabled

echo -e "${GREEN}✅ S3 bucket versioning enabled${NC}"

# Create IAM user for GitHub Actions (if not exists)
echo -e "${YELLOW}👤 Creating IAM user for GitHub Actions...${NC}"
USER_NAME="github-actions-sischampions2022"

aws iam create-user --user-name $USER_NAME 2>/dev/null || echo -e "${YELLOW}ℹ️  User already exists${NC}"

# Create access key for the user
echo -e "${YELLOW}🔑 Creating access key for GitHub Actions...${NC}"
ACCESS_KEY_OUTPUT=$(aws iam create-access-key --user-name $USER_NAME)

ACCESS_KEY_ID=$(echo $ACCESS_KEY_OUTPUT | jq -r '.AccessKey.AccessKeyId')
SECRET_ACCESS_KEY=$(echo $ACCESS_KEY_OUTPUT | jq -r '.AccessKey.SecretAccessKey')

echo -e "${GREEN}✅ Access key created${NC}"
echo -e "${YELLOW}📋 Access Key ID: ${ACCESS_KEY_ID}${NC}"
echo -e "${YELLOW}📋 Secret Access Key: ${SECRET_ACCESS_KEY}${NC}"

# Create IAM policy for the user
echo -e "${YELLOW}📜 Creating IAM policy...${NC}"
POLICY_ARN=$(aws iam create-policy \
    --policy-name "SisChampions2022DeploymentPolicy" \
    --policy-document '{
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "ecr:GetAuthorizationToken",
                    "ecr:BatchCheckLayerAvailability",
                    "ecr:GetDownloadUrlForLayer",
                    "ecr:BatchGetImage",
                    "ecr:PutImage",
                    "ecr:InitiateLayerUpload",
                    "ecr:UploadLayerPart",
                    "ecr:CompleteLayerUpload"
                ],
                "Resource": "*"
            },
            {
                "Effect": "Allow",
                "Action": [
                    "ecs:DescribeServices",
                    "ecs:DescribeTaskDefinition",
                    "ecs:DescribeTasks",
                    "ecs:ListTasks",
                    "ecs:RegisterTaskDefinition",
                    "ecs:UpdateService"
                ],
                "Resource": "*"
            },
            {
                "Effect": "Allow",
                "Action": [
                    "iam:PassRole"
                ],
                "Resource": "*"
            }
        ]
    }' \
    --query 'Policy.Arn' \
    --output text)

echo -e "${GREEN}✅ IAM policy created: ${POLICY_ARN}${NC}"

# Attach policy to user
aws iam attach-user-policy \
    --user-name $USER_NAME \
    --policy-arn $POLICY_ARN

echo -e "${GREEN}✅ Policy attached to user${NC}"

# Create GitHub Secrets file
echo -e "${YELLOW}📝 Creating GitHub Secrets template...${NC}"
cat > github-secrets.txt << EOF
# Add these secrets to your GitHub repository:
# Go to Settings > Secrets and variables > Actions

AWS_ACCESS_KEY_ID=${ACCESS_KEY_ID}
AWS_SECRET_ACCESS_KEY=${SECRET_ACCESS_KEY}
AWS_REGION=${AWS_REGION}
EOF

echo -e "${GREEN}✅ GitHub secrets template created: github-secrets.txt${NC}"

echo -e "${GREEN}🎉 AWS configuration completed successfully!${NC}"
echo -e "${YELLOW}📋 Next steps:${NC}"
echo -e "${YELLOW}   1. Add the secrets from github-secrets.txt to your GitHub repository${NC}"
echo -e "${YELLOW}   2. Update the terraform/main.tf file with your AWS account ID${NC}"
echo -e "${YELLOW}   3. Run 'terraform init' and 'terraform apply' in the terraform directory${NC}"
echo -e "${YELLOW}   4. Push your code to trigger the CI/CD pipeline${NC}" 