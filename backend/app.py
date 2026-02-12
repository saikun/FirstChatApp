from flask import Flask, request, jsonify
from flask_cors import CORS
from flask_socketio import SocketIO, emit
import datetime
import boto3
import uuid
from botocore.exceptions import ClientError
import os

app = Flask(__name__)
app.config['SECRET_KEY'] = 'secret!'
CORS(app)
socketio = SocketIO(app, cors_allowed_origins="*")

# DynamoDB Configuration
TABLE_NAME = os.environ.get('DYNAMODB_TABLE', 'ChatMessages')
REGION = os.environ.get('AWS_REGION', 'ap-northeast-1')

# Initialize DynamoDB client
# Note: For local development, this requires valid AWS credentials or a local DynamoDB instance
try:
    dynamodb = boto3.resource('dynamodb', region_name=REGION)
    table = dynamodb.Table(TABLE_NAME)
    # Check if table exists
    table.load()
    USE_DYNAMO = True
except Exception as e:
    print(f"DynamoDB not available, falling back to in-memory storage. Error: {e}")
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
            socketio.emit('new_message', new_message) # Broadcast to all clients
            return jsonify(new_message), 201
        except ClientError as e:
            return jsonify({"error": str(e)}), 500
    else:
        messages.append(new_message)
        socketio.emit('new_message', new_message) # Broadcast to all clients
        return jsonify(new_message), 201

@socketio.on('connect')
def handle_connect():
    print('Client connected')

@socketio.on('disconnect')
def handle_disconnect():
    print('Client disconnected')

if __name__ == '__main__':
    socketio.run(app, debug=True, port=5000, host='0.0.0.0')
