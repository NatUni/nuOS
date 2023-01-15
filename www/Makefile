build: dashboard/public/build engine/mix.exs ## Build a production-ready binary or set of files
	@echo '=====> Target: build'
	@echo Done.
.PHONY: build

server-info:
	@echo
	@[ 0.0.0.0 = "${HOST}" ] || echo 'Note: Put HOST=0.0.0.0 in the environment in order to access development server from the network.'
	@echo
.PHONY: server-info

start: dashboard/public/build server-info
	cd dashboard && npm start
.PHONY: start

dev: dashboard/node_modules server-info ## Start a local development server with live reloading
	@echo '=====> Target: dev'
	cd dashboard && npm run dev
.PHONY: dev

deploy: ## Tag a release for CI to build, or rsync files to a server
	@echo '=====> Target: deploy'
.PHONY: deploy

format: ## Format all source files to a standard style
	@echo '=====> Target: format'
.PHONY: format

lint: ## Run code quality checks
	@echo '=====> Target: lint'
.PHONY: lint

test: ## Run a full set of test suites
	@echo '=====> Target: test'
.PHONY: test

clean: ## Remove all build artifacts and downloaded dependencies
	@echo '=====> Target: clean'
	rm -rvf dashboard/public/build dashboard/node_modules
.PHONY: clean

dashboard/public/build: dashboard/node_modules
	cd dashboard && npm run build

dashboard/node_modules: dashboard/package.json
	cd dashboard && npm install

dashboard/package.json:
	npx degit sveltejs/template dashboard

engine/mix.exs: phx
	@grep -Fow Engine.Umbrella.MixProject engine/mix.exs || ( \
		mix phx.new --install xxxdistinctlynuosuniquexxx --umbrella --no-assets --no-ecto --no-html --no-gettext --no-dashboard --no-live; \
		grep -rl xxxdistinctlynuosuniquexxx_web xxxdistinctlynuosuniquexxx_umbrella | xargs sed -i '' -e s/xxxdistinctlynuosuniquexxx_web/sparkplug/g; \
		grep -rl XxxdistinctlynuosuniquexxxWeb xxxdistinctlynuosuniquexxx_umbrella | xargs sed -i '' -e s/XxxdistinctlynuosuniquexxxWeb/Sparkplug/g; \
		grep -rl xxxdistinctlynuosuniquexxx xxxdistinctlynuosuniquexxx_umbrella | xargs sed -i '' -e s/xxxdistinctlynuosuniquexxx/crankshaft/g; \
		grep -rl Xxxdistinctlynuosuniquexxx xxxdistinctlynuosuniquexxx_umbrella | xargs sed -i '' -e s/Xxxdistinctlynuosuniquexxx/Crankshaft/g; \
		find xxxdistinctlynuosuniquexxx_umbrella -name xxxdistinctlynuosuniquexxx_web -type d | tail -r | sh -c 'while read -r p; do mv "$$p" "$${p%/*}/sparkplug"; done'; \
		find xxxdistinctlynuosuniquexxx_umbrella -name xxxdistinctlynuosuniquexxx -type d | tail -r | sh -c 'while read -r p; do mv "$$p" "$${p%/*}/crankshaft"; done'; \
		find xxxdistinctlynuosuniquexxx_umbrella -name xxxdistinctlynuosuniquexxx_web.ex -type f | sh -c 'while read -r p; do mv "$$p" "$${p%/*}/sparkplug.ex"; done'; \
		find xxxdistinctlynuosuniquexxx_umbrella -name xxxdistinctlynuosuniquexxx.ex -type f | sh -c 'while read -r p; do mv "$$p" "$${p%/*}/crankshaft.ex"; done'; \
		grep -Frl Crankshaft.Umbrella xxxdistinctlynuosuniquexxx_umbrella | xargs sed -i '' -e 's/Crankshaft\.Umbrella/Engine.Umbrella/g'; \
		mv xxxdistinctlynuosuniquexxx_umbrella engine; \
	)

mix:
	@mix -v || ( \
		echo; \
		echo 'Error: Elixir is not installed. Contact your system administrator.'; \
		echo; \
	false)
.PHONY: mix

rebar: mix
	@~/.mix/rebar3 -v || mix local.rebar --force
.PHONY: rebar

hex: mix
	@mix hex.info || mix local.hex --force
.PHONY: hex

phx: hex
	@mix phx.new -v || mix archive.install --force hex phx_new
.PHONY: phx

help: ## Show this help
	@echo 
	@echo 'Specify a command. The choices are:'
	@echo
	@grep -Eh '^[0-9a-zA-Z_-]+:.*## ' ${.MAKE.MAKEFILES:[-1]} | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[0;36m%-12s\033[m %s\n", $$1, $$2}'
	@echo
.PHONY: help

