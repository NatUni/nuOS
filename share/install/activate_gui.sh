sister enable_svc -C "$TRGT" seatd dbus hald webcamd
mkdir -m 1777 "$TRGT/var/run/user"
cat >> "$TRGT/etc/gettytab" <<'EOF'
Ly:\
	:lo=/usr/local/bin/ly:\
	:al=root:
EOF
sed -i '' -e '/^ttyv1[[:space:]]/s/[[:<:]]Pc[[:>:]]/Ly/' "$TRGT/etc/ttys"
for u in $ADMIN_ACCT $USER_ACCT; do
	uid=`pw -R "$TRGT" usershow -n $u | cut -d: -f3`
	pw -R "$TRGT" groupmod video -m $u
	cat >> "$TRGT/home/$u/.login" <<EOF
setenv XDG_RUNTIME_DIR /var/run/user/$uid
/bin/mkdir -p "\${XDG_RUNTIME_DIR}"
/bin/chflags uunlink "\${XDG_RUNTIME_DIR}"
/bin/chmod 700 "\${XDG_RUNTIME_DIR}"
EOF
	cat >> "$TRGT/home/$u/.profile" <<EOF
export XDG_RUNTIME_DIR=/var/run/user/$uid
/bin/mkdir -p "\$XDG_RUNTIME_DIR"
/bin/chflags uunlink "\$XDG_RUNTIME_DIR"
/bin/chmod 700 "\$XDG_RUNTIME_DIR"
EOF
done
