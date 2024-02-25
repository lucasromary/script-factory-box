sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo docker run hello-world

sudo groupadd docker
sudo usermod -aG docker $USER

docker run hello-world

sudo apt-get install nano


mkdir Docker
cd Docker

sudo mkdir -p grafana/data
sudo chmod 777 grafana/data

sudo mkdir -p nodered/data
##sudo chown -R $USER:$USER  nodered/data
sudo chmod 777  nodered/data

sudo mkdir -p mosquitto/config
sudo chmod 777 mosquitto/config
##sudo cat > moquitto/config/mosquitto.conf

echo 'allow_anonymous true
listener 1883
persistence true
persistence_location /mosquitto/data/
log_dest file /mosquitto/log/mosquitto.log' > mosquitto/config/mosquitto.conf


echo "version: '2'
services:
  influxdb:
    image: influxdb:1.8.10
    container_name: influxdb
    restart: always
    network_mode: "host"
    ports:
      - 8086:8086
    volumes:
      -  ${PWD}/influxdb/data:/var/lib/influxdb
    environment:
      - INFLUXDB_ADMIN_ENABLED=true
      - INFLUXDB_ADMIN_USER=admin
      - INFLUXDB_ADMIN_PASSWORD=admin

  grafana:
    image: grafana/grafana
    container_name: grafana
    restart: always
    depends_on:
      - influxdb
    network_mode: "host"
    ports:
      - 3000:3000
    volumes:
      - ${PWD}/grafana/data:/var/lib/grafana

  node-red:
    image: nodered/node-red:latest
    container_name: nodered
    restart: unless-stopped
    depends_on:
      - influxdb
    environment:
      - TZ=Europe/Paris
    network_mode: "host"
    ports:
      - "1880:1880"
    volumes:
      - ${PWD}/nodered/data:/data

  mosquitto:
    image: eclipse-mosquitto
    container_name: mosquitto
    restart : always
    network_mode: "host"
    ports:
      - 1883:1883
      - 9001:9001
    volumes :
      - ${PWD}/mosquitto:/mosquitto/
" > docker-compose.yaml

set PWD =%CD%

echo "#! /bin/bash 
docker compose up" > start.sh

echo "#! /bin/bash 
docker compose down" > stop.sh
