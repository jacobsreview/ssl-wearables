FROM ubuntu:latest
LABEL authors="jacob"

ENTRYPOINT ["top", "-b"]

# Use official Python 3.7 image
FROM python:3.7-slim

# Set environment variables to avoid issues with Python
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Set the working directory in the container
WORKDIR /app

# Copy the requirements file into the container
COPY req.txt .

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    gcc \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
RUN pip install --upgrade pip \
    && pip install Cython>=0.29.36 \
    && pip install -r req.txt


# Copy the rest of the application code
COPY . .

# Expose a port if needed (for Jupyter Notebook or similar)
EXPOSE 8888

# Default command
CMD ["python3"]
