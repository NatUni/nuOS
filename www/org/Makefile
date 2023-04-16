SITE=		nuOS.org
SERVER=		CargoBay.net
ADMIN=		boba
RSYNC=		${ADMIN}@${SERVER:tl}:/var/jail/www/home/${ADMIN}/${SITE:tl}/www/public

.SUFFIXES:
.SUFFIXES: .css .html .ttf .otf .svg .x[ms]l .t{,e}xt .js


build: prep .PHONY

deploy: rsync .PHONY

all: build deploy .PHONY

prep: .prep .PHONY

rsync: .rsync .PHONY

.rsync:
	rsync -avP --delete --exclude='*.dd.xz' ${PWD}/ ${RSYNC}/
	touch .rsync

.prep: ${.SUFFIXES:S/^/*/}
	gzip -kn9f $?
	touch .prep
	rm -f .rsync

clean: .PHONY
	rm -vf *.gz .rsync .prep

compose-blimgs:
	convert nuos.svg -colorspace gray -depth 8 -resize '220x180>' -background white -gravity center -extent 240x200 -negate -alpha off -strip a.png
	convert -size 240x200 xc:black -colorspace gray -depth 8 -alpha off -strip k.png
	convert -size 240x200 xc:white -colorspace gray -depth 8 -alpha off -strip w.png
	cp k.png r.png
	cp k.png g.png
	cp w.png b.png
	convert r.png g.png b.png -alpha off -combine -strip rgb.png
	convert rgb.png a.png -alpha off -compose Copy_Opacity -composite -strip nuos-boot-logo-rev.png
	convert nuos.svg -resize '365x90>' -background white -gravity center -extent 375x100 -negate -alpha off -strip a.png
	convert -size 375x100 xc:white -colorspace gray -depth 8 -alpha off -strip w.png
	convert w.png a.png -alpha off -compose Copy_Opacity -composite -strip nuos-boot-brand-rev.png
	convert nuos.svg -colorspace gray -depth 8 -resize '375x90>' -background white -gravity center -extent 385x100 -alpha off -strip nuos-boot-brand.png
	rm a.png b.png g.png k.png r.png rgb.png w.png