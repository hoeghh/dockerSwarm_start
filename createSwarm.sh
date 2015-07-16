clear;

if [ -f /etc/redhat-release ]; then
        sudo setenforce 0
fi

SwarmID=`docker run swarm create`
echo $SwarmID

eval $(docker-machine env --swarm swarm-master)

docker-machine create \
    -d virtualbox \
    --swarm \
    --swarm-master \
    --swarm-discovery token://$SwarmID \
    swarm-master

docker-machine create \
    -d virtualbox \
    --swarm \
    --swarm-discovery token://$SwarmID \
    swarm-node-00

echo "SwarmID=$SwarmID" > SwarmIDs

eval $(docker-machine env --swarm swarm-master)

docker info

sleep 5

docker-compose up
docker run swarm list token://$SwarmID
