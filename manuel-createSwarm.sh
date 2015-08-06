SwarmID=$(docker run swarm create)

if [ ! -z "$SwarmID" ]; then
  echo "SwarmID = $SwarmID"

  docker-machine create --driver virtualbox luci-swarm-master
  docker-machine ssh luci-swarm-master<<-\SSH
  sudo sh -c 'echo -e " \
    EXTRA_ARGS=\"--label provider=virtualbox\" \n \
    DOCKER_HOST=\"-H tcp://0.0.0.0:2376\" \n \
    DOCKER_STORAGE=aufs \n \
    DOCKER_TLS=no" > /var/lib/boot2docker/profile'
SSH
  docker-machine restart luci-swarm-master

  docker-machine create --driver virtualbox luci-swarm-node-01
  docker-machine ssh luci-swarm-node-01<<-\SSH
  sudo sh -c 'echo -e " \
    EXTRA_ARGS=\"--label provider=virtualbox\" \n \
    DOCKER_HOST=\"-H tcp://0.0.0.0:2376\" \n \
    DOCKER_STORAGE=aufs \n \
    DOCKER_TLS=no" > /var/lib/boot2docker/profile'
SSH
  docker-machine restart luci-swarm-node-01

  # Get ips of the master node and start swarm
  masterIP=$(docker-machine ls|grep "swarm-master" |cut -d "/" -f3| cut -d":" -f1)
  echo "masterIP = $masterIP"
  docker-machine ssh luci-swarm-master "docker run -d -p 3375:2375 swarm manage token://$SwarmID"
  docker-machine ssh luci-swarm-master "docker run -d swarm join --addr=$masterIP token://$SwarmID"


  # Get ips of the node and start swarm
  node01IP=$(docker-machine ls|grep "swarm-node-01" |cut -d "/" -f3)
  docker-machine ssh luci-swarm-node-01 "docker run -d swarm join --addr=$node01IP token://$SwarmID"

  sleep 10

  # Examples (alter localhost to swarm-master ip, if used)
  docker -H tcp://$masterIP:3375 info
  #docker -H tcp://$masterIP:3375 run -d -p 80:80 nginx
  #docker -H tcp://$masterIP:3375 run -d -p 80:80 nginx
  #docker -H tcp://$masterIP:3375 ps
else
  echo "Fatal: Did not get a SwarmID"
fi


