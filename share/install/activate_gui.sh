sister enable_svc -C "$TRGT" nuos_gui seatd dbus hald webcamd

if canhas ${GPU_VENDOR-}; then
	case $GPU_VENDOR in
		[Aa][Mm][Dd]) gpu_kmod=amdgpu;;
		[Ii][Nn][Tt][Ee][Ll]) gpu_kmod=i915kms;;
		[Rr][Aa][Dd][Ee][Oo][Nn]) gpu_kmod=radeonkms;;
	esac
	cat >> "$TRGT/etc/rc.conf.local" <<EOF
kld_list="\$kld_list $gpu_kmod"
EOF
fi

mkdir -m 1777 "$TRGT/var/run/user"

cat >> "$TRGT/etc/gettytab" <<'EOF'
Ly:\
	:lo=/usr/local/bin/ly:\
	:al=root:
EOF

if canhas ${DISPLAY_MANAGER-}; then
	case $DISPLAY_MANAGER in
		[Ll][Yy])
			sed -i '' -e '/^ttyv1[[:space:]]/s/[[:<:]]Pc[[:>:]]/Ly/' "$TRGT/etc/ttys"
		;;
		[Ll][Ii][Gg][Hh][Tt])
			sister enable_svc -C "$TRGT" lightdm
		;;
	esac
fi

for u in $ADMIN_ACCT $USER_ACCT; do
	uid=`pw -R "$TRGT" usershow -n $u | cut -d: -f3`
	pw -R "$TRGT" groupmod video -m $u
	mkdir -p "$TRGT/etc/nuos/gui_active"
	touch "$TRGT/etc/nuos/gui_active/v0"
	sed -i '' -e '/\<begin:nuOS-activate_gui\>/,/\<end:nuOS-activate_gui\>/d' "$TRGT/home/$u/.login" "$TRGT/home/$u/.profile"
	cat >> "$TRGT/home/$u/.login" <<EOF
##### begin:nuOS-activate_gui #####
test -f /etc/nuos/gui_active/v0 && setenv XDG_RUNTIME_DIR /var/run/user/$uid
test -f /etc/nuos/gui_active/v0 && /bin/mkdir -p "\${XDG_RUNTIME_DIR}"
test -f /etc/nuos/gui_active/v0 && /bin/chflags uunlink "\${XDG_RUNTIME_DIR}"
test -f /etc/nuos/gui_active/v0 && /bin/chmod 700 "\${XDG_RUNTIME_DIR}"
##### end:nuOS-activate_gui #####
EOF
	cat >> "$TRGT/home/$u/.profile" <<EOF
##### begin:nuOS-activate_gui #####
test -f /etc/nuos/gui_active/v0 && export XDG_RUNTIME_DIR=/var/run/user/$uid
test -f /etc/nuos/gui_active/v0 && /bin/mkdir -p "\$XDG_RUNTIME_DIR"
test -f /etc/nuos/gui_active/v0 && /bin/chflags uunlink "\$XDG_RUNTIME_DIR"
test -f /etc/nuos/gui_active/v0 && /bin/chmod 700 "\$XDG_RUNTIME_DIR"
##### end:nuOS-activate_gui #####
EOF
done
