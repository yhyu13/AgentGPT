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
HTTP_PRXY=$LAN_PROXY\n\
HTTPS_PRXY=$LAN_PROXY\n"

cd next
printf $ENV > .env
printf $ENV > .env.docker

docker stop agentgpt
docker rm agentgpt

source .env.docker
#NO_CACHE="--no-cache"
NO_CACHE=""
docker build $NO_CACHE --build-arg NODE_ENV=$NODE_ENV --build-arg LOCAL_PROXY=$LOCAL_PROXY --network host -f local_Dockerfile -t agentgpt . 
docker run -d --name agentgpt -p 3000:3000 -v $(pwd)/db:/app/db agentgpt --network host

cd ..
sleep 10
xdg-open http://localhost:3000