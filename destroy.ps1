# AWS Teardown Script for Chat App
# Usage: .\destroy.ps1

$ErrorActionPreference = "Stop"

Write-Host "--- Starting Teardown of Chat App ---" -ForegroundColor Cyan

# Function to get physical resource ID and empty bucket if it's an S3 bucket
function cleaning-S3Bucket {
    param (
        [string]$StackName,
        [string]$LogicalResourceId
    )
    try {
        $bucketName = aws cloudformation describe-stack-resource --stack-name $StackName --logical-resource-id $LogicalResourceId --query "StackResourceDetail.PhysicalResourceId" --output text
        if ($LASTEXITCODE -eq 0 -and $bucketName -ne "None" -and $bucketName -ne $null) {
            Write-Host "Emptying bucket: $bucketName for stack $StackName ($LogicalResourceId)" -ForegroundColor Yellow
            # check if bucket exists
            aws s3 ls "s3://$bucketName" > $null 2>&1
            if ($LASTEXITCODE -eq 0) {
                aws s3 rb "s3://$bucketName" --force
            }
            else {
                Write-Host "Bucket $bucketName not found or accessible." -ForegroundColor DarkGray
            }
        }
    }
    catch {
        Write-Warning "Could not process bucket for $LogicalResourceId in stack $StackName. It might not exist."
    }
}

# Function to delete ECR repository (force delete images)
function cleaning-ECR {
    param (
        [string]$StackName,
        [string]$LogicalResourceId
    )
    try {
        $repoName = aws cloudformation describe-stack-resource --stack-name $StackName --logical-resource-id $LogicalResourceId --query "StackResourceDetail.PhysicalResourceId" --output text
        if ($LASTEXITCODE -eq 0 -and $repoName -ne "None" -and $repoName -ne $null) {
            Write-Host "Deleting ECR Repository: $repoName for stack $StackName ($LogicalResourceId)" -ForegroundColor Yellow
            aws ecr delete-repository --repository-name $repoName --force
        }
    }
    catch {
        Write-Warning "Could not process ECR repo for $LogicalResourceId in stack $StackName. It might not exist."
    }
}

# 1. Pipeline Stack (Has PipelineBucket)
Write-Host "Step 1: Deleting CI/CD Pipeline Stack..." -ForegroundColor Yellow
cleaning-S3Bucket -StackName "chat-pipeline" -LogicalResourceId "PipelineBucket"
aws cloudformation delete-stack --stack-name chat-pipeline
Write-Host "Waiting for chat-pipeline deletion..."
aws cloudformation wait stack-delete-complete --stack-name chat-pipeline

# 2. Frontend Hosting Stack (Has FrontendBucket)
Write-Host "Step 2: Deleting Frontend Hosting Stack..." -ForegroundColor Yellow
cleaning-S3Bucket -StackName "chat-frontend" -LogicalResourceId "FrontendBucket"
aws cloudformation delete-stack --stack-name chat-frontend
Write-Host "Waiting for chat-frontend deletion..."
aws cloudformation wait stack-delete-complete --stack-name chat-frontend

# 3. Backend Service Stack (Has ECR Repository)
# Note: Ensure dependent stacks (frontend/pipeline) are gone first as they use Exported values.
Write-Host "Step 3: Deleting Backend Service Stack..." -ForegroundColor Yellow
cleaning-ECR -StackName "chat-backend" -LogicalResourceId "ECRRepository"
aws cloudformation delete-stack --stack-name chat-backend
Write-Host "Waiting for chat-backend deletion..."
aws cloudformation wait stack-delete-complete --stack-name chat-backend

# 4. Database Stack
Write-Host "Step 4: Deleting Database Stack..." -ForegroundColor Yellow
aws cloudformation delete-stack --stack-name chat-database
Write-Host "Waiting for chat-database deletion..."
aws cloudformation wait stack-delete-complete --stack-name chat-database

# 5. Network Stack
Write-Host "Step 5: Deleting Network Stack..." -ForegroundColor Yellow
aws cloudformation delete-stack --stack-name chat-network
Write-Host "Waiting for chat-network deletion..."
aws cloudformation wait stack-delete-complete --stack-name chat-network

Write-Host "--- Teardown Complete ---" -ForegroundColor Green
