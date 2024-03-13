SITE=		nuOS.net
SERVER=		CargoBay.net
ADMIN=		jedi
RSYNC=		${ADMIN}@${SERVER:tl}:/var/jail/www/home/${ADMIN}/${SITE:tl}/www/public

.SUFFIXES:
.SUFFIXES: .css .html .ttf .otf .svg .x[ms]l .t{,e}xt .js


build: prep .PHONY

deploy: rsync .PHONY

all: build deploy .PHONY

prep: web-imgs .prep .PHONY

rsync: .rsync .PHONY

.rsync:
	rsync -avP --delete ${PWD}/ ${RSYNC}/
	touch .rsync

.prep: ${.SUFFIXES:S/^/*/}
	gzip -kn9f $?
	touch .prep
	rm -f .rsync

web-imgs: eagle-mask.png eagle.webp

eagle-sm.png: eagle.png
	convert eagle.png -resize 864x -bordercolor transparent -border 80x80 -strip eagle-sm.png

eagle-mask.png: eagle-sm.png
	convert eagle-sm.png -alpha extract -morphology Dilate Disk:2.3 -background black -alpha shape -strip eagle-mask.png
	# optipng -o5 eagle-mask.png

eagle.jpg: eagle-sm.png index.css
	convert eagle-sm.png -background "`sed -nEe '/^:root *\{/,/}/s/^.*--banner: *(.+);$$/\1/p' index.css`" \
		-flatten -quality 60% -define jpeg:dct-method=islow -interlace Plane eagle.jpg

eagle-flat.png: eagle-sm.png index.css
	convert eagle-sm.png -background "`sed -nEe '/^:root *\{/,/}/s/^.*--banner: *(.+);$$/\1/p' index.css`" \
		-flatten -strip eagle-flat.png

eagle.webp: eagle-flat.png eagle-mask.png
	magick eagle-flat.png eagle-mask.png -compose copy_opacity -composite -quality 67 -define webp:alpha-quality=80 eagle.webp

clean: .PHONY
	rm -vf *.gz .rsync .prep
	rm -vf eagle-mask.png eagle-sm.png eagle.jpg eagle.webp eagle-flat.png
