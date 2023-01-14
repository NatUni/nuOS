build: dashboard/public/build ## Build a production-ready binary or set of files
	@echo "=====> Target: build"
	@echo Done.
.PHONY: build

server-info:
	@echo
	@[ 0.0.0.0 = "${HOST}" ] || echo "Note: Put HOST=0.0.0.0 in the environment in order to access development server from the network."
	@echo
.PHONY: server-info

start: dashboard/public/build server-info
	cd dashboard && npm start
.PHONY: start

dev: dashboard/node_modules server-info ## Start a local development server with live reloading
	@echo "=====> Target: dev"
	cd dashboard && npm run dev
.PHONY: dev

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
	rm -rvf dashboard/public/build dashboard/node_modules
.PHONY: clean

dashboard/public/build: dashboard/node_modules
	cd dashboard && npm run build

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

