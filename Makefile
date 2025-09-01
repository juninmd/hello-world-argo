# Makefile for Webhook CronJob

.PHONY: help install dev build docker-build deploy deploy-dev deploy-prod clean lint test

# Variables
IMAGE_NAME := webhook-cronjob
IMAGE_TAG := latest
NAMESPACE := default

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

install: ## Install dependencies
	bun install

dev: ## Run in development mode
	bun run dev

build: ## Build the application
	bun run build

docker-build: ## Build Docker image
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) .

docker-run: ## Run Docker container locally
	docker run --rm -it \
		-e WEBHOOK_URL="https://webhook.site/4567aaad-19c9-4140-8cb4-faf2827ec704" \
		-e CRON_EXPRESSION="*/1 * * * *" \
		$(IMAGE_NAME):$(IMAGE_TAG)

lint: ## Run linter
	bun run type-check

test: ## Run tests (placeholder)
	@echo "No tests configured yet"

# Kubernetes deployment targets
deploy: docker-build ## Build and deploy
	@if command -v ./scripts/deploy.sh >/dev/null 2>&1; then \
		chmod +x ./scripts/deploy.sh && ./scripts/deploy.sh -t $(IMAGE_TAG); \
	else \
		powershell -ExecutionPolicy Bypass -File ./scripts/deploy.ps1 -ImageTag $(IMAGE_TAG); \
	fi

# Helm targets
helm-install: ## Install Helm chart
	helm install webhook-cronjob ./helm --namespace $(NAMESPACE) --create-namespace

helm-upgrade: ## Upgrade Helm chart
	helm upgrade webhook-cronjob ./helm --namespace $(NAMESPACE)

helm-uninstall: ## Uninstall Helm chart
	helm uninstall webhook-cronjob --namespace $(NAMESPACE)

helm-template: ## Generate Kubernetes manifests from Helm chart
	helm template webhook-cronjob ./helm

# ArgoCD targets
argocd-apply: ## Apply ArgoCD application
	kubectl apply -f argocd/application.yaml

argocd-delete: ## Delete ArgoCD application
	kubectl delete -f argocd/application.yaml

# Utility targets
logs: ## Show application logs
	kubectl logs -n $(NAMESPACE) -l app.kubernetes.io/name=webhook-cronjob --tail=100 -f

status: ## Show deployment status
	kubectl get cronjob,pods -n $(NAMESPACE) -l app.kubernetes.io/name=webhook-cronjob

clean: ## Clean build artifacts
	rm -rf dist/ node_modules/

# Development utilities
kind-create: ## Create kind cluster
	kind create cluster --name webhook-cronjob

kind-delete: ## Delete kind cluster
	kind delete cluster --name webhook-cronjob

kind-load: docker-build ## Load image into kind cluster
	kind load docker-image $(IMAGE_NAME):$(IMAGE_TAG) --name webhook-cronjob
