#!/bin/bash
cd "$(dirname "$0")" || exit

cp .local_env ./next/.env
cp .local_env ./next/.env.docker
cp .local_env ./platform/.env
cp .local_env ./platform/.env.docker

docker-compose -f ./local-docker-compose.yml up --remove-orphans