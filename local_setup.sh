#!/bin/bash
cd "$(dirname "$0")" || exit

cp .local_env ./next/.env
cp .local_env ./next/.env.docker
cp .local_env ./platform/.env
cp .local_env ./platform/.env.docker

cd next

if [ "$1" = "--docker" ]; then
  cd ..
  docker-compose -f ./local-docker-compose.yml up --remove-orphans --build
else
  npm install
  # ./prisma/useSqlite.sh
  # #prisma db push
  # npx prisma db push
  npm run dev
fi
