# Makefile для управления Bitrix24 в микросервисной архитектуре 

.PHONY: init deploy monitor scale-down clean help
init:
	@echo "Инициализация Docker Swarm..."
	@if ! docker info | grep -q "Swarm: active"; then \
		docker swarm init --advertise-addr $(shell hostname -i | cut -d' ' -f1); \
	else \
		echo "Docker Swarm уже инициализирован"; \
	fi

networks:
	@echo "Создание overlay сетей..."
	@docker network create --driver overlay --attachable monitor-overlay 2>/dev/null || true

deploy:
	@echo "Развертывание основных сервисов Bitrix24..."
	@docker stack deploy --compose-file ./env-docker/docker-compose.yml bitrix24
#	@docker compose exec --user=bitrix php sh
#	@cd /opt/www/
#	@wget https://www.1c-bitrix.ru/download/portal/bitrix24_enterprise_postgresql_encode.tar.gz
#	@tar -xvzf bitrix24_enterprise_postgresql_encode.tar.gz

down:
	@echo "Остановка сервисов..."
	@docker stack rm bitrix24 || true

clean:
	@echo "Очистка ресурсов..."
	@docker system prune -af --volumes
	@docker network rm bitrix-overlay monitor-overlay 2>/dev/null || true

monitor: networks
	@echo "Развертывание системы мониторинга..."
	@docker stack deploy -c ./monitoring/docker-compose.yml monitor