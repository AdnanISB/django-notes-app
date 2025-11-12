# 👷 Stage 1: Builder - for installing dependencies
FROM python:3.10-slim as builder
# Use a lightweight Python image to install dependencies

WORKDIR /app
# Set working directory inside the container

COPY requirements.txt .
# Copy only requirements file to leverage Docker cache

RUN pip install --prefix=/install -r requirements.txt

# 📦 Stage 2: Final Image - clean and production-ready
FROM python:3.10-slim
# Start a new lightweight base image for final app

WORKDIR /app
# Set working directory again in final image

ENV PYTHONUNBUFFERED=1
# Ensure real-time logging (disable output buffering)

COPY --from=builder /install /usr/local
# Copy installed packages from builder stage into global path

COPY . .
# Copy all app code into the container

EXPOSE 8000
# Expose port 8000 for external access

CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
# Run the Django development server on all IPs

