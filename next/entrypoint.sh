#!/bin/env sh

source .env

# # Ensure DB is available before running Prisma commands
./wait-for-db.sh $db $DATABASE_PORT

# Run Prisma commands
if [[ ! -f "/app/prisma/${DATABASE_URL:5}" ]]; then
  npx prisma migrate deploy --name init
  npx prisma db push
fi

# Generate Prisma client
npx prisma generate

# run cmd
exec "$@"
