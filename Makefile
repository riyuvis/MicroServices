# DevSecOps AWS Flow Makefile

.PHONY: help install build test security-scan deploy clean

# Default target
help:
	@echo "DevSecOps AWS Flow - Available Commands:"
	@echo ""
	@echo "Setup Commands:"
	@echo "  install         Install all dependencies"
	@echo "  setup-aws       Configure AWS CLI and credentials"
	@echo "  setup-k8s       Configure kubectl for EKS cluster"
	@echo ""
	@echo "Build Commands:"
	@echo "  build           Build all microservices"
	@echo "  build-api       Build API microservice"
	@echo "  build-auth      Build Auth microservice"
	@echo "  docker-build    Build Docker images"
	@echo ""
	@echo "Test Commands:"
	@echo "  test            Run all tests"
	@echo "  test-unit       Run unit tests"
	@echo "  test-integration Run integration tests"
	@echo "  lint            Run linting"
	@echo ""
	@echo "Security Commands:"
	@echo "  security-scan   Run comprehensive security scan"
	@echo "  security-audit  Run security audit"
	@echo "  compliance-check Check compliance status"
	@echo ""
	@echo "Infrastructure Commands:"
	@echo "  infra-plan      Plan infrastructure changes"
	@echo "  infra-apply     Apply infrastructure changes"
	@echo "  infra-destroy   Destroy infrastructure"
	@echo ""
	@echo "Deployment Commands:"
	@echo "  deploy-dev      Deploy to development environment"
	@echo "  deploy-prod     Deploy to production environment"
	@echo "  deploy-k8s      Deploy to Kubernetes"
	@echo ""
	@echo "Monitoring Commands:"
	@echo "  monitor-start   Start monitoring stack"
	@echo "  monitor-stop    Stop monitoring stack"
	@echo "  logs            View application logs"
	@echo ""
	@echo "Cleanup Commands:"
	@echo "  clean           Clean build artifacts"
	@echo "  clean-all       Clean all artifacts and temporary files"

# Setup commands
install:
	@echo "Installing dependencies..."
	npm install
	cd security && npm install
	cd microservices/api && npm install
	cd microservices/auth && npm install

setup-aws:
	@echo "Setting up AWS CLI..."
	@if ! command -v aws &> /dev/null; then \
		echo "AWS CLI not found. Please install AWS CLI v2."; \
		exit 1; \
	fi
	aws configure list

setup-k8s:
	@echo "Setting up kubectl for EKS..."
	aws eks update-kubeconfig --region us-east-1 --name devsecops-dev-eks

# Build commands
build: build-api build-auth

build-api:
	@echo "Building API microservice..."
	cd microservices/api && npm run build

build-auth:
	@echo "Building Auth microservice..."
	cd microservices/auth && npm run build

docker-build:
	@echo "Building Docker images..."
	docker build -t api:latest microservices/api/
	docker build -t auth:latest microservices/auth/
	docker build -t gateway:latest microservices/gateway/
	docker build -t database:latest microservices/database/

# Test commands
test: test-unit lint

test-unit:
	@echo "Running unit tests..."
	npm run test:services
	npm run test:security

test-integration:
	@echo "Running integration tests..."
	npm run test:integration

lint:
	@echo "Running linters..."
	npm run lint:services
	npm run lint:security

# Security commands
security-scan:
	@echo "Running comprehensive security scan..."
	npm run security:scan

security-audit:
	@echo "Running security audit..."
	npm audit
	cd security && npm audit

compliance-check:
	@echo "Checking compliance status..."
	node scripts/compliance-checker.js

# Infrastructure commands
infra-plan:
	@echo "Planning infrastructure changes..."
	cd infrastructure && terraform plan

infra-apply:
	@echo "Applying infrastructure changes..."
	cd infrastructure && terraform apply

infra-destroy:
	@echo "Destroying infrastructure..."
	cd infrastructure && terraform destroy

# Deployment commands
deploy-dev:
	@echo "Deploying to development environment..."
	npm run deploy:dev

deploy-prod:
	@echo "Deploying to production environment..."
	npm run deploy:prod

deploy-k8s:
	@echo "Deploying to Kubernetes..."
	kubectl apply -f k8s/namespaces/
	kubectl apply -f k8s/configmaps/
	kubectl apply -f k8s/secrets/
	kubectl apply -f k8s/deployments/
	kubectl apply -f k8s/services/
	kubectl apply -f k8s/ingress/

# Monitoring commands
monitor-start:
	@echo "Starting monitoring stack..."
	kubectl apply -f monitoring/k8s/prometheus-deployment.yaml
	kubectl apply -f monitoring/k8s/grafana-deployment.yaml
	kubectl apply -f monitoring/k8s/alertmanager-deployment.yaml

monitor-stop:
	@echo "Stopping monitoring stack..."
	kubectl delete -f monitoring/k8s/alertmanager-deployment.yaml
	kubectl delete -f monitoring/k8s/grafana-deployment.yaml
	kubectl delete -f monitoring/k8s/prometheus-deployment.yaml

logs:
	@echo "Viewing application logs..."
	kubectl logs -f deployment/api -n microservices

# Cleanup commands
clean:
	@echo "Cleaning build artifacts..."
	rm -rf microservices/*/dist/
	rm -rf microservices/*/build/
	rm -rf coverage/
	rm -rf .nyc_output/

clean-all: clean
	@echo "Cleaning all artifacts..."
	rm -rf node_modules/
	rm -rf security/node_modules/
	rm -rf microservices/*/node_modules/
	rm -rf security-reports/
	rm -rf .terraform/
	rm -f *.tfstate*
	rm -f *.tfplan

# Development commands
dev:
	@echo "Starting development environment..."
	npm run dev

dev-api:
	@echo "Starting API development server..."
	cd microservices/api && npm run dev

dev-auth:
	@echo "Starting Auth development server..."
	cd microservices/auth && npm run dev

# Utility commands
status:
	@echo "Checking system status..."
	@echo "Kubernetes cluster status:"
	kubectl get nodes
	@echo ""
	@echo "Application status:"
	kubectl get pods -n microservices
	@echo ""
	@echo "Service status:"
	kubectl get services -n microservices

port-forward:
	@echo "Setting up port forwarding..."
	@echo "API: http://localhost:3000"
	@echo "Auth: http://localhost:3001"
	@echo "Grafana: http://localhost:3001"
	@echo "Prometheus: http://localhost:9090"
	kubectl port-forward svc/api-service 3000:80 -n microservices &
	kubectl port-forward svc/auth-service 3001:80 -n microservices &
	kubectl port-forward svc/grafana 3002:3000 -n monitoring &
	kubectl port-forward svc/prometheus 9090:9090 -n monitoring &

# Quick start
quick-start: install setup-aws setup-k8s build test security-scan deploy-k8s monitor-start
	@echo "Quick start completed!"
	@echo "Run 'make port-forward' to access services locally"
	@echo "Run 'make status' to check system status"
