mv "$TRGT/etc/newsyslog.conf" "$TRGT/etc/newsyslog.conf.sample"
awk '
	($1 ~ "^/") {
		n=NF
		if ($n ~ "^[0-9]+$" || $n ~ "^SIG") n--
		if ($n ~ "^/") n--
		$(n-3) *= 2
		if ($(n-2) ~ "^[0-9]+$") $(n-2) *= 100
	}
	{ print $0 }
	' "$TRGT/etc/newsyslog.conf.sample" > "$TRGT/etc/newsyslog.conf"

cat >> "$TRGT/etc/rc.conf.local" <<EOF
gateway_enable="YES"
firewall_nat_enable="YES"
EOF

. $NUOS/share/install/keep_time.sh
. $NUOS/share/install/harden_remote_login.sh
. $NUOS/share/install/allow_remote_login.sh
. $NUOS/share/examples/install/enable_static_cargobay_network.sh

case $NAME in
	willy|mama|hub|neo|matrix)
		cp -v "$NUOS/share/examples/install/cargobay_genesis.sh" "$TRGT/root/"
		echo 'nuos_firstboot_script="/root/cargobay_genesis.sh"' > "$TRGT/etc/rc.conf.d/nuos_firstboot"
	;;
esac

cp -v "$NUOS/share/examples/etc/nuos/"* "$TRGT/etc/nuos/"

sister enable_svc -C "$TRGT" nuos_firstboot
touch "$TRGT/firstboot"
