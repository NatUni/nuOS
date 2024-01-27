sister nu_ns_cache -C "$TRGT" -s
cp -anv /usr/local/etc/unbound/root.key "$TRGT/usr/local/etc/unbound/" \
	|| warn "couldn't find the current DNS root.key to bootstrap DNSSEC for the new system"
		# NOTE: Also, if the TRGT system already had a root key put into it for some reason, this
		# warning could be displayed and it would therefore be a misleading error message indeed
		# in that strange case.
