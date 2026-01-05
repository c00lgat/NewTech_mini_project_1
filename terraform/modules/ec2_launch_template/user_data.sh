#!/bin/bash
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh


mkdir /flask-app


cat > /flask-app/docker-compose.yml <<'EOF'
services:
  app:
    image: ${IMAGE_URI}
    ports:
      - "5000:5000"
    restart: unless-stopped
EOF
