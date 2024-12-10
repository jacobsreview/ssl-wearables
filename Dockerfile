# ============================
# Stage 1: Builder
# ============================
FROM python:3.7-slim-bullseye AS builder

# Set the working directory
WORKDIR /app

# Environment settings for cleaner logging, no cache files, and enhanced pip
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/opt/venv/bin:$PATH" \
    CFLAGS="-O2" \
    CRYPTOGRAPHY_DONT_BUILD_RUST=1

# Install build dependencies only required for building
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    pkg-config \
    gcc \
    libjpeg-dev \
    zlib1g-dev \
    gfortran \
    libopenblas-dev \
    libfreetype6-dev \
    libpng-dev \
    libopenjp2-7 \
    libtiff5 \
    liblapack-dev \
    libbz2-dev \
    liblzma-dev \
    libz-dev \
    libreadline-dev \
    libsqlite3-dev \
    python3-dev \
    python3-venv \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create a virtual environment
RUN python3 -m venv /opt/venv

# Activate the virtual environment
ENV PATH="/opt/venv/bin:$PATH"

# Upgrade pip and install dependencies that require compilation
RUN pip install --upgrade pip==22.3.1
RUN pip install --upgrade pip setuptools wheel

# Copy the requirements file
COPY req.txt .

# Allow pip to build from source if binary wheels are not available
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --no-cache-dir --prefer-binary -r req.txt


# ============================
# Stage 2: Final Image
# ============================
FROM python:3.7-slim-bullseye

# Create a non-root user for security
RUN useradd --create-home appuser

# Set the working directory
WORKDIR /app

# Copy the virtual environment from the builder image
COPY --from=builder /opt/venv /opt/venv

# Activate the virtual environment
ENV PATH="/opt/venv/bin:$PATH" \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Copy the application source code
COPY . .

# Change ownership of the app directory to the non-root user
RUN chown -R appuser:appuser /app

# Switch to non-root user for security
USER appuser

# Default command to run the application
CMD ["python", "mtl.py"]
