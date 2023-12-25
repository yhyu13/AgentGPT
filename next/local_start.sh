
cp ../.env ./
source ./.env
./wait-for-db.sh $DATABASE_HOST $DATABASE_PORT

NPM_HOME=/home/hangyu5/.nvm/versions/node/v18.19.0/bin/
export PATH="${NPM_HOME}:${PATH}"

npx prisma migrate deploy --name init
npx prisma db push
npx prisma generate

if [ "$1" == "build" ]; then 
    npm install
    npm run build
fi

npm run start 2>&1 | tee ./local_next.log
#npm run dev 2>&1 | tee ./local_next.log
