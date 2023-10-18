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
	local host_base_ver="`uname -r`"
	if [ "${BASEOS_VER%%-*}" != "${host_base_ver%%-*}" ]; then
		: ${PKG_COLLECTION:=blank}
	else
		: ${PKG_COLLECTION:=$HOSTOS_PKG_COLLECTION}
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
		security/wpa_supplicant
		net/rsync
		security/sudo
		sysutils/lsof
		textproc/jq
		textproc/xsv-rs
		sysutils/ztop
		sysutils/bhyve-firmware
		sysutils/grub2-bhyve
		net/wifi-firmware-ath10k-kmod
		net/wifi-firmware-ath11k-kmod
		net/wifi-firmware-mt76-kmod
		net/wifi-firmware-rtw88-kmod
		net/wifi-firmware-rtw89-kmod
		net/wifibox
		net/ntopng
	'
	
	COLL_developer='
		lite
		graphics/jp2a
		devel/py-setuptools_scm
		devel/subversion
		devel/git
		devel/mercurial
		lang/gawk
		textproc/gsed
		devel/gmake
		sysutils/coreutils
		math/units
		textproc/ydiff
		lang/v
		lang/expect
		math/convertall
		lang/go
		lang/opensycl
		lang/seed7
		textproc/riffdiff
		lang/chez-scheme
		devel/wasmer
		emulators/qemu
	'
	
	COLL_user='
		lite
		textproc/moar
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
		security/strongswan
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
		graphics/vips
		net/vnstat
		databases/postgresql15-server
		databases/postgis33
		databases/pg_activity
		databases/mysql80-server
		databases/redis
		databases/mongodb70
		databases/cassandra4
		databases/cayley
		net/kafka
		devel/zookeeper
		misc/openhab-addons
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
		security/pssh
		sysutils/hilite
		sysutils/py-honcho
		lang/php82-extensions
		www/mod_php82
		www/apache24
		www/mod_qos
		www/nginx
		net/haproxy
		security/snort3
		security/zeek
		security/barnyard2
		security/suricata
		security/lego
		www/matomo
		www/authelia
		net/keycloak
		net-im/ejabberd
		net/rabbitmq
		net/nsq
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
		www/minio
		multimedia/ffmpeg
		multimedia/Bento4
		multimedia/av1an
		www/youtube_dl
		www/yt-dlp
		www/flexget
		www/lux
		www/gallery-dl
		net-p2p/rtorrent
		net-p2p/createtorrent
		net-p2p/mktorrent
		net-p2p/torrentcheck
		multimedia/streamlink
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
		security/palisade
	'
	
	COLL_commonserver='
		mediaserver
		coinserver
	'
	
	COLL_server='
		commonserver
		graphics/optipng
		archivers/zopfli
		graphics/gifsicle
		sysutils/vmdktool
		graphics/povray-meta
		graphics/graphviz
		www/redmine50
		www/rubygem-passenger
		x11-fonts/webfonts
		net-im/jitsi-videobridge
		www/jitsi-meet
		print/gutenprint
	'
	
	COLL_desktop='
		server
		graphics/drm-kmod
		graphics/gpu-firmware-kmod
		net/wpa_supplicant_gui
		net-mgmt/kismet
		x11-wm/wayfire
		x11/wf-shell
		x11/wcm
		x11/alacritty
		x11/swaylock-effects
		x11/swayidle
		x11/wlogout
		x11/ly
		x11/kanshi
		x11/mako
		x11-wm/hyprland
		net/waypipe
		multimedia/helvum
		accessibility/wlsunset
		sysutils/seatd
		sysutils/touchegg
		security/howdy
		devel/tortoisehg
		editors/libreoffice
		graphics/gimp
		graphics/krita
		graphics/inkscape
		audio/audacity
		print/scribus-devel
		deskutils/calibre
		print/fontforge
		x11/xorg
		x11/xeyes
		x11/wshowkeys
		x11/gnome
		x11/kde5
		x11/sddm
		x11/lightdm
		x11/lightdm-gtk-greeter
		x11/lightdm-gtk-greeter-settings
		devel/libqtxdg
		deskutils/xdg-desktop-portal
		sysutils/qtxdg-tools
		x11/libxdg-basedir
		x11/xdg-desktop-portal-gtk
		x11/xdg-desktop-portal-hyprland@qt6
		x11/xdg-desktop-portal-wlr
		sysutils/qtpass
		lang/pharo
		net-p2p/bitcoin
		net-p2p/litecoin
		net-p2p/namecoin
		x11/kitty
		x11/rio
		net/x11vnc
		www/firefox
		multimedia/mpv-mpris
		multimedia/haruna
		java/icedtea-web
		mail/thunderbird
		net/quiterss
		multimedia/vlc
		multimedia/obs-studio
		multimedia/wlrobs
		multimedia/shotcut
		audio/qtractor
		audio/pt2-clone
		audio/fasttracker2
		audio/muse-sequencer
		audio/zrythm
		cad/opencascade
		games/sdlpop
		games/openarena
		games/openrct2
		astro/stellarium
		devel/gwenhywfar
		devel/p5-Module-Build-Tiny
		finance/gnucash
		finance/kmymoney
	'
	
	COLL_nice='
		server
		graphics/blender
		audio/mixxx
		net/kamailio
		www/iridium
		games/veloren-weekly
		net-p2p/cardano-node
		net-p2p/cardano-db-sync
		net-im/py-matrix-synapse
		multimedia/obs-ndi
		multimedia/obs-scrab
		multimedia/obs-streamfx
	'
	
	COLL_nasty='
		nice
		desktop
		math/sage
	'
}
