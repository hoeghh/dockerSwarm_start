clear;

if [ -f /etc/redhat-release ]; then
        sudo setenforce 0
fi
#boot2dockerVersion="v"$(docker --version |cut -d"," -f1|cut -d" " -f3)
#If it fails, use these acording to your local docker client version
#boot2dockerVersion="v1.5.0"
#boot2dockerVersion="v1.6.2"
boot2dockerVersion="v1.7.1"

SwarmID=`docker run swarm create`
echo $SwarmID
isoHome="/home/hoeghh/Development/dockerSwarm_start"
docker-machine create \
    -d virtualbox \
    --virtualbox-boot2docker-url https://github.com/boot2docker/boot2docker/releases/download/$boot2dockerVersion/boot2docker.iso \
    --swarm \
    --swarm-master \
    --swarm-discovery token://$SwarmID \
    swarm-master

docker-machine create \
    -d virtualbox \
    --virtualbox-boot2docker-url https://github.com/boot2docker/boot2docker/releases/download/$boot2dockerVersion/boot2docker.iso \
    --swarm \
    --swarm-discovery token://$SwarmID \
    swarm-node-00

echo "SwarmID=$SwarmID" > SwarmIDs

eval $(docker-machine env --swarm swarm-master)

sleep 15

docker info

#docker-compose up
#docker run swarm list token://$SwarmID
