#!/bin/bash
cd "$(dirname "$0")" || exit

OPENAI_API_KEY=""

NEXTAUTH_SECRET=$(openssl rand -base64 32)

LAN_PROXY=socks5://192.168.1.6:1089
LOCAL_PROXY=socks5://127.0.0.1:1089

ENV="NODE_ENV=development\n\
NEXTAUTH_SECRET=$NEXTAUTH_SECRET\n\
NEXTAUTH_URL=http://localhost:3000\n\
NEXT_PUBLIC_BACKEND_URL=http://localhost:3000\n\
OPENAI_API_KEY=$OPENAI_API_KEY\n\
DATABASE_URL=file:../db/db.sqlite\n\
HTTP_PROXY=$LAN_PROXY\n\
HTTPS_PROXY=$LAN_PROXY\n"

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