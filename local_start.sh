# Start the database server
echo "Starting the database server..."
cd ./db && ./local_start.sh $1 &
db_server=$!

# Start the platform server
echo "Starting the platform server..."
cd ./platform && ./local_start.sh $1 &
plt_server=$!

# Start the next client
echo "Starting the next client..."
cd ./next && ./local_start.sh $1
cd ../

# Listen for Ctrl+C signal
trap "stop_platform_server" SIGINT
trap "stop_db_server" SIGINT

# Function to stop the database server
function stop_db_server {
  echo "Stopping the database server..."
  docker stop agentgpt_db_local
  docker rm agentgpt_db_local
  kill $db_server
}

# Function to stop the platform server
function stop_platform_server {
  echo "Stopping the platform server..."
  kill $plt_server
}

# Wait for the servers to finish
wait