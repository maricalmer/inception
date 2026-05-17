# Developer Documentation

## Overview

This project implements a multi-container infrastructure using Docker Compose.

The architecture is composed of these services:

* NGINX (web server + SSL)
* WordPress (PHP-FPM)
* MariaDB (database)
* Redis (cache)
* Adminer (database administration)
* Static site (bonus web service)

Each service runs in its own container and communicates through a Docker network.

---

## Environment Setup From Scratch

### Prerequisites

Install the following tools on the VM:

* Docker
* Docker Compose
* Make
* Git

### Clone the repository

```sh
git clone https://github.com/maricalmer/inception inception
cd inception
```

### Configure environment variables

Copy the example file and edit the non-sensitive runtime values:

```sh
cp srcs/.env.example srcs/.env
```

Then edit `srcs/.env`.

The `.env` file stores values such as:

* `DOMAIN_NAME`
* `MYSQL_DATABASE`
* `MYSQL_USER`
* WordPress usernames and emails
* Redis host and port

Do not store passwords in `.env`.

### Configure Docker secrets

Create the local secret files expected by `srcs/docker-compose.yaml`:

```sh
mkdir -p secrets
printf '%s' 'your_database_password' > secrets/mysql_password.txt
printf '%s' 'your_database_root_password' > secrets/mysql_root_password.txt
printf '%s' 'your_wordpress_admin_password' > secrets/wp_admin_password.txt
printf '%s' 'your_wordpress_user_password' > secrets/wp_user_password.txt
```

These files are ignored by Git. At runtime, Docker Compose mounts them inside the containers under `/run/secrets/`.

---

## Architecture

```id="v9jz3g"
Client (browser)
        ↓ HTTPS (443)
     NGINX
        ↓ FastCGI (9000)
   WordPress (php-fpm)
        ↓ MySQL (3306)
      MariaDB
```

---

## Docker

### Containers

Each service runs in an isolated container:

* `nginx`
* `wordpress`
* `mariadb`
* `redis`
* `adminer`
* `static`

Containers are lightweight and share the host kernel.

---

### Images

Images are built using custom Dockerfiles:

* Base image: `debian:12`
* No pre-built images (nginx, wordpress, mariadb, redis, adminer, static) are used

Each image:

* Installs required packages
* Copies configuration files
* Defines an entrypoint script

---

### Docker Compose

The `docker-compose.yaml` file defines:

* Services
* Volumes
* Network
* Environment variables
* Docker secrets

It allows running the full infrastructure with Docker Compose directly:

```id="w9kz1x"
docker compose -f srcs/docker-compose.yaml up --build -d
```

The preferred project interface is the `Makefile`.

---

## Docker Network

A Docker bridge network created by docker-compose. This allows containers to communicate using service names:

* `mariadb` → database host
* `wordpress` → php-fpm service

Example:

```id="i7j4ml"
fastcgi_pass wordpress:9000;
```

---

## NGINX

### Role

* Handles HTTPS connections (port 443)
* Terminates SSL/TLS
* Forwards PHP requests to WordPress

---

### SSL/TLS

* Self-signed certificate
* TLSv1.2 and TLSv1.3 enabled

---

### Configuration

```id="jv8l2s"
location ~ \.php$ {
    fastcgi_pass wordpress:9000;
}
```

NGINX does not execute PHP; it delegates to PHP-FPM.

---

## WordPress (PHP-FPM)

### Role

* Executes PHP code
* Handles application logic
* Connects to MariaDB

---

### Initialization script

`init_wordpress.sh`:

* Waits for MariaDB to be ready
* Downloads WordPress (wp-cli)
* Creates `wp-config.php`
* Installs WordPress
* Creates users

---

### Communication with MariaDB

```id="6zj2rm"
--dbhost="mariadb:3306"
```

Uses Docker network DNS resolution.

---

## MariaDB

### Role

* Stores WordPress data (users, posts, comments)

---

### Initialization script

`init_mariadb.sh`:

* Initializes database if not present
* Creates database
* Creates user
* Grants privileges

---

## Volumes (Persistence)

Docker named volumes are configured with the local driver and bind-mounted to host directories:

```id="kq0p5d"
/home/<login>/data/mariadb
/home/<login>/data/wordpress
```

This ensures:

* Data persists after container restart
* Data survives VM reboot
* WordPress files and MariaDB database files can be located on the host

Volume mapping:

* `mariadb` volume -> `/home/<login>/data/mariadb`
* `wordpress` volume -> `/home/<login>/data/wordpress`

The `make fclean` command removes Docker volumes and the host data directories, so it deletes persistent project data.

---

## Runtime Configuration and Secrets

Non-sensitive runtime configuration is stored in:

```id="q3zt9m"
srcs/.env
```

Used for:

* Domain name
* Database name
* Usernames and emails
* Redis host and port

Sensitive values are stored as local Docker secret files under `secrets/` and mounted into containers under `/run/secrets/`.

Secrets used by the project:

* `mysql_password`
* `mysql_root_password`
* `wp_admin_password`
* `wp_user_password`

Used for:

* Database passwords
* WordPress admin password
* WordPress regular user password

---

## Makefile

The Makefile simplifies commands:

```id="3k6p0y"
make up      -> create data directories, build images, and start containers
make down    -> stop containers
make build   -> build images
make logs    -> follow container logs
make ps      -> list project containers
make clean   -> stop containers
make fclean  -> remove containers, Docker volumes, and host data directories
make re      -> rebuild everything from a clean state
```

---

## Docker Compose Commands

Equivalent Docker Compose commands are useful when debugging:

```sh
docker compose -f srcs/docker-compose.yaml config
docker compose -f srcs/docker-compose.yaml up --build -d
docker compose -f srcs/docker-compose.yaml ps
docker compose -f srcs/docker-compose.yaml logs -f
docker compose -f srcs/docker-compose.yaml down
docker compose -f srcs/docker-compose.yaml down -v
```

Container and volume inspection:

```sh
docker ps
docker volume ls
docker network ls
```

---

## Docker vs Virtual Machines

* Containers share the host kernel → lightweight
* Faster startup time
* Lower resource usage
* Easier to deploy and reproduce environments

---

## Key Design Choices

* Separation of services (NGINX / WordPress / MariaDB)
* Use of Docker network for service discovery
* Use of volumes for persistence
* Use of environment variables for configuration
* Use of Docker secrets for passwords
* HTTPS-only exposure (port 443)

---
