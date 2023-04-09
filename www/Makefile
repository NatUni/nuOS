BIND?=localhost

FRONTENDS=	dashboard
#FRONTENDS+=	org net
#FRONTENDS+=	wall gold cash

build: ${FRONTENDS:S/^/build-/} build-engine ## Build a production-ready binary or set of files
	@echo '=====> Target: build'
	@echo Done.
.PHONY: build

server-info:
	@echo
	@[ 0.0.0.0 = "${BIND:tl:S/^*$/0.0.0.0/W}" ] || echo 'Note: Put BIND=0.0.0.0 in the environment in order to access development server from the network.'
	@echo
.PHONY: server-info

start: build-dashboard server-info
	cd dashboard && npm start
.PHONY: start

dev: Procfile server-info ## Start a local development server with live reloading
	@echo '=====> Target: dev'
	...
	honcho start
.PHONY: dev

${FRONTENDS:S/^/dev-/}: ${@:S/^dev-//}/node_modules
	cd ${@:S/^dev-//} && env HOST=${BIND:tl:S/^*$/0.0.0.0/W} npm run dev
.PHONY: ${FRONTENDS:S/^/dev-/}

dev-phoenix: engine/deps rebar bind-phoenix-dev
	cd engine && mix phx.server
.PHONY: dev-phoenix

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

clean: unbind-phoenix-dev ## Remove all build artifacts and downloaded dependencies
	@echo '=====> Target: clean'
	rm -rf Procfile ${FRONTENDS:S+$+/public/build+} ${FRONTENDS:S+$+/node_modules+}
	rm -rf engine/_build engine/deps
.PHONY: clean

clean-world: ## Remove all dependencies from development environment (may have unwanted side effects)
	@echo '=====> Target: clean-world'
	rm -rf ~/.degit ~/.npm
	rm -rf ~/.hex ~/.mix
.PHONY: clean-world

${FRONTENDS:S/^/build-/}: ${@:S/^build-//}/public/build

${FRONTENDS:S+$+/public/build+}: ${@:H:H}/node_modules
	cd ${@:H:H} && npm run build

${FRONTENDS:S+$+/node_modules+}: ${@:H}/package.json
	cd ${@:H} && npm install

${FRONTENDS:S+$+/package.json+}:
	npx --yes degit sveltejs/template ${@:H}

bind-phoenix-dev: build-engine
	sed -i "${:![ -e engine/config/dev.exs.bak ] || echo .bak!}" -Ee 's/^([^#]*\<ip:[[:blank:]]*)\{([[:digit:][:blank:],]+)}(.*)$$/\1{${BIND:tl:S/^*$/0.0.0.0/W:S/^localhost$/127.0.0.1/W:S/./, /g}}\3/g' engine/config/dev.exs
.PHONY: bind-phoenix-dev

unbind-phoenix-dev:
	[ ! -e engine/config/dev.exs.bak ] || mv engine/config/dev.exs.bak engine/config/dev.exs
.PHONY: unbind-phoenix-dev

build-engine: engine/mix.exs engine/deps

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

engine/deps: engine/mix.exs
	cd engine && mix deps.get

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

Procfile:
	echo api: make dev-phoenix > Procfile
	echo ${FRONTENDS} | xargs -n1 | sh -c 'while read -r fe; do echo $$fe: make PORT=$$((5000 + $${i=0})) dev-$$fe; i=$$(($$i + 1)); done >> Procfile'

help: ## Show this help
	@echo 
	@echo 'Specify a command. The choices are:'
	@echo
	@grep -Eh '^[0-9a-zA-Z_-]+:.*## ' ${.MAKE.MAKEFILES:[-1]} | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[0;36m%-12s\033[m %s\n", $$1, $$2}'
	@echo
.PHONY: help

