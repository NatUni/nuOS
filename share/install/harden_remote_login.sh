sed -i '' -E -e '/^#VersionAddendum\>/a\
ChallengeResponseAuthentication no\
PasswordAuthentication no\
AuthenticationMethods publickey,publickey,publickey
' "$TRGT/usr/local/etc/ssh/sshd_config"

mv "$TRGT/usr/local/etc/ssh/moduli" "$TRGT/usr/local/etc/ssh/moduli.sample"
awk '($1 == "#" || $5 > 4000)' "$TRGT/usr/local/etc/ssh/moduli.sample" > "$TRGT/usr/local/etc/ssh/moduli"
