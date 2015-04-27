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

docker run -d -P -m 1G --name db5 -e MYSQL_ROOT_PASSWORD=1234 mysql
docker run -d -P -m 1G --name frontend5 nginx

docker run swarm list token://$SwarmID
