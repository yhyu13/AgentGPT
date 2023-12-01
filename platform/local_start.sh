eval "$(conda shell.bash hook)"
conda activate agentgpt

export REWORKD_PLATFORM_HOST=0.0.0.0
export REWORKD_PLATFORM_DB_HOST=0.0.0.0
export REWORKD_PLATFORM_DB_PORT=3307
export REWORKD_PLATFORM_DB_USER=reworkd_platform
export REWORKD_PLATFORM_DB_PASS=reworkd_platform
export REWORKD_PLATFORM_DB_BASE=reworkd_platform
export REWORKD_PLATFORM_DB_SSL=false

cp ../.env ./
source ./.env

if [ "$1" == "build" ]; then 
    poetry install
fi

poetry run python -m reworkd_platform | tee ./local_platform.log