#!/usr/bin/false
set -e; set -u; set -C

# nuOS 0.0.12.99a0 - lib/nu_make.sh
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
[ -n "${nuos_lib_system_loaded-}" ]
[ -n "${nuos_lib_common_loaded-}" ]
[ -z "${nuos_lib_make_loaded-}" ]
nuos_lib_make_loaded=y

make_vars_init () {
	: ${TRGT_ARCH:=$HOSTOS_ARCH}
	: ${TRGT_PROC:=$HOSTOS_PROC}
	case $TRGT_PROC in
		amd64)
			BASE_CHIP=x86-64
			: ${TRGT_CHIP:=$BASE_CHIP}
			: ${TRGT_OPTZ:=opteron-sse3}
		;;
		i386)
			BASE_CHIP=i686
			: ${TRGT_CHIP:=$BASE_CHIP}
			: ${TRGT_OPTZ:=pentium3}
		;;
		*)
			[ -n "${BASE_CHIP-}" -o -n "${TRGT_CHIP-}" ]
			: ${TRGT_CHIP:=$BASE_CHIP}
			: ${BASE_CHIP:=$TRGT_CHIP}
			: ${TRGT_OPTZ:=$TRGT_CHIP}
	esac
	if [ $TRGT_ARCH = $TRGT_PROC ]; then
		TRGT_MACH=$TRGT_ARCH
	else
		TRGT_MACH=$TRGT_ARCH.$TRGT_PROC
	fi
	if [ $TRGT_CHIP = $TRGT_OPTZ ]; then
		TRGT_CODE=$TRGT_CHIP
	else
		TRGT_CODE=$TRGT_OPTZ
	fi
	if [ $TRGT_CODE = $BASE_CHIP ]; then
		TRGT=$TRGT_MACH
	else
		TRGT=$TRGT_MACH.$TRGT_CODE
	fi
	: ${HOSTOS_TRGT:=$TRGT}
}

pkg_suffix_init () {
	if [ "x${1-}" = x-i ]; then
		_pkg_name=
		_pkg_cmp=
	fi
	: ${_pkg_name:=`pkg info -qO ports-mgmt/pkg < /dev/null 2> /dev/null || true`}
	local pkg_ver=${_pkg_name##*-}
	if canhas $pkg_ver; then
		case ${_pkg_cmp:=`pkg version -t 1.17.0 $pkg_ver < /dev/null 2> /dev/null || true`} in
			'>') PKG_SUFFIX=txz;;
			'=') ;&
			'<') PKG_SUFFIX=pkg;;
		esac
	fi
}

prepare_make_conf () {
	local opt_init=
	while getopts i OPT; do case $OPT in
		i) opt_init=y;;
	esac; done; shift $(($OPTIND-1))
	
	local ret_file_var=$1; shift
	local ret_cmd_var=$1; shift
	
	if [ -z "$opt_init" ] && [ -s "${CHROOTDIR-}/etc/make.conf" ]; then
		setvar $ret_file_var "${CHROOTDIR-}/etc/make.conf"
		setvar $ret_cmd_var :
	else
		make_vars_init
		local makeconf=
		require_tmp makeconf
		cat >| "$makeconf" <<EOF
CPUTYPE?=$TRGT_CODE
DEFAULT_VERSIONS= bdb=18 gcc=12 java=18 llvm=15 lua=5.4 mysql=8.0 nodejs=18 perl5=5.36 pgsql=15 php=8.2 python=3.11 python3=3.11 ruby=3.1 samba=4.16 ssl=openssl
EOF
		setvar $ret_file_var "$makeconf"
		setvar $ret_cmd_var retire_tmp
	fi
}

prepare_src_conf () {
	local opt_init=
	while getopts i OPT; do case $OPT in
		i) opt_init=y;;
	esac; done; shift $(($OPTIND-1))
	
	local ret_file_var=$1; shift
	local ret_cmd_var=$1; shift
	
	if [ -z "$opt_init" ] && [ -s "${CHROOTDIR-}/etc/src.conf" ]; then
		setvar $ret_file_var "${CHROOTDIR-}/etc/src.conf"
		setvar $ret_cmd_var :
	else
		make_vars_init
		local srcconf=
		require_tmp srcconf
		cat >| "$srcconf" <<EOF
WITH_EXTRA_TCP_STACKS=1
EOF
		setvar $ret_file_var "$srcconf"
		setvar $ret_cmd_var retire_tmp
	fi
}
