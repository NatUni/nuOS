NUOS_VER=0.0.12.99a0
. ${NUOS_CODE:=/usr/nuos}/lib/nu_system.sh
nuos_init
load_lib nu_genesis

set_infras -v
read_set_ips -v

enable_svc jail

init_jail resolv ns
service jail start resolv ns

for inf in $INFRA_HOST $guest_infras; do set_infra_metadata -qv $inf
	[ ! -f /var/jail/ns/var/db/knot/$INFRA_DOMAIN_lc.zone ] || continue
	for j in `list_ns_jails`; do
		nu_ns_host -j $j -h $INFRA_DOMAIN_lc
	done
	nu_sshfp -j ns -F -h $INFRA_DOMAIN_lc
done
for inf in $INFRA_HOST $guest_infras; do set_infra_metadata -q $inf
	for z in $client_zones_lc; do
		[ ! -f /var/jail/ns/var/db/knot/$z.zone ] || continue
		for j in `list_ns_jails`; do
			nu_ns_host -j $j -h $z
		done
	done
done

for inf in $INFRA_HOST $guest_infras; do set_infra_metadata -q $inf
	eko
	for z in $zones_lc; do
		nu_ns_host -j ns -h $z -k
	done
done

report_expired_domains

if ! srsly ${GENESIS_SKIP_WAIT-}; then
	echo
	echo Sleeping five minutes to allow canonical DNS authority to be established
	sleep 300 &
	p=$!
	echo "(kill -STOP $p; kill -CONT $p) to pause and resume"
	wait $p
fi

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
	nu_jail -x -q -t vnet -S $my_ip_1:smtp -S $my_ip_2:smtp -S $my_ip_1:submission -S $my_ip_2:submission -j postmaster
	(cd /etc/ssl && tar -cf - certs/$INFRA_HOST_lc.ca.crt certs/$INFRA_HOST_lc.crt csrs.next/$INFRA_HOST_lc.csr csrs/$INFRA_HOST_lc.csr private/$INFRA_HOST_lc.key | tar -xvf - -C /var/jail/postmaster/etc/ssl/)
	mkdir -p /var/jail/postmaster/var/imap/socket
	sysrc -f /etc/rc.conf.d/jail jail_list+=postmaster
	service jail start postmaster
	nu_smtp -j postmaster -s -e -h $INFRA_HOST_lc
	for inf in $INFRA_HOST $guest_infras; do set_infra_metadata -qq $inf
		nu_user -C /var/jail/postmaster -h $INFRA_HOST_lc -a -d net -u $OWNER_ACCT -n "$OWNER_NAME" < /root/owner_pass`[ ! -f /root/owner_pass.$OWNER_ACCT ] || echo .$OWNER_ACCT`
	done
fi

if [ ! -d /var/jail/postoffice ]; then
	nu_jail -x -q -t vnet -m -S $my_ip_1:imaps -S $my_ip_2:imaps -j postoffice
	(cd /etc/ssl && tar -cf - certs/$INFRA_HOST_lc.ca.crt certs/$INFRA_HOST_lc.crt csrs.next/$INFRA_HOST_lc.csr csrs/$INFRA_HOST_lc.csr private/$INFRA_HOST_lc.key | tar -xvf - -C /var/jail/postoffice/etc/ssl/)
	sysrc -f /etc/rc.conf.d/jail jail_list+=postoffice
	service jail start postoffice
	nu_imap -j postoffice -s -e -h $INFRA_HOST_lc
	while read -r proto procs; do
		prgm="${prgm-}${prgm:+ }/#?[[:blank:]]$proto\\>/s/\\<(prefork)=[[:digit:]]+/\1=$procs/;"
	done <<'EOF'
imap 8
imaps 2
lmtp(unix)? 1
EOF
	sed -i '' -E -e "/^SERVICES /,/^}/{$prgm}" /var/jail/postoffice/usr/local/etc/cyrus.conf
	echo /var/jail/postoffice/var/imap/socket /var/jail/postmaster/var/imap/socket nullfs ro >| /etc/fstab.postoffice
	if [ -d /root/nuos_deliverance/po ]; then
		tar -cf - -C /root/nuos_deliverance/po . | tar -xvf - -C /var/jail/postoffice/var
	fi
	for inf in $INFRA_HOST $guest_infras; do set_infra_metadata -qq $inf
		nu_user -C /var/jail/postoffice -h $INFRA_HOST_lc -a -u $OWNER_ACCT -n "$OWNER_NAME" < /root/owner_pass`[ ! -f /root/owner_pass.$OWNER_ACCT ] || echo .$OWNER_ACCT`
	done
	service jail restart postmaster postoffice
fi

for inf in $INFRA_HOST $guest_infras; do set_infra_metadata $inf
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
	nu_jail -t vnet -m -S $my_ip_1:http -S $my_ip_2:http -S $my_ip_1:https -S $my_ip_2:https -j www -x ${ADMIN_USER:+-u $ADMIN_USER} -q
	nu_http -C /var/jail/www -s -IIII
	echo /var/jail/postmaster/var/spool/postfix/maildrop /var/jail/www/var/spool/postfix/maildrop nullfs rw >| /etc/fstab.www
	sysrc -f /etc/rc.conf.d/jail jail_list+=www
fi
for inf in $INFRA_HOST $guest_infras; do set_infra_metadata -q $inf
	for z in $zones_lc; do
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
	done
	
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
			awk "\$2 !~ \"^/var/jail/www/home/[^/]*/$z/www(\$|/)\"" /etc/fstab.www > /etc/fstab.www.tmp_$$
			cat /root/nuos_deliverance/www/$z.fstab >> /etc/fstab.www.tmp_$$
			mount -F /root/nuos_deliverance/www/$z.fstab -a
			mv /etc/fstab.www.tmp_$$ /etc/fstab.www
		fi
	done
done

service jail restart www

# nu_pgsql -n -s -h $INFRA_HOST_lc
# nu_ftp -s -h $INFRA_HOST_lc
