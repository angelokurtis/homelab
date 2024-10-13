ifneq (,$(wildcard ./.env))
	include .env
	export $(shell sed 's/=.*//' .env)
endif

.PHONY: help
help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

.PHONY: init
init: ## Initialize Terraform configurations
	terraform init -upgrade=true

.PHONY: quickstart
quickstart: init ## Initialize Terraform configurations
	terraform apply -auto-approve

.PHONY: plan
plan: ## Show the Terraform execution plan
	terraform plan

.PHONY: apply
apply: ## Apply Terraform configurations with auto-approval
	terraform apply -auto-approve

.PHONY: clean
clean: ## Remove all Terraform-generated files
	rm -rf .terraform .terraform.lock.hcl terraform.tfstate* otel-config
