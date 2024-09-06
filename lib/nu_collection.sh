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
		sysutils/cpu-microcode
		net/realtek-re-kmod198
		security/openssh-portable
		net/dhcpcd
		dns/unbound
		dns/knot-resolver
	'
	
	COLL_base='
		bare
		net/hostapd
		security/wpa_supplicant
		net-mgmt/net-snmp
		net/ntp
		sysutils/pefs-kmod
		net/rsync
		security/gnupg
		dns/libidn2
		dns/libpsl
	'
	
	COLL_lite='
		base
		sysutils/limine
		sysutils/screen49
		misc/mbuffer
		sysutils/pipemeter
		archivers/zstd
		archivers/7-zip
		sysutils/pciutils
		sysutils/dmidecode
		sysutils/hw-probe
		comms/hcidump
		sysutils/acpica-tools
		sysutils/znapzend
		sysutils/smartmontools
		sysutils/ddpt
		sysutils/sg3_utils
		devel/efivar
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
		sysutils/btop
		sysutils/htop
		net/ntopng
		sysutils/py-glances@py311
		sysutils/bottom
		sysutils/usbtop
		net/ipxe
		net/isboot-kmod
		sysutils/bhyve-firmware
		sysutils/grub2-bhyve
		sysutils/dmg2img
		net/wifi-firmware-kmod
		net/wifibox
		emulators/libc6-shim
	'
	
	COLL_developer='
		lite
		devel/bsddialog
		ports-mgmt/portconfig
		security/osv-scanner
		lang/rizin-cutter
		devel/ghidra
		devel/cppcheck
		archivers/rpm4
		devel/xdg-dbus-proxy
		graphics/jp2a
		devel/subversion
		devel/git
		devel/git-lfs
		devel/mercurial
		lang/gawk
		textproc/gsed
		devel/gmake
		sysutils/coreutils
		sysutils/heirloom
		textproc/heirloom-doctools
		devel/heirloom-devtools
		devel/pika
		security/nmap
		dns/packetq
		dns/dsc
		dns/dnsjit
		math/units
		textproc/ydiff
		sysutils/siegfried
		www/hurl
		devel/llvm18
		lang/gcc14
		math/lean4
		lang/v
		devel/kokkos
		lang/expect
		math/convertall
		lang/perl5.38
		lang/perl5.40
		lang/php83-extensions
		databases/mysql90-client
		lang/python
		lang/python312
		lang/ruby33
		lang/go
		lang/go123
		lang/rust
		lang/emilua
		lang/sbcl
		lang/ecl
		devel/eql5
		lang/guile3
		lang/chez-scheme
		lang/ocaml
		lang/ldc
		lang/squeak
		lang/algol68g
		lang/gravity
		lang/wren-cli
		lang/janet
		math/cvc5
		math/yices
		lang/maude
		lang/crystal
		devel/shards
		java/openjdk21
		java/openjdk22
		devel/gradle
		textproc/zed
		textproc/zq
		devel/wasmer
		www/wabt
		lang/mono6.8
		www/node
		www/npm
		www/yarn
		www/deno
		lang/erlang
		lang/erlang-runtime25
		lang/erlang-runtime26
		devel/rebar3
		lang/elixir
		devel/stack
		multimedia/arcan
		sysutils/mise
		lang/nim
		lang/seed7
		lang/racket
		lang/cairo
		lang/cim
		lang/halide
		sysutils/py-upt
		www/zola
		www/gohugo
		devel/libsigsegv
		devel/linux-rl9-libsigsegv
		devel/linux-rl9-devtools
		sysutils/linux-miniconda-installer
		textproc/riffdiff
		emulators/qemu
		emulators/unicorn
		editors/vim
		editors/neovim
		math/octave
		math/octave-forge
		math/geogebra
		math/maxima
		math/R
		net/spoofdpi
		emulators/qemu-user-static
		archivers/nfpm
		devel/pipelight
		devel/lefthook
	'
	
	COLL_user='
		lite
		sysutils/keyd
		sysutils/netevent
		sysutils/password-store
		sysutils/pass-otp
		security/py-xkcdpass
		security/rbw
		textproc/moar
		net/trippy
		finance/ledger
		irc/irssi
		textproc/en-aspell
		textproc/ripgrep
		shells/pdksh
		shells/ksh
		shells/zsh
		shells/fish
		shells/bash
		shells/dash
		shells/xonsh@py311
		shells/heirloom-sh
		mail/heirloom-mailx
		sysutils/faketty
		sysutils/parallel
		security/pssh
		games/cxxmatrix
		www/tgpt
		misc/toilet
		misc/figlet-fonts
		misc/tdfiglet
		sysutils/shuf
		sysutils/neofetch
		sysutils/pfetch
		sysutils/fastfetch
		sysutils/ufetch
		sysutils/bsdebfetch
		sysutils/cpufetch
		sysutils/bsdinfo
		sysutils/bsdhwmon
		net/speedtest-go
	'
	
	COLL_miniserver='
		developer
		user
		security/pam_script
		sysutils/ngbuddy
		net-mgmt/lldpd
		net/dpdk
		net/vpp
		mail/postfix
		mail/opendkim
		mail/opendmarc
		dns/knot3
		security/zlint
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
		irc/inspircd
		ftp/pure-ftpd
		net/isc-dhcp44-server
		net/istgt
		net/mosquitto
		mail/cyrus-imapd38
		security/cyrus-sasl2-saslauthd
		graphics/vips
		net/vnstat
		net/eturnal
		security/vaultwarden
		databases/postgresql16-server
		databases/postgis34
		databases/pg_activity
		databases/timescaledb
		databases/timescaledb-backup
		databases/timescaledb-tune
		databases/mysql90-server
		databases/redis
		databases/mongodb70
		databases/mongodb-tools
		databases/cassandra4
		databases/cayley
		net/kafka
		devel/zookeeper
		misc/openhab-addons
		sysutils/hilite
		sysutils/py-honcho
		www/mod_php83
		www/apache24
		www/mod_qos
		www/nginx
		net/haproxy
		www/trunk
		security/snort3
		security/zeek
		security/barnyard2
		security/suricata
		security/lego
		net-mgmt/fastnetmon
		www/matomo
		www/authelia
		net/keycloak
		mail/nocc
		mail/snappymail
		net-im/ejabberd
		net/rabbitmq
		net/nsq
		net/natscli
		net/nats-top
		net/nats-streaming-server
		net/nats-server
		net/nats-nsc
		net/nats-nkeys
		sysutils/kubo-go
		security/tor
		net/torsocks
		security/i2pd
		net-mgmt/librenms
		net-mgmt/observium
		net-mgmt/prometheus2
		databases/prometheus-postgresql-adapter
		databases/prometheus-postgres-exporter
		net-mgmt/prometheus-collectd-exporter
		dns/prometheus-dnssec-exporter
		sysutils/py-prometheus-zfs
		www/nginx-prometheus-exporter
		net-mgmt/nvidia_gpu_prometheus_exporter
		net-mgmt/mqtt2prometheus
		www/grafana
	'
	
	COLL_mediaserver='
		miniserver
		multimedia/pwcbsd
		multimedia/webcamd
		www/httrack
		net/netatalk3
		net/samba419
		www/minio
		multimedia/ffmpeg
		multimedia/uvg266
		multimedia/gstreamer1-plugins-all
		multimedia/gstreamer1-qt
		multimedia/gstreamer1-vaapi
		multimedia/gstreamer1-validate
		multimedia/gstreamer1-rtsp-server
		multimedia/gstreamer1-editing-services
		multimedia/gstreamermm
		multimedia/Bento4
		multimedia/av1an
		www/yt-dlp
		www/flexget
		www/lux
		www/gallery-dl
		multimedia/ytfzf
		net-p2p/rtorrent
		net-p2p/createtorrent
		net-p2p/mktorrent
		net-p2p/torrentcheck
		multimedia/streamlink
		audio/shairport-sync
		audio/owntone
		sysutils/android-file-transfer
		www/galene
		multimedia/zoneminder
		multimedia/linux_dvbwrapper-kmod
		graphics/potrace
		audio/virtual_oss_ctl
		graphics/filament
	'
	
	COLL_coinserver='
		miniserver
		net-p2p/bitcoin-daemon
		net-p2p/bitcoin-utils
		finance/ord
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
		sysutils/docker
		sysutils/docker-compose
		sysutils/docker-credential-pass
		sysutils/docker-machine
		sysutils/docker-registry
		sysutils/containerd
		sysutils/helm
		sysutils/helmfile
		sysutils/kapp
		sysutils/podman-suite
		devel/etcd34
		net/kube-apiserver
		net/kube-controller-manager
		net/kube-scheduler
		sysutils/kubectl
		sysutils/minikube
		sysutils/minipot
		sysutils/potnet
		net-p2p/nomadnet
	'
	
	COLL_server='
		commonserver
		security/certspotter
		graphics/optipng
		archivers/zopfli
		graphics/gifsicle
		graphics/guetzli
		sysutils/vmdktool
		www/librespeed
		graphics/povray-meta
		graphics/graphviz
		www/forgejo
		www/rubygem-passenger
		www/redmine51
		finance/prestashop
		x11-fonts/webfonts
		net/kamailio
		net-im/jitsi-videobridge
		www/jitsi-meet
		print/gutenprint
		print/brlaser
		print/ipp-usb
		misc/llama-cpp
		misc/ollama
		misc/py-ollama@py311
		misc/py-oterm@py311
		misc/alpaca
		misc/koboldcpp
		misc/aichat
		devel/py-jupyterlab@py311
		devel/py-jupyterlab-lsp@py311
		textproc/py-jupyterlab-pygments@py311
		devel/py-jupyterlab_launcher@py311
		textproc/py-jupyter_sphinx@py311
		devel/py-pytest-jupyter@py311
		devel/py-jupyter_console@py311
		devel/py-jupyter-packaging@py311
		devel/py-jupyter-telemetry@py311
		devel/py-jupyter-collaboration@py311
		devel/py-jupyter-server-fileid@py311
		devel/py-jupyter-kernel-test@py311
		devel/py-jupyter-server-mathjax@py311
		devel/py-jupyter-ydoc@py311
		devel/evcxr-jupyter
		misc/pytorch
		misc/py-pytorch@py311
		audio/py-torchaudio@py311
		math/py-pytorchvideo@py311
		misc/py-facenet-pytorch@py311
		misc/py-pytorch-lightning@py311
		misc/py-torch-geometric@py311
		misc/py-torchmetrics@py311
		misc/py-torchvision@py311
		misc/py-wandb
	'
	
	COLL_desktop='
		server
		graphics/drm-kmod
		graphics/gpu-firmware-kmod
		x11/nvidia-driver
		graphics/nvidia-drm-kmod
		graphics/nvidia-texture-tools
		x11/nvidia-xconfig
		x11/nvidia-settings
		multimedia/libva-nvidia-driver
		x11/linux-nvidia-libs
		graphics/linux-rl9-dri
		graphics/linux-rl9-vulkan
		misc/utouch-kmod
		x11/antimicrox
		sysutils/radeontop
		graphics/vulkan-caps-viewer
		graphics/vulkan-extension-layer
		graphics/vulkan-headers
		graphics/vulkan-loader
		graphics/vulkan-tools
		graphics/vulkan-utility-libraries
		graphics/vulkan-validation-layers
		graphics/spirv-tools
		graphics/spirv-cross
		devel/spirv-llvm-translator
		multimedia/libva-vdpau-driver
		multimedia/libvdpau
		multimedia/libvdpau-va-gl
		graphics/mesa-gallium-vdpau
		multimedia/linux-rl9-libvdpau
		multimedia/vdpauinfo
		graphics/linux-rl9-libglvnd
		multimedia/simplescreenrecorder
		multimedia/wl-screenrec
		net/wpa_supplicant_gui
		net-mgmt/kismet
		x11/rofi-pass
		x11/rofi-rbw
		x11-wm/durden
		graphics/aloadimage
		x11/aclip
		x11-servers/xarcan
		x11-wm/labwc
		x11-wm/wayfire
		x11/wf-shell
		x11/wcm
		x11/alacritty
		x11/swaylock-effects
		x11/swayidle
		x11/wlogout
		x11/ly
		x11-wm/hyprland
		x11/kanshi
		x11/mako
		net/waypipe
		multimedia/helvum
		accessibility/wlsunset
		sysutils/seatd
		sysutils/touchegg
		security/howdy
		graphics/sdl2_gpu
		devel/tortoisehg
		editors/neovim-qt@qt6
		editors/neovim-gtk
		editors/languageclient-neovim
		editors/vim-lsp
		editors/kakoune
		editors/kakoune-lsp
		editors/emacs
		editors/calligra
		editors/libreoffice
		graphics/gimp
		graphics/gmic-qt
		graphics/krita
		graphics/inkscape
		print/scribus
		print/fontforge
		x11/xorg
		x11/scripts
		net/xrdp
		x11-drivers/xorgxrdp
		x11/xnotify
		deskutils/fyi
		sysutils/tiramisu
		x11-clocks/wlclock
		graphics/scrot
		x11/xeyes
		x11/screenkey
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
		x11/xdg-desktop-portal-hyprland
		x11/xdg-desktop-portal-wlr
		security/openssh-askpass
		sysutils/qtpass
		graphics/zbar
		sysutils/plasma-pass
		graphics/qtqr
		x11/tessen
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
		net/spiritvnc
		www/novnc
		multimedia/py-tartube
		x11/xpra
		x11/xpra-html5
		sysutils/conky
		www/firefox
		multimedia/mpv-mpris
		multimedia/mpvpaper
		multimedia/haruna
		java/icedtea-web
		mail/thunderbird
		net-im/dissent
		net-im/fractal
		multimedia/vlc
		multimedia/mpc-qt
		multimedia/gtk-youtube-viewer
		multimedia/v4l-utils
		multimedia/obs-studio
		multimedia/wlrobs
		multimedia/shotcut
		net-p2p/qbittorrent
		comms/scrcpy
		audio/qjackctl
		audio/qtractor
		audio/pt2-clone
		audio/ft2-clone
		audio/audacity
		audio/muse-sequencer
		audio/zrythm
		audio/mixxx
		audio/lsp-plugins-lv2
		math/wxmaxima
		cad/opencascade
		graphics/blender
		devel/gwenhywfar
		devel/p5-Module-Build-Tiny
		finance/gnucash
		finance/kmymoney
		cad/qcad
		science/opensim-core
		cad/PrusaSlicer
		cad/cura
		emulators/wine-proton
		databases/pgmodeler
		devel/RStudio@desktop
	'
	
	COLL_gamer='
		desktop
		astro/stellarium
		games/sdlpop
		games/openarena
		games/urbanterror-data
		games/wesnoth
		games/0ad
		games/SRB2
		games/astromenace
		games/bzflag
		games/brutalchess
		games/connectfive
		games/cgoban
		games/diaspora
		games/endgame-singularity
		games/endless-sky-high-dpi
		games/el
		games/dunelegacy
		games/flightgear
		games/formido
		games/foobillard
		games/evq3
		games/etracer
		games/etlegacy
		games/freecol
		games/freeciv21
		games/freeorion
		games/frogatto
		games/frozen-bubble
		games/gigalomania
		games/glest
		games/goonies
		games/gracer
		games/hedgewars
		games/hedgewars-server
		games/heretic
		games/hexxagon
		games/highmoon
		emulators/fceux
		emulators/higan
		emulators/mednafen
		games/jumpy
		games/jumpnbump
		games/irrlamb
		games/iqpuzzle
		games/lugaru
		games/lincity-ng
		games/lander
		games/megamario
		games/megaglest
		games/mari0
		games/marblemarcher
		games/netrek-client-cow
		games/nexuiz
		games/neverball
		games/moonlight-qt
		games/open-adventure
		games/oolite
		games/opensonic
		games/openmortal
		games/openclonk
		games/openclaw
		games/opencity
		games/openttd
		games/opengfx
		games/openmsx
		games/opensfx
		games/opentyrian
		games/tyrian-data
		games/opensurge
		games/openssn
		games/pioneers
		games/pioneer
		games/phlipple
		games/pingus
		games/pinball
		games/pengupop
		games/pacmanarena
		games/prboom-plus
		games/primateplunge
		games/punchy
		games/openyahtzee
		games/powermanga
		games/powder-toy
		games/pokerth
			devel/py-flit-core@py311
			x11-toolkits/py-wxPython4@py311
			devel/py-flit-core@py39
			x11-toolkits/py-wxPython4@py39
		emulators/playonbsd
		emulators/ares
		games/veloren-weekly
		games/simutrans
		games/tesseract
		games/supertux
		games/supertux2
		games/supertuxkart
		games/stormbaancoureur
		graphics/ogre3d
		games/gogrepo
		games/torcs
		games/toycars
		games/trackballs
		games/traingame
		games/triplane
		games/tuxracer
		games/trigger-rally
		games/voadi
		games/ultimatestunts
		games/unknown-horizons
		games/untahris
		games/ufoai
		games/vamos
		games/vkquake
		games/wolfpack
		games/wop
		games/wordwarvi
		games/worldofpadman
		games/wyrmsun
		games/uqm
		games/xpilot-ng-server
		games/xpilot
		games/xonotic
		games/xbill
		games/xlennart
		games/xkoules
		games/xinvaders3d
		games/xeyesplus
		games/xfireworks
		games/xdesktopwaves
		games/xconq
		games/xblackjack
		games/xbl
		games/widelands
		games/whichwayisup
		games/warzone2100
		games/warmux
		games/xrally
		games/xsc
	'
	
	COLL_nice='
		gamer
		games/minecraft-server
		games/minecraft-client
		security/shibboleth-sp
		security/shibboleth-idp
		net/lavinmq
		math/sage
		multimedia/makemkv
		security/bitwarden-cli
		editors/vscode
		math/or-tools
		games/stuntrally
		devel/py-jupyterlab-widgets@py311
		science/py-jupyter_jsmol@py311
		games/emptyepsilon
		games/pink-pony
		games/palomino
		devel/jenkins
		net/krill
		multimedia/kooha
		audio/mousai
		net-p2p/bitcoinsv-daemon
		net-p2p/bitcoinsv-utils
		www/librewolf
		www/iridium
		net-p2p/cardano-node
		net-p2p/cardano-db-sync
		net-im/py-matrix-synapse
		multimedia/obs-ndi
		multimedia/obs-scrab
		multimedia/obs-streamfx
		lang/opensycl
		deskutils/calibre
		games/openbve
	'
	
	COLL_nasty='
		nice
		desktop
		x11/sddm
	'
}
