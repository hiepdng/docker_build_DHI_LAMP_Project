## LAMP Project using Docker Hardened Images <br> &emsp; dhi.io/httpd – dhi.io/mysql – dhi.io/php


### Introduction:
This repository is used to create an MySQl server based on [MySQL Docker Hardened Image (DHI)](https://hub.docker.com/hardened-images/catalog/dhi/mysql)  

Files provided:  
- scripts.sh:
  - Create mount directory on the host system
- Dockerfile:
  - Used to create your own local image. Modify it if neccessary.
- docker-compose.yml:
  - Used to create the container. Modify it if neccessary.

<br/>

### Step 1: Pre-configuration
- Run the script.sh:  
`$ sh script.sh`

### Step 2: Building a PHP-FPM image
`$ docker build -t dhi.io/mysql:lts-debian13 .`   

### Step 3: Runing a MySQL container
```
$ docker run --name my-mysql \
  -e MYSQL_ROOT_PASSWORD=my-secret-pw \
  -v /home/app/mysql:/var/lib/mysql \
  -d dhi.io/mysql:lts-debian13 mysqld
```   
or  
```
-Setup Docker named volume: run once
$ docker volume create --driver local \
  --opt type=none \
  --opt o=bind \
  --opt device=/home/app/mysql \
  mysql-data

-Run a container:
$ docker compose up -d`  
```
<br/><br/>

### Testing Secure (SSL) MySQl connections:
you will create two containers and make Mysql connections between them.
```
-Create your own network;
$ docker network create --subnet=172.1.0.0/16 mynet123
$ docker network ls                                      # List all network
$ docker netowrk inspect mynet123                        # Inspect network mynet123


-Create two containers (server and client) with their own ip addresses:
$ docker run --name server \
  -e MYSQL_ROOT_PASSWORD=my-secret-pw \
  --network mynet123  --ip 172.1.0.2 \
  --hostname server.example.con \
  --add-host "client.example.com client":172.1.0.3 \
  -p 3306:3306 \
  -d dhi.io/mysql:lts-debian13  mysqld

$ docker run --name client \
  -e MYSQL_ROOT_PASSWORD=my-secret-pw \
  --network mynet123  --ip 172.1.0.3 \
  --hostname client.example.con \
  --add-host "server.example.com server":172.1.0.2 \
  -p 33060:33060 \
  -d dhi.io/mysql:lts-debian13  mysqld


-From client container, make MySQL connections to server container:
$ docker exec -it client mysql -h server -uroot -p
mysql> status;


-Remove your network and containers
$ docker network ls
$ docker network rm mynet123       # Delete network mynet123
$ docker rm -f server client       # Delete sever client containers
```

<br/><br/>

### Some other docker MysQl commands:
```
-Running the container
$ docker run --name=my-mysql \
  -e MYSQL_ROOT_PASSWORD=my-secret-pw \
  -d dhi.io/mysql:lts-debian13 mysqld

-Running the container with options
$ docker run --name my-mysql \
  -e MYSQL_ROOT_PASSWORD=my-secret-pw \
  -e MYSQL_OPTIONS="--max_connections=50 --connect_timeout=20" \
  -d dhi.io/mysql:lts-debian13  mysqld

-Run container shell:
$ docker exec -it <containerID> bash
or
$ docker run -it -e MYSQL_ROOT_PASSWORD=my-secret-pw  dhi.io/mysql:lts-debian13 bash

$ docker run --rm -e MYSQL_ROOT_PASSWORD=my-secret-pw dhi.io/mysql:lts-debian13 mysql --help     # Show mysql options
$ docker run --rm -e MYSQL_ROOT_PASSWORD=my-secret-pw dhi.io/mysql:lts-debian13 mysql --version  # show mysql version

# Login mysql shell:
$ docker exec -it <containerID> mysql -uroot -p
$ docker exec -it <containerID> mysql -uroot -p -e "SHOW VARIABLES LIKE 'max_connections';"

# Create a database:
$ docker exec -it <containerID> mysql -uroot -p -e "CREATE DATABASE mydb;"

# Create a user with privileges
$ docker exec -it <containerID> mysql -uroot -p -e \
  "CREATE USER 'myuser'@'%' IDENTIFIED BY 'mypassword'; \
   GRANT ALL PRIVILEGES ON mydb.* TO 'myuser'@'%';"

# Run sql scripts
$ docker exec -i <containerID> mysql -uroot -pmy-secret-pw  < /path/to/init.sql

```

<br/>

### Basic docker commands:
```
$ docker pull <image_name>       – Pulls an image from dockerhub
$ docker image ls                – Lists all locally stored Docker images on your host system
$ docker run -d <image_name>     – Creates & starts a new Docker container from animage and runs it in the background
  docker run -it -d --name image_name <image_name>
$ docker ps                      – Lists all currently running Docker container IDs on your system
$ docker ps -a                   – lists all Docker container IDs on your system, regardless of their current status. 
$ docker stop <containerID>      – Gracefully shuts down a running Docker container
$ docker start <containerID>     – Resumes and boots up stopped Docker container
$ docker rm <containerID>        – Remove Docker container

$ docker exec -it <containerID> bash – Opens an interactive command-line terminal (Bash) inside a Docker
                                       container that is already running.
```

<br/>

