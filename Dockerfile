# Dockerfile — edited to create uploads dir and allow PORT expansion
FROM python:3.11-slim

# --- metadata / working dir ---
LABEL maintainer="you@example.com"
WORKDIR /app

# Prevent Python from writing .pyc files and make stdout/stderr unbuffered
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Optional: install system deps required by some packages (uncomment if needed)
# RUN apt-get update && \
#     apt-get install -y --no-install-recommends build-essential libffi-dev libssl-dev && \
#     rm -rf /var/lib/apt/lists/*

# Copy Python requirements first for better layer caching
COPY requirements.txt /app/requirements.txt

# Upgrade pip and install Python dependencies
RUN python -m pip install --upgrade pip setuptools wheel && \
    pip install --no-cache-dir -r /app/requirements.txt

# Copy application code
COPY . /app

# Create uploads dir and ensure it's owned by the app user (fixes PermissionError)
RUN mkdir -p /app/uploads

# Create a less-privileged user and make them owner of /app
RUN useradd --create-home appuser || true
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Expose port Railway will map (use 8080)
EXPOSE 8080

# --- DEFAULT CMD ---
# Use shell form so $PORT (if supplied) expands; default to 8080
CMD gunicorn --bind 0.0.0.0:${PORT:-8080} --workers 1 --worker-class uvicorn.workers.UvicornWorker app:app

# Optional healthcheck (uncomment to use)
# HEALTHCHECK --interval=30s --timeout=5s --start-period=10s CMD curl -f http://localhost:8080/ || exit 1
