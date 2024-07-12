if [ -f "$NUOS_CODE/conf" ]; then
	warn you are not a developer to begin with
else
	for u in $ADMIN_ACCT $BD_ACCT; do
		[ -d "$TRGT/home/$u/$(basename "$NUOS_CODE")" ] || cp -av "$NUOS_CODE" "$TRGT/home/$u/"
	done
fi
