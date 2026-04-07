#!/bin/bash
set -e

# ── 1. Sistema ────────────────────────────────────────────
yum update -y
yum install -y docker
systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user

# ── 2. Crear directorio de la app ─────────────────────────
mkdir -p /app

# ── 3. Escribir app.py ────────────────────────────────────
cat > /app/app.py << 'EOF'
from flask import Flask, jsonify
import datetime

app = Flask(__name__)

@app.route("/")
def home():
    return jsonify({
        "message": "API operativa — kratosvil",
        "timestamp": datetime.datetime.utcnow().isoformat() + "Z"
    })

@app.route("/health")
def health():
    return jsonify({"status": "ok"})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
EOF

# ── 4. Escribir Dockerfile ────────────────────────────────
cat > /app/Dockerfile << 'EOF'
FROM python:3.11-slim

WORKDIR /app

RUN pip install flask

COPY app.py .

EXPOSE 5000

CMD ["python", "app.py"]
EOF

# ── 5. Build de la imagen ─────────────────────────────────
docker build -t kratosvil-api:latest /app

# ── 6. Correr el contenedor con awslogs driver ────────────
docker run -d \
  --name kratosvil-api \
  --restart always \
  --log-driver=awslogs \
  --log-opt awslogs-region=us-east-1 \
  --log-opt awslogs-group=/lab3/api \
  --log-opt awslogs-create-group=true \
  --log-opt awslogs-stream=api-container \
  -p 80:5000 \
  kratosvil-api:latest
