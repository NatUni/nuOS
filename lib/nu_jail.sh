#!/usr/bin/false
set -e; set -u; set -C

# nuOS 0.0.12.99a0 - lib/nu_jail.sh
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
[ -n "${nuos_lib_common_loaded-}" ]
[ -z "${nuos_lib_jail_loaded-}" ]
nuos_lib_jail_loaded=y

jail_vars_init () {
	echo 'creating jail   -j JAIL_NAME      ' ${JAIL_NAME:=clink}
	JAIL_NAME_=`echo $JAIL_NAME | tr . _`
	echo 'jail type       -t JAIL_TYPE      ' ${JAIL_TYPE:=jail}
	echo 'jail opsys      -o JAIL_OS        ' ${JAIL_OS:=$HOSTOS_TYPE/$HOSTOS_VER/$HOSTOS_TRGT}
	echo 'pool name       -p POOL_NAME      ' ${POOL_NAME:=$POOL_BOOT_NAME}
	echo 'jail snapshot   -s JAIL_SNAP      ' ${JAIL_SNAP:=$PKG_COLLECTION}
	local hostname=${NEW_HOST:-${HOST:=`hostname`}}
	echo 'jail host name  -h JAIL_HOST      ' ${JAIL_HOST:=$JAIL_NAME.$hostname}
	echo 'jail dataset       JAIL_DATA      ' ${JAIL_DATA:=$POOL_NAME/jail/$JAIL_HOST}
	echo 'jail path          JAIL_PATH      ' ${JAIL_PATH:=/var/jail/$JAIL_NAME}
	
	case $JAIL_TYPE in
		jail|clone) : ${JAIL_NET:=127.1.0.0/16};;
		nat) : ${JAIL_NET:=172.16.0.1/16};;
		vnet) : ${JAIL_NET:=172.24.0.0/16};;
		vnet-nat) : ${JAIL_NET:=172.28.0.1/16};;
		public|vnet-public) ;;
		*) error 22 "JAIL_TYPE (-t) must be jail (default), nat, vnet, clone or public."
	esac
	case "${JAIL_IP-}" in
		'') JAIL_IP=`next_available_jail_ip`;;
		[xX].[xX].*) JAIL_IP=${JAIL_NET%.*.*}.${JAIL_IP#?.?.};;
	esac
	
	echo 'jail ip address -i JAIL_IP        ' ${JAIL_IP:=`next_available_jail_ip`}
	[ -n "$JAIL_IP" -a $JAIL_IP = ${JAIL_IP#E} ]
	echo -n 'shared src mnts -w OPT_RW_SRC      ' && [ -n "${OPT_RW_SRC-}" ] && echo set || echo null
}

last_used_jail_ip () {
	[ ${JAIL_NET##*/} -le 16 ] || error 78 "JAIL_NET must be of size B (end in /16) or less"
	local net=${JAIL_NET%.*.*} n=
	{ eko ${JAIL_NET%/*}; grep "^${net%.*}\\.${net#*.}\\." "${CHROOTDIR-}/etc/hosts"; } |\
		cut -w -f 1 | ip_to_int |\
		awk '$0 >= '${n:=`ip_to_int ${JAIL_NET%/*}`}' && $0 < '$n' + (2 ^ '${JAIL_NET##*/}') {print $0}' |\
		sort -n | int_to_ip |\
		awk -F . '$3 < 250 {print $0}' | tail -n 1
}

next_available_jail_ip () {
	local net=${JAIL_NET%.*.*} ip=${1:-`last_used_jail_ip`}
	int_to_ip $((`ip_to_int $ip` + 1))
}
