# Inception

## Overview

This project consists of setting up a small infrastructure using Docker and Docker Compose.

The infrastructure includes:

* NGINX with SSL/TLS (TLSv1.2 / TLSv1.3, self-signed certificate)
* WordPress with PHP-FPM
* MariaDB

Each service runs in its own container and communicates through a Docker network.

---

## Concepts

### Docker

Docker allows applications to run in isolated environments called containers.
Each container includes everything needed to run the service.

### Docker Compose

Docker Compose allows defining and running multiple containers together using a single configuration file (`docker-compose.yml`).

### Image vs Container

* **Image**: blueprint (built from Dockerfile)
* **Container**: running instance of an image

### Docker vs Virtual Machines

* Containers share the host kernel → lightweight
* Faster startup than VMs
* Less resource usage

### Why this architecture

* Separation of concerns (web / app / database)
* Easier maintenance and scalability

---

## Architecture

* **NGINX**

  * Serves the website over HTTPS (port 443)
  * Handles SSL/TLS termination
  * Forwards PHP requests to WordPress (php-fpm)

* **WordPress (php-fpm)**

  * Handles application logic
  * Connects to MariaDB for data storage

* **MariaDB**

  * Stores WordPress data

* **Volumes**

  * `/home/<login>/data/wordpress` → WordPress files
  * `/home/<login>/data/mariadb` → Database data

All containers are connected through a Docker bridge network, allowing them to communicate using service names (e.g., mariadb, wordpress).

---

## Project Structure

```
.
├── Makefile
├── srcs/
│   ├── docker-compose.yml
│   ├── .env
│   └── requirements/
│       ├── nginx/
│       ├── wordpress/
│       └── mariadb/
```

---

## Setup

### 1. Clone the repository

```
git clone <repo_url>
cd inception
```

### 2. Configure environment variables

Edit:

```
srcs/.env
```

---

### 3. Start the infrastructure

```
make up
```

---

## Usage

Open in browser (inside VM):

```
https://dlemaire.42.fr
```

---

## Makefile commands

```
make up       # Build and start containers
make down     # Stop containers
make build    # Build images
make logs     # Show logs
make ps       # Show containers
make fclean   # Remove containers, volumes, and data
make re       # Rebuild everything
```

---

## Persistence

Data is stored in:

```
/home/<login>/data/
```

This ensures:

* WordPress content persists
* MariaDB data persists after restart

---

## Notes

* Only HTTPS (port 443) is exposed
* Self-signed SSL certificate is used
* No pre-built images are used (all images are built from Debian)
* Services communicate via a Docker network
* All images are built from Debian (no pre-built images such as nginx or wordpress are used)
* Containers communicate using service names defined in docker-compose

---

