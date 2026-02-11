# Use official Python image
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Copy requirements and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Expose port 5000
EXPOSE 5000

# Use Gunicorn as production server
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
