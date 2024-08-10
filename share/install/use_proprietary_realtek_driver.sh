cat >> "$TRGT/boot/loader.conf.d/if_re.conf" <<EOF
if_re_load="YES"
if_re_name="/boot/modules/if_re.ko"
EOF
