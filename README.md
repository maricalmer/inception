*This project has been created as part of the 42 curriculum by dlemaire.*

# Inception

## Description

The goal of this project is to set up a small containerized infrastructure using Docker and Docker Compose.

It builds and runs a WordPress website backed by MariaDB and served through NGINX over HTTPS. The infrastructure includes:

* NGINX with SSL/TLS (TLSv1.2 / TLSv1.3, self-signed certificate)
* WordPress with PHP-FPM
* MariaDB

Each service runs in its own container and communicates through a Docker network.

Docker is used to build every service from local sources in `srcs/requirements/`: each service has its own Dockerfile, configuration files, and initialization scripts when needed. Docker Compose connects these services, injects runtime configuration from the local environment file, exposes only NGINX on port 443, and persists application data through Docker volumes backed by host directories.

---

## Concepts

### Docker

Docker allows applications to run in isolated environments called containers.
A container packages an application with the dependencies it needs to run.

In this project, Docker is used to create one image per service from Debian-based Dockerfiles. This keeps NGINX, WordPress, MariaDB, Redis, Adminer, and the static site isolated from each other while still letting them communicate through Docker Compose.

### Docker Compose

Docker Compose allows defining and running multiple containers together using a single configuration file (`docker-compose.yaml`).

The `srcs/docker-compose.yaml` file defines the services, build contexts, volumes, network, restart policy, and the single exposed HTTPS port.

### Image vs Container

* **Image**: blueprint (built from Dockerfile)
* **Container**: running instance of an image

### Virtual Machines vs Docker

* **Virtual Machines** emulate a full machine with their own guest operating system and kernel. Each VM behaves as if it were running on its own hardware, which gives strong separation between services running on the same physical host.
* This makes VMs very secure and reliable for isolation: one guest OS cannot normally see another guest OS files or processes, and resource limits help prevent one VM from consuming everything available to the host.
* **Docker containers** share the host kernel and rely on Linux isolation features instead of booting a full guest OS.
* At a lower level, container isolation is built from mechanisms such as `chroot` for changing the visible root filesystem, `namespaces` for isolating resources such as processes and networks, and `cgroups` for limiting CPU, memory, and process usage.
* Containers are lighter, start faster, and use fewer resources than virtual machines, which makes them well suited for this small multi-service infrastructure.
* Virtual machines provide stronger OS-level separation, but they are slower and heavier because each VM runs a complete operating system on top of the host system. That extra overhead is not necessary for this project.

### Secrets vs Environment Variables

* **Secrets** are intended for sensitive values such as passwords, private keys, and API tokens. They should be stored outside the Git repository and mounted or injected only at runtime.
* **Environment variables** are useful for runtime configuration such as domain names, database names, and service options.
* This project uses a local ignored `srcs/.env` file to provide configuration to Docker Compose. The committed `srcs/.env.example` file contains only placeholders.
* Passwords are mounted as Docker secrets from local files under `secrets/` and read from `/run/secrets/` inside the containers.
* Credentials must never be committed. The real secret files and the real `srcs/.env` file are ignored by Git.

### Docker Network vs Host Network

* **Host networking** makes a container share the host network namespace. It is simple, but it weakens isolation and can create port conflicts.
* **Docker networks** create an isolated network where containers can reach each other by service name.
* This project uses a custom bridge network named `inception`, so internal services such as `mariadb`, `wordpress`, `redis`, `adminer`, and `static` are not exposed directly on the host.
* Only NGINX publishes port 443, making it the single public entry point.

### Docker Volumes vs Bind Mounts

* **Docker volumes** are managed by Docker and are the preferred way to persist container data.
* **Bind mounts** map a specific host path into a container, making the location explicit on the host filesystem.
* This project uses Docker named volumes with the local driver bound to `/home/dlemaire/data/mariadb` and `/home/dlemaire/data/wordpress`.
* This keeps Compose volume management while satisfying the subject requirement that persistent data lives under `/home/<login>/data`.

### Why this architecture

* Services are separated by responsibility: NGINX handles HTTPS and routing, WordPress handles the application, and MariaDB stores data.
* Bonus services are isolated as separate containers: Redis for caching, Adminer for database administration, and a static site served through NGINX.
* Images are built locally from Debian-based Dockerfiles instead of using pre-built service images.
* A private Docker bridge network keeps internal services reachable by name without exposing them directly.
* Persistent state is limited to WordPress files and MariaDB data, which are stored under `/home/dlemaire/data`.

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

* **Redis**

  * Provides cache support for WordPress

* **Adminer**

  * Provides a lightweight database administration interface

* **Static site**

  * Serves a simple static website as an additional service

* **Volumes**

  * `/home/<login>/data/wordpress` -> WordPress files
  * `/home/<login>/data/mariadb` -> Database data

All containers are connected through a Docker bridge network, allowing them to communicate using service names (e.g., mariadb, wordpress).

---

## Project Structure

```
.
├── Makefile
├── secrets/
│   └── README.md
├── srcs/
│   ├── .env.example
│   ├── docker-compose.yaml
│   └── requirements/
│       ├── adminer/
│       │   ├── Dockerfile
│       │   └── conf/
│       ├── mariadb/
│       │   ├── Dockerfile
│       │   ├── conf/
│       │   └── tools/
│       ├── nginx/
│       │   ├── Dockerfile
│       │   └── conf/
│       ├── redis/
│       │   ├── Dockerfile
│       │   └── conf/
│       ├── static/
│       │   ├── Dockerfile
│       │   └── site/
│       └── wordpress/
│           ├── Dockerfile
│           ├── conf/
│           └── tools/
```

---

## Instructions

The project is managed with the `Makefile`. There is no separate compilation step: Docker images are built locally from the Dockerfiles through Docker Compose.

### 1. Clone the repository

```
git clone https://github.com/maricalmer/inception inception
cd inception
```

### 2. Configure environment variables

Copy the example file and edit the non-sensitive values:

```
cp srcs/.env.example srcs/.env
```

Then edit `srcs/.env`.

This file contains runtime configuration such as the domain name, database name, usernames, emails, and Redis settings. Passwords are not stored in `.env`.

### 3. Create local Docker secret files

Create the local secret files expected by Docker Compose:

```
mkdir -p secrets
printf '%s' 'your_database_password' > secrets/mysql_password.txt
printf '%s' 'your_database_root_password' > secrets/mysql_root_password.txt
printf '%s' 'your_wordpress_admin_password' > secrets/wp_admin_password.txt
printf '%s' 'your_wordpress_user_password' > secrets/wp_user_password.txt
```

These files are mounted inside the relevant containers under `/run/secrets/`. They are ignored by Git and must not be committed.

### 4. Build the images

```
make build
```

### 5. Start the infrastructure

```
make up
```

This creates the required data directories under `/home/dlemaire/data`, builds the images if needed, and starts the containers in the background.

### 6. Open the website

Open the site in a browser from inside the VM:

```
https://your_login.42.fr
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

## Resources

References used while working on this project:

* **Mastering Docker - Second Edition** by Russ McKendrick and Scott Gallagher
* **University of Helsinki - Welcome to DevOps with Docker - MOOC**
* **Complete Intro to Containers v2** by Brian Holt
* Docker documentation
* Docker Compose documentation

AI was used to brainstorm the infrastructure architecture and to help write and review the shell scripts used by the project. It was also used to improve the clarity and structure of this README.

---
