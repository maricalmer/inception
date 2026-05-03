# Developer Documentation

## Overview

This project implements a multi-container infrastructure using Docker Compose.

The architecture is composed of three main services:

* NGINX (web server + SSL)
* WordPress (PHP-FPM)
* MariaDB (database)

Each service runs in its own container and communicates through a Docker network.

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

Containers are lightweight and share the host kernel.

---

### Images

Images are built using custom Dockerfiles:

* Base image: `debian:12`
* No pre-built images (nginx, wordpress, mariadb) are used

Each image:

* Installs required packages
* Copies configuration files
* Defines an entrypoint script

---

### Docker Compose

The `docker-compose.yml` file defines:

* Services
* Volumes
* Network
* Environment variables

It allows running the full infrastructure with:

```id="w9kz1x"
docker compose up
```

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

Bind mounts are used:

```id="kq0p5d"
/home/<login>/data/mariadb
/home/<login>/data/wordpress
```

This ensures:

* Data persists after container restart
* Data survives VM reboot

---

## Environment Variables

All sensitive data is stored in:

```id="q3zt9m"
srcs/.env
```

Used for:

* Database credentials
* WordPress configuration

---

## Makefile

The Makefile simplifies commands:

```id="3k6p0y"
make up      → build and start
make down    → stop containers
make fclean  → remove containers + volumes
make re      → rebuild everything
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
* HTTPS-only exposure (port 443)

---
