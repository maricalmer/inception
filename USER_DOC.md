# User Documentation

## Overview

This document explains how to install, run, and use the Inception project.

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

Edit the `.env` file:

```
srcs/.env
```

Set your values:

```
MYSQL_DATABASE=wordpress
MYSQL_USER=wp_user
MYSQL_PASSWORD=your_password
MYSQL_ROOT_PASSWORD=your_root_password

DOMAIN_NAME=your_login.42.fr

WP_ADMIN_USER=your_admin
WP_ADMIN_PASSWORD=your_password
WP_ADMIN_EMAIL=your_email

WP_USER=your_user
WP_USER_PASSWORD=your_password
WP_USER_EMAIL=your_user_email
```

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

Login using the credentials defined in `.env`.

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
