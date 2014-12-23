#! /bin/bash


sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
sudo sh -c "echo deb https://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list"
sudo apt-get update -y
sudo apt-get install -y lxc-docker

sudo mkdir -p /data/postgresql

sudo docker run -d -e VIRTUAL_PORT=5432    -e VIRTUAL_HOST=taiga.ragesheep.com -p 5432:5432 --name postgres -v /data/postgresql:/var/lib/postgresql/data postgres
sudo docker run -d -e VIRTUAL_PORT=80,8000 -e VIRTUAL_HOST=taiga.ragesheep.com -p 8000:8000 -p 80 --name taiga-front --link taiga-back:taiga-back ipedrazas/taiga-front
sudo docker run -d -e VIRTUAL_PORT=8001    -e VIRTUAL_HOST=taiga.ragesheep.com -p 8001:8001 --name taiga-back --link postgres:postgres ipedrazas/taiga-back


sudo docker run -it --link postgres:postgres --rm postgres sh -c "su postgres --command 'createuser -h "'$POSTGRES_PORT_5432_TCP_ADDR'" -p "'$POSTGRES_PORT_5432_TCP_PORT'" -d -r -s taiga'"
sudo docker run -it --link postgres:postgres --rm postgres sh -c "su postgres --command 'createdb -h "'$POSTGRES_PORT_5432_TCP_ADDR'" -p "'$POSTGRES_PORT_5432_TCP_PORT'" -O taiga taiga'";
sudo docker run -it --rm --link postgres:postgres ipedrazas/taiga-back bash regenerate.sh


sudo docker stop taiga-front
sudo docker stop taiga-back
sudo docker stop postgres
