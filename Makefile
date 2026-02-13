.PHONY: help dev dev-docker swarm-init swarm-secrets swarm-deploy swarm-down swarm-logs swarm-logs-web swarm-logs-traefik swarm-ps swarm-scale swarm-update swarm-rollback clean test deploy

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
