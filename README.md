# Chat Web App (React + Flask + AWS)

This is a modern, real-time-like chat application built with React (Vite) and Flask.

## Project Structure
- `backend/`: Flask REST API.
- `frontend/`: React components with Vite and Framer Motion.
- `infrastructure/`: AWS CloudFormation templates.

## Local Setup

### Backend
1. Navigate to `backend/`
2. Install dependencies: `pip install -r requirements.txt`
3. Run the server: `python app.py` (Default: http://localhost:5000)

### Frontend
1. Navigate to `frontend/`
2. Install dependencies: `npm install`
3. Run dev server: `npm run dev` (Default: http://localhost:5173)

## Deployment to AWS (CloudFormation)

Follow these steps to deploy the application to AWS. You will need the AWS CLI configured.

### 1. Preparation
- Pushed your code to a GitHub repository.
- Created a CodeStar Connection in the AWS Console and noted its **Connection ARN**.

### 2. Deploy Stacks (Order matters)

Run the following commands from the root directory:

#### A. Network Stack
```bash
aws cloudformation deploy --stack-name chat-network --template-file infrastructure/network.yaml
```

#### B. Database Stack
```bash
aws cloudformation deploy --stack-name chat-database --template-file infrastructure/database.yaml
```

#### C. Frontend Hosting Stack
```bash
aws cloudformation deploy --stack-name chat-frontend --template-file infrastructure/frontend-hosting.yaml
```

#### D. Backend Service Stack
*Note: You need the VPC and Subnet ID from the Network Stack output (or Console).*
```bash
aws cloudformation deploy --stack-name chat-backend --template-file infrastructure/backend-service.yaml --parameter-overrides VPCId=<VPC_ID> SubnetId=<SUBNET_ID> --capabilities CAPABILITY_IAM
```

#### E. CI/CD Pipeline Stack
```bash
aws cloudformation deploy --stack-name chat-pipeline --template-file infrastructure/pipeline.yaml --parameter-overrides ConnectionArn=<CONNECTION_ARN> GitHubRepo=<USERNAME/REPO> --capabilities CAPABILITY_IAM
```

### 3. Verification
- Once the pipeline stack is deployed, the first build will start automatically.
- Check the **AWS CodePipeline** console to monitor progress.
- Once completed, access the UI via the CloudFront URL (output of `chat-frontend` stack).

## Tech Stack
- **Frontend**: React, Vite, Framer Motion, Lucide React, Axios.
- **Backend**: Python, Flask, Flask-CORS.
- **Infrastructure**: AWS CloudFormation, ECS Fargate, S3, CloudFront.
