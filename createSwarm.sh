docker-machine create -d virtualbox local
eval "$(docker-machine env local)"

SwamID=$(docker run swarm create)

docker-machine create \
    -d virtualbox \
    --swarm \
    --swarm-master \
    --swarm-discovery token://$SwamID \
    swarm-master

docker-machine create \
    -d virtualbox \
    --swarm \
    --swarm-discovery token://$SwamID \
    swarm-node-00

eval $(docker-machine env --swarm swarm-master)

echo "SwarmID=$SwarmID \
      SwarmMasterID=$SwarmMasterID \
      SwarmSlaveID=$SwarmSlaveID" > SwarmIDs

docker info
