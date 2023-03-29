sister enable_svc -C "$TRGT" seatd dbus hald sddm
if canhas $ADMIN_ACCT; then
	pw -R "$TRGT" groupmod video -m $ADMIN_ACCT
fi
if canhas $USER_ACCT; then
	pw -R "$TRGT" groupmod video -m $USER_ACCT
fi
