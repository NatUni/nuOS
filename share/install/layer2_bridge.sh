if canhas ${L2_bridge} && ! canhas ${L2_BRIDGES}; then
	L2_bridge255=$L2_bridge
fi

for b in ${L2_BRIDGES-255}; do
	b=bridge${b#bridge}
	case $b in
		bridge[0-9]) :;&
		bridge[1-9][0-9]) :;&
		bridge[12][0-9][0-9])
			eval mbrs=\"\$L2_$b\"
			l2_conf=
			for m in $mbrs; do
				push l2_conf addm $m stp $m
			done
			cat >> "$TRGT/etc/rc.conf.local" <<EOF

cloned_interfaces="\$cloned_interfaces $b"
ifconfig_$b="$l2_conf up"
EOF
			for m in $mbrs; do
				cat >> "$TRGT/etc/rc.conf.local" <<EOF
: \${ifconfig_$m=up}
EOF
			done
		;;
		*) error 22 Bad entry in L2_BRIDGES
	esac
done
