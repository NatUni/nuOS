cat >> "$TRGT/boot/loader.conf.d/re.conf" <<EOF
if_re_load="YES"
if_re_name="/boot/modules/if_re.ko"
EOF
