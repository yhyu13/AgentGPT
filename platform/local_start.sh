eval "$(conda shell.bash hook)"
conda activate agentgpt


cp ../.env ./
source ./.env

export REWORKD_PLATFORM_HOST=$HOST_IP
export REWORKD_PLATFORM_DB_HOST=$REWORKD_PLATFORM_DATABASE_HOST
export REWORKD_PLATFORM_DB_PORT=3307
export REWORKD_PLATFORM_DB_USER=reworkd_platform
export REWORKD_PLATFORM_DB_PASS=reworkd_platform
export REWORKD_PLATFORM_DB_BASE=reworkd_platform
export REWORKD_PLATFORM_DB_SSL=false


if [ "$1" == "build" ]; then 
    poetry install
fi

poetry run python -m reworkd_platform 2>&1 | tee ./local_platform.log