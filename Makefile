COMPOSE_FILE = srcs/docker-compose.yml
DATA_DIR = /home/dlemaire/data

all: up

up:
	@mkdir -p $(DATA_DIR)/mariadb $(DATA_DIR)/wordpress
	@sudo chown -R 999:999 $(DATA_DIR)/mariadb
	@sudo chown -R 33:33 $(DATA_DIR)/wordpress
	@docker compose -f $(COMPOSE_FILE) up --build -d

down:
	@docker compose -f $(COMPOSE_FILE) down

build:
	@docker compose -f $(COMPOSE_FILE) build

logs:
	@docker compose -f $(COMPOSE_FILE) logs -f

ps:
	@docker compose -f $(COMPOSE_FILE) ps

clean:
	@docker compose -f $(COMPOSE_FILE) down

fclean:
	@docker compose -f $(COMPOSE_FILE) down -v
	@sudo rm -rf $(DATA_DIR)/mariadb $(DATA_DIR)/wordpress

re: fclean all

.PHONY: all up down build logs ps clean fclean re
