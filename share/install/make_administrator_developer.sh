for u in $ADMIN_ACCT $BD_ACCT; do
	cp -av "$NUOS_CODE" "$TRGT/home/$u/nuOS"
done
