#!/usr/bin/false
set -e; set -u; set -C

# nuOS 0.0.12.999a0 - lib/nu_collection.sh
#
# Copyright (c) 2008-2024 Chad Jacob Milios and Crop Circle Systems.
# All rights reserved.
#
# This Source Code Form is subject to the terms of the Simplified BSD License.
# If a copy of the Simplified BSD License was not distributed alongside this file, you can
# obtain one at https://www.freebsd.org/copyright/freebsd-license.html . This software
# project is not affiliated with the FreeBSD Project.
#
# Official updates and community support available at https://nuos.org .
# Professional services available at https://ccsys.com .

nuos_lib_ver=0.0.12.999a0
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
		net/realtek-re-kmod198
		security/openssh-portable
		net/dhcpcd
		dns/unbound
	'
	
	COLL_base='
		bare
		net/hostapd
		security/wpa_supplicant
		sysutils/pefs-kmod
		net/rsync
		security/gnupg
		dns/libidn2
		dns/libpsl
	'
	
	COLL_lite='
		base
		sysutils/screen
		misc/mbuffer
		sysutils/pipemeter
		archivers/zstd
		archivers/7-zip
		sysutils/pciutils
		sysutils/dmidecode
		sysutils/hw-probe
		comms/hcidump
		sysutils/smartmontools
		sysutils/ipmitool
		sysutils/freeipmi
		sysutils/openipmi
		security/sudo
		sysutils/lsof
		textproc/jq
		devel/llvm17
		lang/gcc13
		textproc/xsv-rs
		sysutils/ztop
		net/ipxe
		net/isboot-kmod
		sysutils/bhyve-firmware
		sysutils/grub2-bhyve
		sysutils/dmg2img
		net/wifi-firmware-kmod
		net/wifibox
		net/ntopng
		sysutils/neofetch
	'
	
	COLL_developer='
		lite
		devel/bsddialog
		ports-mgmt/portconfig
		graphics/jp2a
		devel/subversion
		devel/git
		devel/git-lfs
		devel/mercurial
		lang/gawk
		textproc/gsed
		devel/gmake
		sysutils/coreutils
		security/nmap
		math/units
		textproc/ydiff
		lang/v
		lang/expect
		math/convertall
		lang/python
		lang/ruby33
		lang/go
		www/npm
		lang/seed7
		lang/racket
		lang/cim
		textproc/riffdiff
		lang/chez-scheme
		emulators/qemu
		editors/vim
		editors/neovim
	'
	
	COLL_user='
		lite
		sysutils/password-store
		sysutils/pass-otp
		security/py-xkcdpass
		textproc/moar
		finance/ledger
		irc/irssi
		textproc/en-aspell
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
		security/tailscale
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
		mail/cyrus-imapd38
		security/cyrus-sasl2-saslauthd
		graphics/vips
		net/vnstat
		databases/postgresql16-server
		databases/postgis34
		databases/pg_activity
		databases/mysql81-server
		databases/redis
		databases/mongodb70
		databases/mongodb-tools
		databases/cassandra4
		databases/cayley
		net/kafka
		devel/zookeeper
		misc/openhab-addons
		lang/squeak
		lang/gravity
		lang/wren
		lang/janet
		java/openjdk21
		textproc/zed
		math/or-tools
		sysutils/parallel
		security/pssh
		sysutils/hilite
		sysutils/py-honcho
		lang/php83-extensions
		www/mod_php83
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
		security/shibboleth-sp
		security/shibboleth-idp
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
		net/samba419
		www/minio
		multimedia/ffmpeg
		multimedia/Bento4
		multimedia/av1an
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
		net-p2p/bitcoincash-daemon
		net-p2p/bitcoincash-utils
		net-p2p/bitcoingold-daemon
		net-p2p/bitcoingold-utils
		net-p2p/monero-cli
		finance/vanitygen++
		security/solana
		security/openfhe
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
		www/forgejo
		www/rubygem-passenger
		x11-fonts/webfonts
		net/kamailio
		net-im/jitsi-videobridge
		www/jitsi-meet
		print/gutenprint
		print/brlaser
	'
	
	COLL_desktop='
		server
		graphics/drm-kmod
		graphics/gpu-firmware-kmod
		misc/utouch-kmod
		sysutils/radeontop
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
		net/waypipe
		multimedia/helvum
		accessibility/wlsunset
		sysutils/seatd
		sysutils/touchegg
		security/howdy
		devel/tortoisehg
		editors/neovim-qt@qt6
		editors/neovim-gtk
		editors/emacs
		editors/calligra
		editors/libreoffice
		graphics/gimp
		graphics/krita
		graphics/inkscape
		print/scribus
		print/fontforge
		x11/xorg
		graphics/scrot
		x11/xeyes
		x11/wshowkeys
		x11/gnome
		x11/kde5
		security/kleopatra
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
		security/openssh-askpass
		sysutils/qtpass
		graphics/zbar
		sysutils/plasma-pass
		graphics/qtqr
		devel/godot
		devel/godot-tools
		lang/pharo
		net-p2p/bitcoin
		net-p2p/litecoin
		net-p2p/namecoin
		net-p2p/bitcoincash
		net-p2p/bitcoingold
		x11/kitty
		x11/rio
		net/x11vnc
		www/firefox
		multimedia/mpv-mpris
		multimedia/haruna
		java/icedtea-web
		mail/thunderbird
		multimedia/vlc
		multimedia/obs-studio
		multimedia/wlrobs
		multimedia/shotcut
		net-p2p/qbittorrent
		audio/qtractor
		audio/pt2-clone
		audio/ft2-clone
		audio/audacity
		audio/muse-sequencer
		audio/zrythm
		audio/mixxx
		cad/opencascade
		graphics/blender
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
		devel/wasmer
		net/ntp
		net-p2p/bitcoinsv-daemon
		net-p2p/bitcoinsv-utils
		www/redmine51
		www/iridium
		games/veloren-weekly
		net-p2p/cardano-node
		net-p2p/cardano-db-sync
		net-im/py-matrix-synapse
		multimedia/obs-ndi
		multimedia/obs-scrab
		multimedia/obs-streamfx
		lang/opensycl
		lang/crystal
	'
	
	COLL_nasty='
		nice
		desktop
		x11/sddm
		math/sage
		deskutils/calibre
		x11-wm/hyprland
	'
}
