dev: dashboard/node_modules ## Start a local development server with live reloading
	@echo "=====> Target: dev"
	cd dashboard && npm run dev
.PHONY: dev

build: dashboard/node_modules ## Build a production-ready binary or set of files
	@echo "=====> Target: build"
.PHONY: build

deploy: ## Tag a release for CI to build, or rsync files to a server
	@echo "=====> Target: deploy"
.PHONY: deploy

format: ## Format all source files to a standard style
	@echo "=====> Target: format"
.PHONY: format

lint: ## Run code quality checks
	@echo "=====> Target: lint"
.PHONY: lint

test: ## Run a full set of test suites
	@echo "=====> Target: test"
.PHONY: test

clean: ## Remove all build artifacts and downloaded dependencies
	@echo "=====> Target: clean"
.PHONY: clean

dashboard/node_modules: dashboard/package.json
	cd dashboard && npm install

dashboard/package.json:
	npx degit sveltejs/template dashboard

help: ## Show this help
	@echo 
	@echo "Specify a command. The choices are:"
	@echo
	@grep -Eh '^[0-9a-zA-Z_-]+:.*## ' ${.MAKE.MAKEFILES} | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[0;36m%-12s\033[m %s\n", $$1, $$2}'
	@echo
.PHONY: help

