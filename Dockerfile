# 👷 Stage 1: Builder - for installing dependencies
FROM python:3.10-slim as builder
# Use a lightweight Python image to install dependencies

WORKDIR /app
# Set working directory inside the container

RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
# Copy only requirements file to leverage Docker cache

RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# 📦 Stage 2: Final Image - clean and production-ready
FROM python:3.10-slim
# Start a new lightweight base image for final app

RUN adduser --disabled-password --gecos '' appuser

WORKDIR /app
# Set working directory again in final image

ENV PYTHONUNBUFFERED=1 \
    PYTHONPATH="/install" \
    PATH="/install/bin:$PATH"
# Ensure real-time logging (disable output buffering)

COPY --from=builder /install /usr/local
# Copy installed packages from builder stage into global path

COPY . .
# Copy all app code into the container

RUN chown -R appuser:appuser /app

USER appuser

EXPOSE 8000
# Expose port 8000 for external access

CMD ["gunicorn", "notesapp.wsgi:application", "--bind", "0.0.0.0:8000"]
# Run the Django development server on all IPs

