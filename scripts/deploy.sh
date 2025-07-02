#!/bin/bash

# Deploy script for SisChampions2022
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
AWS_REGION=${AWS_REGION:-"us-east-1"}
ECR_REPOSITORY="sischampions2022"
ECS_CLUSTER="sischampions2022-cluster"
ECS_SERVICE="sischampions2022-service"
TASK_DEFINITION="sischampions2022"

echo -e "${GREEN}🚀 Starting deployment of SisChampions2022...${NC}"

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo -e "${RED}❌ AWS CLI is not installed. Please install it first.${NC}"
    exit 1
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed. Please install it first.${NC}"
    exit 1
fi

# Get AWS account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

echo -e "${YELLOW}📋 AWS Account ID: ${AWS_ACCOUNT_ID}${NC}"
echo -e "${YELLOW}📋 AWS Region: ${AWS_REGION}${NC}"
echo -e "${YELLOW}📋 ECR Registry: ${ECR_REGISTRY}${NC}"

# Login to ECR
echo -e "${YELLOW}🔐 Logging in to Amazon ECR...${NC}"
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}

# Build Docker image
echo -e "${YELLOW}🔨 Building Docker image...${NC}"
docker build -t ${ECR_REPOSITORY}:latest .

# Tag image
echo -e "${YELLOW}🏷️  Tagging image...${NC}"
docker tag ${ECR_REPOSITORY}:latest ${ECR_REGISTRY}/${ECR_REPOSITORY}:latest

# Push image to ECR
echo -e "${YELLOW}⬆️  Pushing image to ECR...${NC}"
docker push ${ECR_REGISTRY}/${ECR_REPOSITORY}:latest

# Update ECS service
echo -e "${YELLOW}🔄 Updating ECS service...${NC}"
aws ecs update-service \
    --cluster ${ECS_CLUSTER} \
    --service ${ECS_SERVICE} \
    --force-new-deployment \
    --region ${AWS_REGION}

# Wait for service to be stable
echo -e "${YELLOW}⏳ Waiting for service to be stable...${NC}"
aws ecs wait services-stable \
    --cluster ${ECS_CLUSTER} \
    --services ${ECS_SERVICE} \
    --region ${AWS_REGION}

# Get service URL
echo -e "${YELLOW}🔍 Getting service URL...${NC}"
ALB_DNS=$(aws elbv2 describe-load-balancers \
    --names sischampions2022-alb \
    --region ${AWS_REGION} \
    --query 'LoadBalancers[0].DNSName' \
    --output text)

echo -e "${GREEN}✅ Deployment completed successfully!${NC}"
echo -e "${GREEN}🌐 Application URL: http://${ALB_DNS}${NC}"

# Check if domain is configured
if [ ! -z "$DOMAIN_NAME" ]; then
    echo -e "${GREEN}🌐 Custom Domain: https://${DOMAIN_NAME}${NC}"
fi

echo -e "${GREEN}📊 Monitor your application in the AWS Console:${NC}"
echo -e "${YELLOW}   - ECS: https://console.aws.amazon.com/ecs/home?region=${AWS_REGION}#/clusters/${ECS_CLUSTER}${NC}"
echo -e "${YELLOW}   - CloudWatch: https://console.aws.amazon.com/cloudwatch/home?region=${AWS_REGION}#logsV2:log-groups/log-group/%2Fecs%2F${ECR_REPOSITORY}${NC}" 