case $NAME in
	neo|matrix)
		my_ip=209.133.193.154
		netmask=0xfffffff8
		defaultrouter=209.133.193.153
		primary_if=ix0
	;;
	*) error 6 "No network configuration found for $NAME"
esac

if canhas ${primary_if-}; then
	set_primary_phys_netif $primary_if "$TRGT"
fi

sed -i '' -e '/^#/d;/^$/d' "$TRGT/etc/rc.conf.local"
sed -i '' -e "/^ifconfig_net0=/s/\<up\>/inet $my_ip netmask $netmask/" "$TRGT/etc/rc.conf.local"

cat >> "$TRGT/etc/rc.conf.local" <<EOF
defaultrouter="$defaultrouter"
EOF

case $NAME in
	neo|matrix)
		cat >> "$TRGT/etc/rc.conf.local" <<EOF
ifconfig_net0_alias0="inet `next_ip $my_ip` netmask 0xffffffff"
EOF
	;;
esac
