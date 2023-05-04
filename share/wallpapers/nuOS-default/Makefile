SAMPLES=	3840x2400 3840x2160 3200x2000 3200x1800 2560x1600 2560x1440 1920x1200 1920x1080 1080x1920 1600x1200 1680x1050 1280x1024 1440x900 1366x768 720x1440 1280x800 1024x768 360x720 440x247
DESTDIR=	/usr/local/share/wallpapers/nuOS-default
SKELDIR=	/usr/share/skel

all: .samples contents/screenshot.png

contents/screenshot.png: .samples
	cp contents/images/440x247.png contents/screenshot.png

.samples: contents/images/${SAMPLES:[1]}.png
	for s in ${SAMPLES:[2..-1]}; do \
		w=$${s%x*}; \
		h=$${s#*x}; \
		if [ $$w -gt $$h ]; then \
			echo -n $$s; \
			convert contents/images/${SAMPLES:[1]}.png -resize "$$s>" +repage -gravity center -crop $$s+0+0 +repage \
				-alpha off -strip contents/images/$$s.png; \
			echo .png; \
		fi; \
	done
	optipng -v -force -i0 -zc9 -zm8 -zs1 -f5 contents/images/*.png
	touch .samples

contents/images/${SAMPLES:[1]}.png:
	mkdir -p contents/images
	convert src/original.png -gravity center -crop ${SAMPLES:[1]}+0+0 +repage \
		-alpha off -strip contents/images/${SAMPLES:[1]}.png

install: all .PHONY
	mkdir -p ${DESTDIR}
	cp -r contents metadata.json ${DESTDIR}/
	mkdir -p ${SKELDIR}/dot.config/plasma-workspace/env/
	cp set-nuOS-wallpaper.sh ${SKELDIR}/dot.config/plasma-workspace/env/
	cp kscreenlockerrc ${SKELDIR}/dot.config/

clean: .PHONY
	rm -rf contents .samples