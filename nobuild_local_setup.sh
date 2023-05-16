#!/bin/bash
cd "$(dirname "$0")" || exit

source .local_env

ENV="NODE_ENV=development\n\
NEXTAUTH_SECRET=$NEXTAUTH_SECRET\n\
NEXTAUTH_URL=http://localhost:3000\n\
NEXT_PUBLIC_BACKEND_URL=http://localhost:3000\n\
OPENAI_API_KEY=$OPENAI_API_KEY\n\
DATABASE_URL=file:../db/db.sqlite\n\
HTTP_PROXY=$LOCAL_PROXY\n\
HTTPS_PROXY=$LOCAL_PROXY\n\
NEXT_PUBLIC_WEB_SEARCH_ENABLED=true\n\
SERP_API_KEY=$SERP_API_KEY\n"

echo $ENV

cd next
printf $ENV > .env
printf $ENV > .env.docker

cd ..
docker stop agentgpt
docker rm agentgpt

docker-compose -f ./local-docker-compose.yml up -d --remove-orphans

cd ..
sleep 10
xdg-open http://localhost:3000