NUOS_VER=0.0.12.99a0
. /usr/nuos/lib/nu_system.sh
nuos_init

set_infras -v
read_set_ips -v

enable_svc jail

if [ ! -d /var/jail/resolv ]; then
	nu_jail -j resolv -S domain -T a.ns -T b.ns -x -q
	nu_ns_cache -C /var/jail/resolv -s
	{ grep -w -v nameserver /var/jail/resolv/etc/resolv.conf; getent hosts resolv.jail | cut -w -f 1 | xargs -n 1 echo nameserver; } > /etc/resolv.conf
	cp -av /var/jail/resolv/etc/resolvconf.conf /etc/resolvconf.conf
	push start_jails resolv
fi

if [ ! -d /var/jail/ns -a ! -d /var/jail/a.ns -a ! -d /var/jail/b.ns ]; then
	nu_jail -j ns -S domain -x -q
	env ALIAS_IP=$my_ip_1 nu_jail -j a.ns -AP -S domain -x -q
	env ALIAS_IP=$my_ip_2 nu_jail -j b.ns -AP -S domain -x -q
	nu_ns_server -C /var/jail/ns -d -k 4096 -z 2048 -i $my_ip_1 -i $my_ip_2 -s a.ns.jail -s b.ns.jail
	nu_ns_server -C /var/jail/a.ns -i $my_ip_1 -i $my_ip_2 -m ns.jail
	nu_ns_server -C /var/jail/b.ns -i $my_ip_1 -i $my_ip_2 -m ns.jail
	if [ -d /root/nuos_deliverance/ns ]; then
		tar -cf - -C /root/nuos_deliverance/ns/knotdb keys | tar -xvf - -C /var/jail/ns/var/db/knot
	fi
	push start_jails ns a.ns b.ns
fi

canhas ${start_jails-} || service jail start $start_jails; start_jails=

for inf in $INFRA_HOST $guest_infras; do set_infra_metadata -q $inf
	for z in $zones_lc; do
		[ ! -f /var/jail/ns/var/db/knot/$z.zone ] || continue
		for j in ns a.ns b.ns; do
			nu_ns_host -j $j -h $z
		done
		nu_sshfp -j ns -F -h $z
	done
done

for inf in $INFRA_HOST $guest_infras; do set_infra_metadata -q $inf
	eko
	for z in $zones_lc; do
		nu_ns_host -j ns -h $z -k
	done
done

report_expired_domains

echo
echo Sleeping three minutes to allow canonical DNS authority to be established
sleep 180 &
p=$!
echo "(kill -STOP $p; kill -CONT $p) to pause and resume"
wait $p

for s in lb vpn ca; do
	if [ -d /root/nuos_deliverance/$s ]; then
		tar -cf - -C /root/nuos_deliverance/$s/ssl . | tar --keep-newer-files -xvf - -C /etc/ssl
	fi
done

for inf in $INFRA_HOST $guest_infras; do set_infra_metadata $inf
	
	if [ ! -f /etc/ssl/private/ca.$INFRA_DOMAIN_lc.key ] || [ ! -f /etc/ssl/certs/ca.$INFRA_DOMAIN_lc.internal.crt ]; then
		nu_ssl -h ca.$INFRA_DOMAIN_lc -b 4096 -s -W -d 512 -n $country -p "$province" -l "$locality" -o "$organization" -u "$sec_dept" -S
	fi
	if [ ! -f /etc/ssl/private/$INFRA_DOMAIN_lc.key ] || [ ! -f /etc/ssl/csrs/$INFRA_DOMAIN_lc.csr ]; then
		nu_ssl -h $INFRA_DOMAIN_lc -b 4096 -n $country -p "$province" -l "$locality" -o "$organization" -u "$net_dept" -S
	fi
	if [ ! -f /etc/ssl/certs/$INFRA_DOMAIN_lc.internal.crt ]; then
		nu_ca -h $INFRA_DOMAIN_lc
	fi
	
	if [ ! -f /etc/ssl/csrs.next/$INFRA_DOMAIN_lc.csr ]; then
		nu_ssl -h $INFRA_DOMAIN_lc -b 4096 -n $country -p "$province" -l "$locality" -o "$organization" -u "$net_dept" -S -N
	fi
	nu_acme_renew -j ns $INFRA_DOMAIN_lc
	host -rt tlsa _443._tcp.$INFRA_DOMAIN_lc ns.jail | grep -w 'has TLSA record' || nu_ssl -j ns -F -h $INFRA_DOMAIN_lc -tt
done

if [ ! -d /usr/local/etc/openvpn ]; then
	nu_vpn -q -h $INFRA_HOST_lc
	service openvpn start
fi


if [ ! -d /var/jail/postmaster ]; then
	nu_jail -j postmaster -P -S smtp -I submission -x -q
	(cd /etc/ssl && tar -cf - certs/$INFRA_HOST_lc.ca.crt certs/$INFRA_HOST_lc.crt csrs.next/$INFRA_HOST_lc.csr csrs/$INFRA_HOST_lc.csr private/$INFRA_HOST_lc.key | tar -xvf - -C /var/jail/postmaster/etc/ssl/)
	mkdir -p /var/jail/postmaster/var/imap/socket
	service jail start postmaster
	nu_smtp -j postmaster -s -e -h $INFRA_HOST_lc
	for inf in $INFRA_HOST $guest_infras; do set_infra_metadata -qq $inf
		nu_user -C /var/jail/postmaster -h $INFRA_DOMAIN_lc -a -d net -u $OWNER_ACCT -n "$OWNER_NAME" < /root/owner_pass`[ ! -f /root/owner_pass.$OWNER_ACCT ] || echo .$OWNER_ACCT`}
	done
fi

if [ ! -d /var/jail/postoffice ]; then
	nu_jail -j postoffice -m -P -I imap -I imaps -I pop3 -I pop3s -I sieve -x -q
	(cd /etc/ssl && tar -cf - certs/$INFRA_HOST_lc.ca.crt certs/$INFRA_HOST_lc.crt csrs.next/$INFRA_HOST_lc.csr csrs/$INFRA_HOST_lc.csr private/$INFRA_HOST_lc.key | tar -xvf - -C /var/jail/postoffice/etc/ssl/)
	service jail start postoffice
	nu_imap -j postoffice -s -e -h $INFRA_HOST_lc
	while read -r proto procs; do
		prgm="${prgm-}${prgm:+ }/#?[[:blank:]]$proto\\>/s/\\<(prefork)=[[:digit:]]+/\1=$procs/;"
	done <<'EOF'
imap 8
imaps 2
lmtp(unix)? 1
EOF
	sed -i '' -E -e "/^SERVICES {/,/^}/{$prgm}" /var/jail/postoffice/usr/local/etc/cyrus.conf
	echo /var/jail/postoffice/var/imap/socket /var/jail/postmaster/var/imap/socket nullfs ro >| /etc/fstab.postoffice
	if [ -d /root/nuos_deliverance/po ]; then
		tar -cf - -C /root/nuos_deliverance/po . | tar -xvf - -C /var/jail/postoffice/var
	fi
	for inf in $INFRA_HOST $guest_infras; do set_infra_metadata -qq $inf
		nu_user -C /var/jail/postoffice -h $INFRA_DOMAIN_lc -a -u $OWNER_ACCT -n "$OWNER_NAME" < /root/owner_pass`[ ! -f /root/owner_pass.$OWNER_ACCT ] || echo .$OWNER_ACCT`}
	done
	service jail restart postmaster postoffice
fi

for inf in $INFRA_HOST $guest_infras; do set_infra_metadata -qq $inf
	for z in $zones_lc; do
		grep -w ^$z /var/jail/postmaster/usr/local/etc/postfix/domains || nu_smtp_host -C /var/jail/postmaster -h $z
		for b in operator security hostmaster postmaster webmaster whois-data; do
			grep -w ^$b@$z /var/jail/postmaster/usr/local/etc/postfix/virtual || nu_user_mail -C /var/jail/postmaster -h $INFRA_DOMAIN_lc -u $OWNER_ACCT -m $b@$z
		done
	done
	for m in $init_emails; do
		grep -w ^${m#'*'} /var/jail/postmaster/usr/local/etc/postfix/virtual || nu_user_mail -C /var/jail/postmaster -h $INFRA_DOMAIN_lc -u $OWNER_ACCT -m $m
	done
done

for inf in $INFRA_HOST $guest_infras; do set_infra_metadata $inf
	for z in $zones_lc; do
		department=`get_domains | match_names $z | extract_dept`
		canhas $department || continue
	
		if [ ! -f /etc/ssl/private/$z.key ] || [ ! -f /etc/ssl/csrs/$z.csr ]; then
			nu_ssl -h $z -b 4096 -n $country -p "$province" -l "$locality" -o "$organization" -u "$department" -S
		fi
		if [ ! -f /etc/ssl/csrs.next/$z.csr ]; then
			nu_ssl -N -h $z -b 4096 -n $country -p "$province" -l "$locality" -o "$organization" -u "$department" -S
		fi
		nu_acme_renew -j ns $z
		host -rt tlsa _443._tcp.$z ns.jail | grep -w 'has TLSA record' || nu_ssl -j ns -F -h $z -tt
	done
done

ADMIN_USER=`pw usershow -u 1001 | cut -d : -f 1`
if [ ! -d /var/jail/www ]; then
	nu_jail -j www -m -P -I http -I https -x ${ADMIN_USER:+-u $ADMIN_USER} -q
	nu_http -C /var/jail/www -s -IIII
fi
for z in $all_zones_lc; do
	[ -f /var/jail/www/etc/ssl/certs/$z.crt -a ! /etc/ssl/certs/$z.crt -nt /var/jail/www/etc/ssl/certs/$z.crt ] || (cd /etc/ssl && tar -cf - certs/$z.ca.crt certs/$z.crt csrs.next/$z.csr csrs/$z.csr private/$z.key | tar -xvf - -C /var/jail/www/etc/ssl/)
	http_host_extra_flags=`get_domains | match_names $z | extract_flags`
	[ -f /var/jail/www/usr/local/etc/apache*/Includes/$z.conf ] || nu_http_host -C /var/jail/www -a -kkf -G -P -i $http_host_extra_flags -u ${ADMIN_USER:-root} -h $z

	if [ ccsys.com = $z ] && [ ! -f /var/jail/www/home/$ADMIN_USER/$z/www/public/index.html ]; then
		sed -i '' -e "/\\<Content-Security-Policy\\>/s:object-src 'none':plugin-types application/pdf:" /var/jail/www/usr/local/etc/apache*/Includes/$z.conf
		${ADMIN_USER:+env -i} chroot ${ADMIN_USER:+-u 1001 -g 1001} /var/jail/www /bin/sh <<EOF
d=\`mktemp -d\`
cd \$d
`which pdftex` /usr/nuos/share/examples/tex/cv.tex
mv cv.pdf /home/$ADMIN_USER/$z/www/public/resume.pdf
rm -rv \$d
EOF
		${ADMIN_USER:+env -i} chroot ${ADMIN_USER:+-u 1001 -g 1001} /var/jail/www /bin/sh -c "cat > /home/$ADMIN_USER/$z/www/public/index.css" <<'EOF'
html {
	background: LightSteelBlue;
	color: DimGray;
	font-size: 0;
}
body {
	font-family: Helvetica, Verdana, Arial, sans-serif;
	font-size: 12pt;
	line-height: 1.125;
	margin: 1em;
}
a {
	color: SteelBlue;
}
h1, h2, h3, h4, h5, h6 {
	font-weight: bold;
}
h1 {
	font-size: 2em;
	margin: 0.67em 0;
}
h2 {
	font-size: 1.5em;
	margin: 0.83em 0;
}
h3 {
	font-size: 1.17em;
	margin: 1em 0;
}
h4 {
	font-size: 1em;
	margin: 1.33em 0;
}
h5 {
	font-size: 0.83em;
	margin: 1.67em 0;
}
h6 {
	font-size: 0.67em;
	margin: 2.33em 0;
}
p {
	margin: 1em 0;
}
address {
	font-style: italic;
}
EOF
		${ADMIN_USER:+env -i} chroot ${ADMIN_USER:+-u 1001 -g 1001} /var/jail/www /bin/sh -c "cat > /home/$ADMIN_USER/$z/www/public/index.html" <<'EOF'
<!DOCTYPE HTML>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<link href="index.css" rel="stylesheet" type="text/css" />
<title>CCSys.com</title>
</head>
<body>
<h1>CCSys.com</h1>
<h2>Crop Circle Systems</h2>
<h3><a href="resume.pdf">Chad Jacob Milios, CEO</a></h3>
<p><address>
	1256 Glendora Rd.<br/>
	Kissimmee, Florida 34759
</address></p>
<p>
	<a href="tel:+16143973917">(614) 397-3917</a><br/>
</p>
</body>
EOF
	fi

	case $INFRA_DOMAIN_lc in
		cargobay.net) link=lobby/;;
		woneye.site) link=https://UglyBagsOfMostlyWater.club/;;
		macleod.host) link=home/;;
		*) link=https://$INFRA_DOMAIN/
	esac
	i=1; for Z in $org_zones; do
		z=`lower_case $Z`
		[ ! -f /var/jail/www/usr/local/etc/apache*/Includes/VirtualHost.custom/$z.conf ] || continue
		${ADMIN_USER:+env -i} chroot ${ADMIN_USER:+-u 1001 -g 1001} /var/jail/www `which nu_http_host_snowtube` -h $Z -l $link -S "`echo $org_zones | xargs -n 1 | sed -E -e 's|^(.*)$|https://\1/|'`" -s $i -g >> `echo /var/jail/www/usr/local/etc/apache*/Includes/VirtualHost.custom`/$z.conf
	i=$(($i+1)); done

	admin_home=${ADMIN_USER:+home/$ADMIN_USER}
	: ${admin_home:=root}
	for z in $prod_zones_lc; do
		z=`lower_case $Z`
		[ -z "`find /var/jail/www/$admin_home/$z/www/public -type f | head -n 1`" ] || continue
		if [ -d /root/nuos_deliverance/www/$z ]; then
			tar -cf - -C /root/nuos_deliverance/www/$z . | tar -xvf - -C /var/jail/www/$admin_home/$z/www
		fi
		if [ -f /root/nuos_deliverance/www/$z.conf ]; then
			cp -v /root/nuos_deliverance/www/$z.conf /var/jail/www/usr/local/etc/apache*/Includes/VirtualHost.custom/
		fi
	done

	for z in $zones_lc; do
		if [ -f /root/nuos_deliverance/www/$z.fstab ]; then
			awk "\$2 !~ \"^/var/jail/www/home/[^/]*/$z/www(\$|/)\"" /etc/fstab.www > /etc/fstab.www.$$
			cat /root/nuos_deliverance/www/$z.fstab >> /etc/fstab.www.$$
			mv /etc/fstab.www.$$ /etc/fstab.www
		fi
	done

mount -F /etc/fstab.www -a
service jail restart www


# nu_pgsql -n -s -h $INFRA_HOST_lc
# nu_ftp -s -h $INFRA_HOST_lc
