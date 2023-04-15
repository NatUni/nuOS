all: build release

build: target/debug

release: target/release

target/debug:
	cargo build

target/release:
	cargo build --release

install: release
	mkdir -p ~/bin
	install -s target/release/rmd320 ~/bin/rmd320

clean:
	cargo clean
