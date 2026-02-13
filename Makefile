.PHONY: help dev dev-docker swarm-init swarm-secrets swarm-deploy swarm-down swarm-logs swarm-logs-web swarm-logs-proxy swarm-ps swarm-scale swarm-update swarm-rollback clean test deploy sync add install

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

dev: ## Run Flask development server locally
	cd website && uv run python main.py

dev-docker: ## Run Flask in Docker for development
	docker compose -f docker-compose.development.yml up

# Docker Swarm commands
swarm-init: ## Initialize Docker Swarm
	docker swarm init

swarm-secrets: ## Set up Docker Swarm secrets
	./setup-secrets.sh

swarm-deploy: ## Deploy to Docker Swarm using GHCR image
	./deploy-swarm.sh

swarm-update: ## Update web service with latest GHCR image (rolling update)
	@. .env.production && docker service update --image ghcr.io/$${GITHUB_REPOSITORY}/flask-app:latest flask-app_web

swarm-rollback: ## Rollback web service to previous version
	docker service rollback flask-app_web

swarm-down: ## Remove Docker Swarm stack
	docker stack rm flask-app

swarm-logs: ## View logs from all swarm services
	docker service logs flask-app_web --tail 50 --follow

swarm-logs-web: ## View logs from web service
	docker service logs flask-app_web --tail 50 --follow

swarm-logs-proxy: ## View logs from nginx proxy service
	docker service logs flask-app_proxy --tail 50 --follow

swarm-ps: ## Show status of swarm services
	docker stack services flask-app

swarm-scale: ## Scale web service (usage: make swarm-scale REPLICAS=3)
	docker service scale flask-app_web=$(REPLICAS)

logs: ## View logs from running containers
	docker compose -f docker-compose.production.yml logs -f

clean: ## Clean up Python cache and Docker resources
	find . -type d -name __pycache__ -exec rm -r {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete
	docker system prune -f

install: ## Install Python dependencies
	cd website && uv sync

test: ## Run tests (when implemented)
	cd website && uv run pytest

deploy: ## Alias for swarm-deploy
	./deploy-swarm.sh

sync: ## Sync dependencies to lock file
	cd website && uv sync

add: ## Add a new dependency (usage: make add PACKAGE=flask-cors)
	cd website && uv add $(PACKAGE)
