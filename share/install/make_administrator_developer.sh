for u in $ADMIN_ACCT $BD_ACCT; do
	[ -d "$TRGT/home/$u/nuOS" ] || cp -av "$NUOS_CODE" "$TRGT/home/$u/nuOS"
done
