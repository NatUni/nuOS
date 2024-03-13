SITE=		nuOS.org
SERVER=		CargoBay.net
ADMIN=		jedi
RSYNC=		${ADMIN}@${SERVER:tl}:/var/jail/www/home/${ADMIN}/${SITE:tl}/www/public

.SUFFIXES:
.SUFFIXES: .css .html .ttf .otf .svg .x[ms]l .t{,e}xt .js


build: prep .PHONY

deploy: rsync .PHONY

all: build deploy .PHONY

prep: .prep .PHONY

rsync: .rsync .PHONY

.rsync:
	rsync -avP --delete --exclude='*.dd.*' ${.CURDIR}/ ${RSYNC}/
	touch .rsync

.prep: ${.SUFFIXES:S/^/*/}
	gzip -kn9f $?
	touch .prep
	rm -f .rsync

clean: .PHONY
	rm -vf *.gz .rsync .prep
