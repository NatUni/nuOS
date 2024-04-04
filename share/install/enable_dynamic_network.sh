sister enable_svc -C "$TRGT" dhcpcd

cat >> "$TRGT"/usr/local/etc/dhcpcd.conf <<'EOF'

# Ignore management and VPN interfaces
denyinterfaces mgmt[0-9]* fw[0-9]* vpn[0-9]* tap[0-9]* tun[0-9]* ng[0-9]* epair[0-9]*[ab]
EOF
