# Makefile для управления Bitrix24 в микросервисной архитектуре 

.PHONY: init deploy monitor scale-down clean help
init:
	@echo "Инициализация Docker Swarm..."
	@if ! docker info | grep -q "Swarm: active"; then \
		docker swarm init --advertise-addr $(shell hostname -i | cut -d' ' -f1); \
	else \
		echo "Docker Swarm уже инициализирован"; \
	fi


deploy:
	@echo "Развертывание основных сервисов Bitrix24..."
	@docker stack deploy --compose-file ./env-docker/docker-compose.yml bitrix24


down:
	@echo "Остановка сервисов..."
	@docker stack rm bitrix24 || true
	@docker stack rm monitor || true


clean:
	@echo "Очистка ресурсов..."
	@docker system prune -af --volumes

monitor: networks
	@echo "Развертывание системы мониторинга..."
	@docker stack deploy -c ./monitoring/docker-compose.yml monitor

status:
	@echo "Статус сервисов Bitrix24:"
	@docker stack services bitrix24
	@echo ""
	@echo "Статус сервисов мониторинга:"
	@docker stack services monitor

help:
	@echo "Доступные команды:"
	@echo "  init         - Инициализировать Docker Swarm"
	@echo "  deploy       - Развернуть основные сервисы Bitrix24"
	@echo "  monitor      - Развернуть систему мониторинга"
	@echo "  down         - Остановить и удалить сервисы"
	@echo "  clean        - Полная очистка ресурсов"
	@echo "  status       - Показать статус сервисов"