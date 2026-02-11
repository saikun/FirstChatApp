# AWS Deployment Script for Chat App
# Usage: .\deploy.ps1 -ConnectionArn "arn:aws:codeconnections:..." -GitHubRepo "username/repo"

param (
    [Parameter(Mandatory = $true)]
    [string]$ConnectionArn,
    
    [Parameter(Mandatory = $true)]
    [string]$GitHubRepo
)

$ErrorActionPreference = "Stop"

Write-Host "--- Starting Deployment of Chat App ---" -ForegroundColor Cyan

# 1. Network Stack
Write-Host "Step 1: Deploying Network Stack..." -ForegroundColor Yellow
aws cloudformation deploy `
    --stack-name chat-network `
    --template-file infrastructure/network.yaml

# Get outputs for the next steps
$vpcId = aws cloudformation describe-stacks --stack-name chat-network --query "Stacks[0].Outputs[?OutputKey=='VPCId'].OutputValue" --output text
$subnet1Id = aws cloudformation describe-stacks --stack-name chat-network --query "Stacks[0].Outputs[?OutputKey=='PublicSubnet1Id'].OutputValue" --output text
$subnet2Id = aws cloudformation describe-stacks --stack-name chat-network --query "Stacks[0].Outputs[?OutputKey=='PublicSubnet2Id'].OutputValue" --output text

# 2. Database Stack
Write-Host "Step 2: Deploying Database Stack..." -ForegroundColor Yellow
aws cloudformation deploy `
    --stack-name chat-database `
    --template-file infrastructure/database.yaml

# 3. Frontend Hosting Stack
Write-Host "Step 3: Deploying Frontend Hosting Stack..." -ForegroundColor Yellow
aws cloudformation deploy `
    --stack-name chat-frontend `
    --template-file infrastructure/frontend-hosting.yaml

# 4. Backend Service Stack
Write-Host "Step 4: Deploying Backend Service Stack..." -ForegroundColor Yellow
aws cloudformation deploy `
    --stack-name chat-backend `
    --template-file infrastructure/backend-service.yaml `
    --parameter-overrides VPCId=$vpcId Subnet1Id=$subnet1Id Subnet2Id=$subnet2Id `
    --capabilities CAPABILITY_IAM

# 5. CI/CD Pipeline Stack
Write-Host "Step 5: Deploying CI/CD Pipeline Stack..." -ForegroundColor Yellow
aws cloudformation deploy `
    --stack-name chat-pipeline `
    --template-file infrastructure/pipeline.yaml `
    --parameter-overrides ConnectionArn=$ConnectionArn GitHubRepo=$GitHubRepo `
    --capabilities CAPABILITY_IAM

Write-Host "--- Deployment Commands Submitted Successfully ---" -ForegroundColor Green
Write-Host "Please check AWS CodePipeline console for the build progress." -ForegroundColor Cyan
