# Dockerfile — ready to copy
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

# Create a less-privileged user and use it
RUN useradd --create-home appuser || true
USER appuser

# Expose port Railway will map (use 8080)
EXPOSE 8080

# --- DEFAULT CMD ---
# NOTE: ensure your app exposes the callable referenced below.
# If your Flask app defines "app = Flask(__name__)" use app:app
# If it exports an ASGI variable named `asgi_app`, change to app:asgi_app
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "1", "--worker-class", "uvicorn.workers.UvicornWorker", "app:app"]

# Optional healthcheck (uncomment to use)
# HEALTHCHECK --interval=30s --timeout=5s --start-period=10s CMD curl -f http://localhost:8080/ || exit 1
