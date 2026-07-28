## LAMP Project using Docker Hardened Images <br> &emsp; dhi.io/httpd – dhi.io/mysql – dhi.io/php


### Introduction:
This LAMP project using Docker Hardened Images:  
  - Apache image: [dhi.io/httpd:2.4.68-debian13](https://hub.docker.com/hardened-images/catalog/dhi/httpd)  
  - MySQL image: [dhi.io/mysql:lts-debian13](https://hub.docker.com/hardened-images/catalog/dhi/mysql)  
  - PHP image: [dhi.io/php:8.5.8-debian13-fpm](https://hub.docker.com/hardened-images/catalog/dhi/php)

<br/>

Files provided:  
```
├── certs/  
│   ├── httpd/  
│   └── mysql/
├── cleanup.sh  
├── docker-compose.yml
├── .env  
├── etc/  
│   ├── httpd.conf  
│   ├── httpd-ssl.conf  
│   ├── my.cnf  
│   └── php.ini  
├── htdocs/
│   ├── database.php  
│   ├── index.php  
│   ├── module_list.php  
│   ├── upload.php  
│   └── uploads/  
├── log/  
│   └── httpd/  
├── mysql_data/  
├── setup.sh  
└── versions/  
    ├── httpd:2.4.68-debian13/  
    │   └── Dockerfile  
    ├── mysql:lts-debian13/  
    │   └── Dockerfile  
    └── php:8.5.8-debian13-fpm/  
        └── Dockerfile
```
- **.env**: Environment file
- **cleanup.sh**: a script to delete all project containers and images
- **setup.sh**:
   - Generate SSL/TLS self-signed certificates for **httpd** server
   - Modify httpd.conf and httpd-ssl.conf to work with SSL certificates 
   - Generate SSL/TLS Certificates for **mysql** server
   - Modify php.ini for **php-fpm** server  
- **docker-compose.yml**:
   - Used to create **httpd**, **mysql** and **php-fpm** containers.
   - Modify it if neccessary.
- **./etc/***:  
   - All configuration files - **httpd.conf**, **httpd-ssl.conf**, **my.cnf**, and **php.ini** - are bound to the host system as bind mounts.
   - Modify them if necessary.  
- **./htdocs**: Document root mounted directory
   - **index.php**: An example **index.php** web page
   - **database.php**: An example of database upload/insert/query web page
   - **module_list.php**: List of all installed php modules page
   - **upload.php**: An example of file upload web page
- **./mysql_data/**  
   - A directory containing mysql data  

<br/>

### Step 1: Download the repository
```
git clone https://github.com/hiepdng/docker_build_DHI_LAMP_Project.git
```

### Step 2: Pre-configuration
- Setting up: directories, certificates and configuration files 
```
cd docker_build_DHI_LAMP_Project
sh setup.sh
```

### Step 3: Building httpd, mysql, php-fpm images and Running httpd, mysql, php-fpm containers
```
docker compose build --no-cache
docker compose up -d
```

<br/><br/>

### Checking:
To visit your page, to to https://localhost/index.php

<br/>

### Cleaup your LAMP Project:
```
sh cleanup.sh
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

