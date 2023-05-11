#!/bin/bash
cd "$(dirname "$0")" || exit

OPENAI_API_KEY=""

NEXTAUTH_SECRET=$(openssl rand -base64 32)

LAN_PROXY=http://192.168.1.6:8889
LOCAL_PROXY=http://127.0.0.1:8889

ENV="NODE_ENV=development\n\
NEXTAUTH_SECRET=$NEXTAUTH_SECRET\n\
NEXTAUTH_URL=http://localhost:3000\n\
OPENAI_API_KEY=$OPENAI_API_KEY\n\
DATABASE_URL=file:../db/db.sqlite\n\
HTTP_PRXY=$LAN_PROXY\n\
HTTPS_PRXY=$LAN_PROXY\n"

cd next
printf $ENV > .env
printf $ENV > .env.docker

docker stop agentgpt
docker rm agentgpt

source .env.docker
docker run -d --name agentgpt -p 3000:3000 -v $(pwd)/db:/app/db agentgpt

cd ..
sleep 10
xdg-open http://localhost:3000