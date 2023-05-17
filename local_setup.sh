#!/bin/bash
cd "$(dirname "$0")" || exit

source .local_env

ENV="NODE_ENV=development\n\
NEXTAUTH_SECRET=$NEXTAUTH_SECRET\n\
NEXTAUTH_URL=http://localhost:3000\n\
OPENAI_API_KEY=$OPENAI_API_KEY\n\
DATABASE_URL=file:../db/db.sqlite\n\
SERP_API_KEY=$SERP_API_KEY\n\
HTTP_PROXY=$HTTP_PROXY\n\
HTTPS_PROXY=$HTTPS_PROXY\n"

printf $ENV > .env

if [ "$1" = "--docker" ]; then
  printf $ENV > .env.docker
  source .env.docker
  docker build --build-arg NODE_ENV=$NODE_ENV -t agentgpt .
  docker run -d --name agentgpt -p 3000:3000 -v $(pwd)/db:/app/db agentgpt
elif [ "$1" = "--docker-compose" ]; then
  docker-compose up -d --remove-orphans
else
  printf $ENV > .env
  ./prisma/useSqlite.sh
  npm install
  npm run dev --inspect
fi
