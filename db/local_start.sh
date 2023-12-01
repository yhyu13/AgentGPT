DOCKER_ARGS="--remove-orphans"
if [ "$1" == "build" ]; then 
    DOCKER_ARGS+=" --build"
fi

docker stop agentgpt_db_local
docker rm agentgpt_db_local
docker compose up $DOCKER_ARGS | tee ./db_docker.log