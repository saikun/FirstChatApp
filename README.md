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

## Deployment (AWS CloudFormation)
The `infrastructure/` directory contains templates for:
1. `network.yaml`: VPC and Subnets.
2. `backend-service.yaml`: ECS Fargate service.
3. `frontend-hosting.yaml`: S3 + CloudFront.

## Tech Stack
- **Frontend**: React, Vite, Framer Motion, Lucide React, Axios.
- **Backend**: Python, Flask, Flask-CORS.
- **Infrastructure**: AWS CloudFormation, ECS Fargate, S3, CloudFront.
