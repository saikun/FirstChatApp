from flask import Flask, request, jsonify
from flask_cors import CORS
import datetime
import boto3
import uuid
from botocore.exceptions import ClientError
import os

app = Flask(__name__)
CORS(app)

# DynamoDB Configuration
TABLE_NAME = os.environ.get('DYNAMODB_TABLE', 'ChatMessages')
REGION = os.environ.get('AWS_REGION', 'ap-northeast-1')

import traceback

# Initialize DynamoDB client
# Note: For local development, this requires valid AWS credentials or a local DynamoDB instance
try:
    dynamodb = boto3.resource('dynamodb', region_name=REGION)
    table = dynamodb.Table(TABLE_NAME)
    # Check if table exists
    table.load()
    USE_DYNAMO = True
    print(f"Successfully connected to DynamoDB table: {TABLE_NAME}")
except Exception as e:
    print(f"ERROR: Failed to connect to DynamoDB.")
    print(f"Region: {REGION}, Table: {TABLE_NAME}")
    print(f"Error Details: {str(e)}")
    traceback.print_exc()
    USE_DYNAMO = False
    messages = [
        {"id": "1", "user": "System", "text": "Welcome to the chat! (In-Memory Fallback)", "timestamp": datetime.datetime.now().isoformat()}
    ]

@app.route('/api/messages', methods=['GET'])
def get_messages():
    if USE_DYNAMO:
        try:
            response = table.scan()
            items = response.get('Items', [])
            # Sort by timestamp
            items.sort(key=lambda x: x['timestamp'])
            return jsonify(items)
        except ClientError as e:
            return jsonify({"error": str(e)}), 500
    else:
        return jsonify(messages)

@app.route('/api/messages', methods=['POST'])
def post_message():
    data = request.json
    if not data or 'user' not in data or 'text' not in data:
        return jsonify({"error": "Invalid data"}), 400
    
    new_message = {
        "id": str(uuid.uuid4()),
        "user": data['user'],
        "text": data['text'],
        "timestamp": datetime.datetime.now().isoformat()
    }

    if USE_DYNAMO:
        try:
            table.put_item(Item=new_message)
            return jsonify(new_message), 201
        except ClientError as e:
            return jsonify({"error": str(e)}), 500
    else:
        messages.append(new_message)
        return jsonify(new_message), 201

if __name__ == '__main__':
    app.run(debug=True, port=5000)
