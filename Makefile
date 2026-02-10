.PHONY: help dev dev-docker build up down logs clean test deploy

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

dev: ## Run Flask development server locally
	cd website && uv run python main.py

dev-docker: ## Run Flask in Docker for development
	docker compose -f docker-compose.development.yml up

build: ## Build production Docker image
	docker compose -f docker-compose.production.yml build

up: ## Start production services (local build)
	docker compose -f docker-compose.production.yml up -d

down: ## Stop all services
	docker compose -f docker-compose.development.yml down
	docker compose -f docker-compose.production.yml down
	docker compose -f docker-compose.production.ghcr.yml down

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

deploy: ## Deploy using GHCR image
	./deploy.sh

sync: ## Sync dependencies to lock file
	cd website && uv sync

add: ## Add a new dependency (usage: make add PACKAGE=flask-cors)
	cd website && uv add $(PACKAGE)
