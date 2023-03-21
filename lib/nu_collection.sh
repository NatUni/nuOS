#!/usr/bin/false
set -e; set -u; set -C

# nuOS 0.0.12.99a0 - lib/nu_collection.sh
#
# Copyright (c) 2008-2022 Chad Jacob Milios and Crop Circle Systems.
# All rights reserved.
#
# This Source Code Form is subject to the terms of the Simplified BSD License.
# If a copy of the Simplified BSD License was not distributed alongside this file, you can
# obtain one at https://www.freebsd.org/copyright/freebsd-license.html . This software
# project is not affiliated with the FreeBSD Project.
#
# Official updates and community support available at https://nuos.org .
# Professional services available at https://ccsys.com .

nuos_lib_ver=0.0.12.99a0
[ $nuos_lib_ver = "$NUOS_VER" ]
[ -n "${nuos_lib_system_loaded-}" ]
[ -z "${nuos_lib_collection_loaded-}" ]
nuos_lib_collection_loaded=y

: ${HOSTOS_PKG_COLLECTION:=desktop}

reset_pkg_collection () {
	: ${PKG_COLLECTION:=$HOSTOS_PKG_COLLECTION}
	
	local host_base_ver="`uname -r`"
	
	if [ "${BASEOS_VER%%-*}" != "${host_base_ver%%-*}" ]; then
		PKG_COLLECTION=blank
	fi
	if [ -q != "${1-}" ]; then
		echo 'pkg collection  -c PKG_COLLECTION ' $PKG_COLLECTION
	fi
}

collection_vars_init () {
	
	reset_pkg_collection ${1-}
	
	COLL_blank=
	
	COLL_pkg='
		blank
		ports-mgmt/pkg
	'
	
	COLL_bare='
		pkg
		net/ipxe
		net/isboot-kmod
		net/realtek-re-kmod
		sysutils/pefs-kmod
		security/openssh-portable
		security/wpa_supplicant
		net/hostapd
		net/dhcpcd
		dns/unbound
	'
	
	COLL_base='
		bare
		security/gnupg
	'
	
	COLL_lite='
		base
		sysutils/screen
		misc/buffer
		sysutils/pipemeter
		archivers/zstd
		archivers/7-zip
		sysutils/pciutils
		sysutils/dmidecode
		sysutils/smartmontools
		sysutils/ipmitool
		sysutils/freeipmi
		sysutils/openipmi
		net/rsync
		security/sudo
		sysutils/lsof
		textproc/jq
		textproc/xsv-rs
		sysutils/ztop
		sysutils/bhyve-firmware
		sysutils/grub2-bhyve
	'
	
	COLL_developer='
		lite
		devel/subversion
		devel/git
		devel/mercurial
		lang/gawk
		textproc/gsed
		devel/gmake
		sysutils/coreutils
		textproc/ydiff
		lang/v
		lang/expect
		math/convertall
	'
	
	COLL_user='
		lite
		finance/ledger
		irc/irssi
		net-im/tut
	'
	
	COLL_miniserver='
		developer
		user
		net-mgmt/lldpd
		mail/postfix
		mail/opendkim
		mail/opendmarc
		dns/knot3
		security/acme.sh
		net/openldap26-server
		security/openvpn
		net/mpd5
		textproc/gtk-doc
		net/avahi
		dns/nss_mdns
		net/3proxy
		ftp/pure-ftpd
		net/isc-dhcp44-server
		net/istgt
		net/mosquitto
		mail/cyrus-imapd34
		security/cyrus-sasl2-saslauthd
		databases/postgresql15-server
		databases/postgis33
		databases/pg_activity
		databases/mysql80-server
		databases/redis
		databases/mongodb50
		lang/go
		lang/squeak
		lang/gravity
		lang/crystal
		lang/wren
		lang/janet
		lang/python
		lang/ruby32
		java/openjdk19
		textproc/zed
		math/or-tools
		www/npm
		sysutils/parallel
		sysutils/hilite
		sysutils/py-honcho
		lang/php82-extensions
		graphics/pecl-imagick-im7
		www/mod_php82
		www/apache24
		www/nginx
		net/haproxy
		security/snort3
		security/barnyard2
		security/suricata
		www/matomo
		www/authelia
		net/keycloak
		net-im/ejabberd
		net/rabbitmq
		lang/erlang-runtime25
		lang/elixir
		devel/stack
		sysutils/ipfs-go
		security/tor
	'
	
	COLL_mediaserver='
		miniserver
		misc/toilet
		www/httrack
		net/netatalk3
		net/samba416
		multimedia/ffmpeg
		multimedia/Bento4
		www/youtube_dl
		www/yt-dlp
		www/flexget
		www/lux
		www/gallery-dl
		net-p2p/rtorrent
		net-p2p/createtorrent
		net-p2p/torrentcheck
	'
	
	COLL_coinserver='
		miniserver
		net-p2p/bitcoin-daemon
		net-p2p/bitcoin-utils
		net-p2p/litecoin-daemon
		net-p2p/litecoin-utils
		net-p2p/namecoin-daemon
		net-p2p/namecoin-utils
		net-p2p/monero-cli
	'
	
	COLL_commonserver='
		mediaserver
		coinserver
	'
	
	COLL_server='
		commonserver
		graphics/optipng
		graphics/gifsicle
		sysutils/vmdktool
		graphics/povray-meta
		graphics/graphviz
		x11-fonts/webfonts
		net-im/jitsi-videobridge
		www/jitsi-meet
		print/gutenprint
	'
	
	COLL_desktop='
		server
		graphics/drm-kmod
		graphics/gpu-firmware-kmod
		sysutils/touchegg
		editors/libreoffice
		graphics/gimp
		graphics/krita
		graphics/inkscape
		audio/audacity
		print/scribus-devel
		deskutils/calibre
		print/fontforge
		x11/xorg
		x11/gnome
		x11/kde5
		x11/sddm
		lang/pharo
		net-p2p/bitcoin
		net-p2p/litecoin
		net-p2p/namecoin
		x11/kitty
		net/x11vnc
		www/firefox
		www/chromium
		java/icedtea-web
		mail/thunderbird
		net/quiterss
		multimedia/vlc
		multimedia/obs-studio
		multimedia/wlrobs
		multimedia/obs-qtwebkit
		multimedia/shotcut
		graphics/blender
		games/sdlpop
	'
	
	COLL_nice='
		server
		net-p2p/cardano-node
		net-p2p/cardano-db-sync
		security/zeek
		net/kamailio
		net-im/py-matrix-synapse
		multimedia/obs-ndi
		multimedia/obs-scrab
		multimedia/obs-streamfx
		games/openarena
		security/palisade
		cad/opencascade
		math/fplll
		math/maxima
		audio/zrythm
		audio/muse-sequencer
	'
	
	COLL_nasty='
		nice
		desktop
		finance/gnucash
		finance/kmymoney
		finance/jgnash
		math/sage
		audio/protracker
		audio/fasttracker2
		audio/mixxx
	'
}
