
cp ../.env ./
source ./.env
./wait-for-db.sh $DATABASE_HOST $DATABASE_PORT

npx prisma migrate deploy --name init
npx prisma db push
npx prisma generate

if [ "$1" == "build" ]; then 
    npm install
    npm run build
fi

npm run dev | tee ./local_next.log
