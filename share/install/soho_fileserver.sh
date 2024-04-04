sister enable_svc -C "$TRGT" dbus netatalk

[ ! -f "$TRGT"/usr/local/etc/afp.conf ] || sed -Ee 's/^\+(afp interfaces)/+;\1/' "$NUOS"/share/examples/etc/afp.conf.diff | patch "$TRGT"/usr/local/etc/afp.conf
