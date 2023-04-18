all: nuos-mascot.png nuos-brand.png .PHONY

nuos-mascot.png: grumpy_owl-geometry.png badges.png
	convert grumpy_owl-geometry.png badges.png -gravity southeast -composite \
		-type TrueColorAlpha -define png:color-type=6 -define png:bit-depth=8 -strip nuos-mascot.png

nuos-brand.png:
	convert ${NUOS_CODE}/www/org/nuos.svg -resize '375x100>' -background white -gravity center -extent 375x100 \
		\( -fill '#404040' -font Cantarell-Bold -pointsize 11 -gravity southeast 'label:v12.99' \) \
		-composite -negate -alpha off -strip brand-alpha.png
	convert -size 375x100 xc:white brand-alpha.png -alpha off -compose Copy_Opacity -composite \
		-type TrueColorAlpha -define png:color-type=6 -define png:bit-depth=8 -strip nuos-brand.png

grumpy_owl-flat.png:
	convert +antialias ~/Pictures/shutterstock_2279453975.eps'[0]' \
		-gravity southwest -extent 2213x3033 -gravity west -extent 2213x2900 \
		-type TrueColor -auto-level -depth 8 -strip grumpy_owl-flat.png

grumpy_owl-alpha.png: grumpy_owl-flat.png
	convert grumpy_owl-flat.png -colorspace gray \
		-color-threshold '#fefefe-#ffffff' \
		-fill black \
		-draw 'rectangle 1676,950 1678,990' \
		-floodfill +520+1220 '#ffffff' \
		-floodfill +405+1155 '#ffffff' \
		-floodfill +410+1080 '#ffffff' \
		-floodfill +444+1073 '#ffffff' \
		-floodfill +446+1077 '#ffffff' \
		-floodfill +1600+1000 '#ffffff' \
		-floodfill +1615+919 '#ffffff' \
		-floodfill +1660+1080 '#ffffff' \
		-colorspace gray -depth 8 -negate -alpha off \
		-strip grumpy_owl-alpha.png

grumpy_owl.png: grumpy_owl-flat.png grumpy_owl-alpha.png
	convert grumpy_owl-flat.png grumpy_owl-alpha.png -alpha off -compose Copy_Opacity -composite -alpha background \
		-type TrueColorAlpha -strip grumpy_owl.png

grumpy_owl-extended.png: grumpy_owl.png
	convert -background transparent -bordercolor transparent -compose copy -border 12x12 grumpy_owl.png \
		-strip grumpy_owl-extended.png

grumpy_owl-stroke.png: grumpy_owl-extended.png
	convert grumpy_owl-extended.png -alpha extract \
		-morphology Dilate Disk:6.3 -background white -alpha shape \
		-strip grumpy_owl-stroke.png

grumpy_owl-stroked.png: grumpy_owl-extended.png grumpy_owl-stroke.png
	magick grumpy_owl-extended.png grumpy_owl-stroke.png \
		-compose dst-over -composite \
		-strip grumpy_owl-stroked.png

grumpy_owl-geometry.png: grumpy_owl-stroked.png
	convert grumpy_owl-stroked.png -resize '240x256>' -background transparent -gravity west -extent 240x256  \
		-strip grumpy_owl-geometry.png

badges.png:
	magick -gravity east -background transparent \
		\( -fill white -font Cantarell -pointsize 16 'label:extends' -trim \) \
		\( /usr/src/stand/images/freebsd-logo-rev.png \
			\( +clone -alpha extract -fill black -draw 'rectangle 216,12 228,24' \) \
				-alpha off -compose copyalpha -composite \
			 -trim -resize 30% \) \
		\( /usr/src/stand/images/freebsd-brand-rev.png \
			\( +clone -alpha extract -fill black -draw 'rectangle 357,12 367,22' \) \
				-alpha off -compose copyalpha -composite \
			-trim -resize 22.5% \) \
		\( \
			\( -fill white -font Cantarell-Bold -pointsize 16 'label:13.2' \) \
			\( -fill white -font Cantarell -pointsize 16 'label:-' \) \
			\( -fill white -font Cantarell-Bold -pointsize 16 'label:RELEASE' \
				-resize 60%x100% \) \
			+append -trim \) \
		-smush 4 \
		-strip badges.png

clean: .PHONY
	rm -v *.png
