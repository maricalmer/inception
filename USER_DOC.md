# User Documentation

## Overview

This document explains how to install, run, and use the Inception project.

---

## Services Provided

The stack provides the following services:

* **NGINX**: public HTTPS entry point on port 443
* **WordPress**: website and administration panel
* **MariaDB**: database used by WordPress
* **Redis**: cache service used by WordPress
* **Adminer**: database administration interface
* **Static site**: additional static website available through NGINX

Only NGINX is exposed to the host. The other services communicate inside the Docker network.

---

## Requirements

* Linux system (Debian recommended)
* Docker
* Docker Compose
* Make

---

## Installation

### 1. Clone the repository

```
git clone https://github.com/maricalmer/inception inception
cd inception
```

---

### 2. Configure environment variables

Copy the example file and edit the non-sensitive values:

```
cp srcs/.env.example srcs/.env
```

Then edit `srcs/.env`.

Set your values:

```
MYSQL_DATABASE=wordpress
MYSQL_USER=wp_user

DOMAIN_NAME=your_login.42.fr

WP_ADMIN_USER=your_admin
WP_ADMIN_EMAIL=your_email

WP_USER=your_user
WP_USER_EMAIL=your_user_email

REDIS_HOST=redis
REDIS_PORT=6379
```

Passwords are provided through Docker secrets, not through `.env`.

---

### 3. Create local Docker secret files

Create the secret files expected by Docker Compose:

```
mkdir -p secrets
printf '%s' 'your_database_password' > secrets/mysql_password.txt
printf '%s' 'your_database_root_password' > secrets/mysql_root_password.txt
printf '%s' 'your_wordpress_admin_password' > secrets/wp_admin_password.txt
printf '%s' 'your_wordpress_user_password' > secrets/wp_user_password.txt
```

These files are mounted inside containers under `/run/secrets/` and must not be committed.

---

## Usage

### Start the project

```
make up
```

---

### Stop the project

```
make down
```

---

### Rebuild everything

```
make re
```

---

### View logs

```
make logs
```

---

### Check running services

List the project containers:

```
make ps
```

All services should be running or healthy enough to stay up:

* `nginx`
* `wordpress`
* `mariadb`
* `redis`
* `adminer`
* `static`

You can also check the logs if a service is not working:

```
make logs
```

For direct Docker Compose inspection:

```
docker compose -f srcs/docker-compose.yaml ps
docker compose -f srcs/docker-compose.yaml logs
```

---

## Access the website

Open in a browser (inside the VM):

```
https://your_login.42.fr
```

⚠️ A security warning may appear because a self-signed SSL certificate is used. This is normal.

---

## WordPress administration

Access the admin panel:

```
https://your_login.42.fr/wp-admin
```

Login using the username and email defined in `.env`, and the password stored in `secrets/wp_admin_password.txt`.

---

## Credentials

Credentials are split between configuration and secrets:

* Usernames, emails, domain name, database name, and Redis settings are stored in `srcs/.env`.
* Passwords are stored in local files under `secrets/`.

Secret files:

* `secrets/mysql_password.txt`: MariaDB WordPress user password
* `secrets/mysql_root_password.txt`: MariaDB root password
* `secrets/wp_admin_password.txt`: WordPress administrator password
* `secrets/wp_user_password.txt`: WordPress regular user password

To change a password, update the matching file in `secrets/`, then rebuild/restart the affected services. If MariaDB or WordPress was already initialized, stored credentials may also need to be updated inside the application or database because persistent data is kept in `/home/<login>/data/`.

---

## Data persistence

All data is stored locally:

```
/home/<login>/data/
```

* WordPress files → `/home/<login>/data/wordpress`
* Database → `/home/<login>/data/mariadb`

Data remains after restarting the containers.

---

## Notes

* Only HTTPS (port 443) is exposed
* HTTP (port 80) is not available
* All services run in separate containers
* Containers communicate through a Docker network

---
