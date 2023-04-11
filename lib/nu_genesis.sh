#!/usr/bin/false
set -e; set -u; set -C

# nuOS 0.0.12.99a0 - lib/nu_genesis.sh
#
# Copyright (c) 2008-2022 Chad Jacob Milios and Crop Circle Systems.
# All rights reserved.
#
# This Source Code Form is subject to the terms of the Simplified BSD License.
# If a copy of the Simplified BSD License was not distributed alongside this file, you can
# obtain one at https://www.freebsd.org/copyright/freebsd-license.html . This software
# project is not affiliated with the FreeBSD Project.
#
# Official updates and community support available at https://nuos.org .
# Professional services available at https://ccsys.com .

nuos_lib_ver=0.0.12.99a0
[ $nuos_lib_ver = "$NUOS_VER" ]
[ -z "${nuos_lib_genesis_loaded-}" ]
nuos_lib_genesis_loaded=y

require_domain_metadata () {
	[ -r ${ZONE_DIR:=$CONF_DIR}/domain.csv ] || error 6 'no servicable domains, check configuration'
}

get_domains () {
	require_domain_metadata
	local col= exp= dom= rest=
	: ${_today:=`env TZ=UTC date -v +1d +%Y%m%d`}
	col=`xsv headers ${ZONE_DIR:=$CONF_DIR}/domain.csv | grep ' Expires$' | cut -wf1`
	xsv search -i -s Enabled '^y$' ${ZONE_DIR:=$CONF_DIR}/domain.csv | xsv select $col,1-$(($col - 1)),$(($col+1))- | while IFS=, read -r exp dom rest; do
		if [ "x$exp" = 'xExpires' ] || [ $exp -gt $_today ]; then
			eko "$exp,$dom,$rest"
		elif [ ! -f /tmp/expired_domains.$$ ]; then
			eko $exp $dom >> /tmp/expired_domains.$$.tmp
		fi
	done
	[ ! -f /tmp/expired_domains.$$.tmp ] || mv /tmp/expired_domains.$$.tmp /tmp/expired_domains.$$
}

report_expired_domains () {
	if [ -f /tmp/expired_domains.$$ ]; then
		local line=
		sort -u /tmp/expired_domains.$$ | while read -r line; do
			warn expired "$line"
		done
		rm /tmp/expired_domains.$$
	fi
}

get_emails () {
	[ -r ${ZONE_DIR:=$CONF_DIR}/email.csv ] || error 6 'no email information, check configuration'
	tr @ , < ${ZONE_DIR:=$CONF_DIR}/email.csv
}

infra_name () {
	require_domain_metadata
	local domain= domain_re= name=
	if canhas "${1-}"; then
		domain=$1
	else
		domain=`hostname -d`
	fi
	re_pattern domain
	name=`xsv search -i -s Name "$domain_re" ${ZONE_DIR:=$CONF_DIR}/domain.csv | xsv select Infrastructure | strip_csv_header`
	canhas $name && echo $name || echo $domain
}

require_infra_metadata () {
	[ -r ${ZONE_DIR:=$CONF_DIR}/infrastructure.csv ] || error 6 'no infrastructure metadata found, check configuration'
}

list_ns_jails () {
	sysrc -f /etc/rc.conf.d/jail -n jail_list | xargs -n1 | grep -w 'ns$'
}

infra () {
	require_infra_metadata
	local infra= infra_re=
	infra=`infra_name ${1-}`
	re_pattern infra
	xsv search -i -s Name "$infra_re" ${ZONE_DIR:=$CONF_DIR}/infrastructure.csv
}

infra_host_name () {
	local metal=
	metal=`infra ${1-} | xsv select Host | strip_csv_header`
	case "$metal" in
		'') ;&
		[Nn][Uu][Ll][Ll]) ;&
		[Ss][Ee][Ll][Ff]) ;&
		[Dd][Ee][Ff][Aa][Uu][Ll][Tt])
			infra_name ${1-}
		;;
		*)
			eko $metal
		;;
	esac
}

extract_name () {
	xsv select Name | strip_csv_header | xargs
}

extract_country () {
	xsv select Country | strip_csv_header
}

extract_state () {
	xsv select Province | strip_csv_header
}

extract_city () {
	xsv select Locality | strip_csv_header
}

extract_org () {
	xsv select Organization | strip_csv_header
}

extract_dept () {
	xsv select Department | strip_csv_header
}

extract_flags () {
	xsv select Flags | strip_csv_header
}

extract_sec_dept () {
	xsv select 'Security Department' | strip_csv_header
}

extract_own_acct () {
	xsv select 'Owner Account' | strip_csv_header
}

extract_own_name () {
	xsv select 'Owner Name' | strip_csv_header
}

match_infra () {
	local infra= infra_re=
	infra=`infra_name ${1-}`
	re_pattern infra
	xsv search -i -s Infrastructure "$infra_re"
}

match_func () {
	local func=$1 func_re=
	re_pattern -n func
	xsv search -i -s Function "^$func_re"
}

match_names () {
	local names_re=
	re_pattern -m names $@
	xsv search -i -s Name "$names_re"
}

match_hosts () {
	local zones_re=
	re_pattern -m zones $@
	xsv search -i -s Host "$zones_re"
}

extract_email () {
	xsv select Box,Host | strip_csv_header | tr , @ | xargs
}

get_all_infras () {
	require_infra_metadata
	local metal= metal_re=
	metal=`infra_host_name ${1-}`
	re_pattern metal
	xsv search -i -s Name,Host "$metal_re" ${ZONE_DIR:=$CONF_DIR}/infrastructure.csv
}

get_guest_infras () {
	local infra= infra_re=
	infra=`infra_name ${1-}`
	re_pattern infra
	get_all_infras ${1-} | xsv search -v -i -s Name "$infra_re"
}

set_infras () {
	# NOTE: Sets these variables in caller context:
	# INFRA_HOST, guest_infras
	
	local opt_verbose=
	while getopts v OPT; do case $OPT in
		v) opt_verbose=y;;
	esac; done; shift $(($OPTIND-1))
	
	INFRA_HOST=`infra_host_name ${1-}`
	
	! srsly ${opt_verbose-} || spill INFRA_HOST
	
	guest_infras=`get_guest_infras $INFRA_HOST | extract_name`
	
	! srsly ${opt_verbose-} || spill guest_infras
	
	lower_case INFRA_HOST guest_infras
}

read_set_ips () {
	# NOTE: Sets these variables in caller context:
	# my_ip_<n>, my_ip6_<n>
	
	local opt_verbose= i=
	while getopts v OPT; do case $OPT in
		v) opt_verbose=y;;
	esac; done; shift $(($OPTIND-1))
	
	while IFS=: read i ip; do
		setvar my_ip_$i $ip
		! srsly ${opt_verbose-} || spill my_ip_$i
	done <<EOF
`ifconfig net0 | grep -E '^[[:blank:]]*inet ' | xargs -L 1 | cut -w -f 2 | grep -n .`
EOF

	while IFS=: read i ip; do
		setvar my_ip6_$i $ip
		! srsly ${opt_verbose-} || spill my_ip6_$i
	done <<EOF
`ifconfig net0 | grep -E '^[[:blank:]]*inet6 ' | xargs -L 1 | cut -w -f 2 | grep -n .`
EOF
}

set_infra_metadata () {
	# NOTE:
	#
	# [Re]sets these variables in caller context:
	# INFRA_DOMAIN
	# OWNER_ACCT, OWNER_NAME,
	# country, province, locality, organization, sec_dept, net_dept,
	# corp_zones, org_zones, prod_zones,
	# client_zones, zones, init_emails
	#
	# Appends to these variables in caller context:
	# all_client_zones, all_zones
	#
	# Along with <varname>_lc (lower case) variants.
	
	local opt_quick= opt_really_quick= opt_verbose=
	while getopts qv OPT; do case $OPT in
		q) [ -n "${opt_quick-}" ] && opt_really_quick=y || opt_quick=y;;
		v) opt_verbose=y;;
	esac; done; shift $(($OPTIND-1))
	
	INFRA_DOMAIN=`infra_name ${1-}`
	OWNER_ACCT=`infra ${1-} | extract_own_acct`
	OWNER_NAME=`infra ${1-} | extract_own_name`
	! srsly ${opt_verbose-} || spill INFRA_DOMAIN OWNER_ACCT OWNER_NAME
	
	lower_case -s INFRA_DOMAIN
	
	if srsly ${opt_really_quick-}; then
		unset corp_zones org_zones prod_zones client_zones zones
	else
		client_zones=
		zones=$INFRA_DOMAIN
		for func in corp org prod; do
			setvar ${func}_zones "`get_domains | match_infra ${1-} | match_func $func | extract_name`"
			! srsly ${opt_verbose-} || spill ${func}_zones
			eval push client_zones \$${func}_zones
			eval push zones \$${func}_zones
		done
		push_set all_client_zones $client_zones
		push_set all_zones $zones
		lower_case corp_zones org_zones prod_zones client_zones zones all_client_zones all_zones
	fi

	if srsly ${opt_quick-}; then
		unset country province locality organization sec_dept net_dept init_emails
	else
		country=`infra ${1-} | extract_country`
		province=`infra ${1-} | extract_state`
		locality=`infra ${1-} | extract_city`
		organization=`infra ${1-} | extract_org`
		sec_dept=`infra ${1-} | extract_sec_dept`
		net_dept=`get_domains | match_names $INFRA_DOMAIN | extract_dept`
		init_emails=`get_emails | match_hosts $zones | extract_email`
		! srsly ${opt_verbose-} || spill country province locality organization sec_dept net_dept init_emails
	fi
	! srsly ${opt_verbose-} || eko
}

init_jail () {
	for j in $@; do
		case "$j" in
			resolv)
				if [ ! -d /var/jail/resolv ]; then
					nu_jail -q -x -t vnet -H domain -T =::domain -j resolv
					nu_ns_cache -C /var/jail/resolv -l all -s
					{ grep -w -v nameserver /var/jail/resolv/etc/resolv.conf; getent hosts resolv.jail | cut -w -f 1 | xargs -n 1 echo nameserver; } > /etc/resolv.conf
					cp -av /var/jail/resolv/etc/resolvconf.conf /etc/resolvconf.conf
					sysrc -f /etc/rc.conf.d/jail jail_list+=resolv
				fi
			;;
			ns)
# 				if [ ! -d /var/jail/ns -a ! -d /var/jail/a.ns -a ! -d /var/jail/b.ns ]; then
# 					nu_jail -x -q -t vnet -H domain -S $my_ip_1:domain -j a.ns
# 					nu_jail -x -q -t vnet -H domain -S $my_ip_2:domain -j b.ns
# 					nu_jail -x -q -t vnet -H domain -T =:a.ns.jail:domain -T =:b.ns.jail:domain -j ns
# 					nu_ns_server -C /var/jail/ns -l all -d -k 4096 -z 2048 -i $my_ip_1 -i $my_ip_2 -s a.ns.jail -s b.ns.jail
# 					nu_ns_server -C /var/jail/a.ns -l all -i $my_ip_1 -i $my_ip_2 -m ns.jail
# 					nu_ns_server -C /var/jail/b.ns -l all -i $my_ip_1 -i $my_ip_2 -m ns.jail
# 					if [ -d /root/nuos_deliverance/ns ]; then
# 						tar -cf - -C /root/nuos_deliverance/ns/knotdb keys | tar -xvf - -C /var/jail/ns/var/db/knot
# 					fi
# 					sysrc -f /etc/rc.conf.d/jail jail_list+="ns a.ns b.ns"
# 				fi
				if [ ! -d /var/jail/ns ]; then
					nu_jail -x -q -t vnet -H domain -S $my_ip_1:domain -S $my_ip_2:domain -j ns
					nu_ns_server -C /var/jail/ns -l all -d -k 4096 -z 2048 -i $my_ip_1 -i $my_ip_2
					if [ -d /root/nuos_deliverance/ns ]; then
						tar -cf - -C /root/nuos_deliverance/ns/knotdb keys | tar -xvf - -C /var/jail/ns/var/db/knot
					fi
					ns_jails=ns
					sysrc -f /etc/rc.conf.d/jail jail_list+=ns
				fi
			;;
		esac
	done
}
