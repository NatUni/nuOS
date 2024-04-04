sister enable_svc -C "$TRGT" dbus avahi_daemon
cp -nv "$NUOS"/share/examples/etc/dhcpcd.exit-hook "$TRGT"/usr/local/etc/
