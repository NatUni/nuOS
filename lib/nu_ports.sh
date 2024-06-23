#!/usr/bin/false
set -e; set -u; set -C

# nuOS 0.0.12.999a0 - lib/nu_ports.sh
#
# Copyright (c) 2008-2024 Chad Jacob Milios and Crop Circle Systems.
# All rights reserved.
#
# This Source Code Form is subject to the terms of the Simplified BSD License.
# If a copy of the Simplified BSD License was not distributed alongside this file, you can
# obtain one at https://www.freebsd.org/copyright/freebsd-license.html . This software
# project is not affiliated with the FreeBSD Project.
#
# Official updates and community support available at https://nuos.org .
# Professional services available at https://ccsys.com .

nuos_lib_ver=0.0.12.999a0
[ $nuos_lib_ver = "$NUOS_VER" ]
[ -n "${nuos_lib_system_loaded-}" ]
[ -n "${nuos_lib_make_loaded-}" ]
[ -z "${nuos_lib_ports_loaded-}" ]
nuos_lib_ports_loaded=y

if [ -n "${PORT_DBDIR-}" ]; then
	_nuos_ports_dbdir_user_override=y
	exit 45
else
	PORT_DBDIR="$(realpath "$(dirname "$(realpath "$0")")/../port_opts")"
fi


ports_tag () {
	if [ -d /usr/ports/.git ]; then
		save_git_info -r /usr/ports
	else
		cut -d '|' -f 2 /var/db/portsnap/tag
	fi
}

pkg_db_tag () {
	if [ -d "${CHROOTDIR-}$NU_PKG_DBDIR" -a ! -L "${CHROOTDIR-}$NU_PKG_DBDIR" -a -f "${CHROOTDIR-}$NU_PKG_DBDIR/tag" ]; then
		cat "${CHROOTDIR-}$NU_PKG_DBDIR/tag"
	else
		ports_tag
	fi
}

port_idx () {
	local make_conf=$1 db=$2 port=$3 port_= env= ma=
	underscore port
	: ${_port_building_metainfo_dir:="$(dirname "$(realpath "$0")")/../pkg"}
	env="$_port_building_metainfo_dir/${port_%%@*}.env"
	ma="$_port_building_metainfo_dir/${port_%%@*}.makeargs"
	nuos_sha_fngr -b 16 -m "$make_conf" "$env" "$ma" "$db/$port_/settings" "$db/$port_/dependencies/all"
}

require_portsnap_files () {
	if [ ! -d /var/db/portsnap/files ]; then
		portsnap fetch
	fi
}

require_ports_tree () {
	local opt_must_already_exist=
	while getopts e OPT; do case $OPT in
		e) opt_must_already_exist=y;;
	esac; done; shift $(($OPTIND-1))

	if [ ! -f /usr/ports/Mk/bsd.port.mk ]; then
		[ -z "$opt_must_already_exist" ]
		require_portsnap_files
		portsnap extract
	fi
	if [ ! -d /usr/ports/packages ]; then
		mkdir /usr/ports/packages
	fi
	if [ ! -d /usr/ports/packages/All ]; then
		mkdir /usr/ports/packages/All 2> /dev/null || true
	fi
	local pkg_meta="$(dirname "$(realpath "$0")")/../pkg"
	local port_shars="`cd "$pkg_meta" && ls *.shar 2> /dev/null`"
	for port_shar in $port_shars; do
		local shar_ver= port=`echo $port_shar | sed -e 's|_|/|;s/\.shar$//'`
		if [ $port != ${port%.REPLACE_v*} ]; then
			shar_ver="${port##*.REPLACE_v}"
			port="${port%.REPLACE_v$shar_ver}"
			if [ "`cat /usr/ports/$port/.nuOS_shar_ver 2> /dev/null`" != $shar_ver ]; then
				mv -nhv /usr/ports/$port /usr/ports/$port.$$.bak 2> /dev/null || true
				# TODO: fix race condition here
				# XXX: only reach here through nu_pkg_tree or nu_update, not nu_install_pkg
			fi
		fi
		if [ ! -e /usr/ports/$port ]; then
			local category=${port%/*}
			(cd /usr/ports/$category && sh "$pkg_meta"/$port_shar)
			if [ -n "$shar_ver" ]; then
				echo $shar_ver > /usr/ports/$port/.nuOS_shar_ver
				rm -rv /usr/ports/$port.$$.bak 2> /dev/null || true
			fi
		fi
	done
	local port_diff= port_diffs=
	port_diffs="`cd "$pkg_meta" && ls *.1.diff 2> /dev/null || true`"
	for port_diff in $port_diffs; do
		local i= port_= port= targ=
		port_=${port_diff%.1.diff}
		port=`echo $port_ | sed -e 's|_|/|'`
		if (cd /usr/ports/$port && . "$pkg_meta"/$port_.diff.test); then
			if [ -f /usr/ports/$port/.nuOS_diff_test ]; then
				echo "WARNING: patch for $port seems to have been applied yet still passes need-to-apply test." >&2
				sleep 15
			fi
			i=1
			while [ -f "$pkg_meta"/$port_.$i.diff ]; do
				targ=`head -n 2 "$pkg_meta"/$port_.$i.diff | tail -n 1 | cut -w -f 2`
				patch -s -C -F 0 -E -t -N -d /usr/ports/$port -i "$pkg_meta"/$port_.$i.diff $targ || { echo "ERORR: patch for $port failed." >&2 && exit 1; }
				patch -F 0 -E -t -N -V none -d /usr/ports/$port -i "$pkg_meta"/$port_.$i.diff $targ
				i=$(($i+1))
			done
			sha256 -q "$pkg_meta"/$port_.diff.test >| /usr/ports/$port/.nuOS_diff_test
		elif [ ! -f /usr/ports/$port/.nuOS_diff_test ]; then
			echo "WARNING: patch for $port does not pass its need-to-apply test but does not seem to have been applied." >&2
			sleep 15
		fi
	done
}

pkg_name () {
	local port_= metainfo_dir= makeargs= opt_db= opt_installed= output=
	while getopts di OPT; do case $OPT in
		d) opt_db=y;;
		i) opt_installed=y;;
	esac; done; shift $(($OPTIND-1))

	local port=$1; shift

	[ $# = 0 ]

	port_=`echo $port | tr / _`
	if [ -n "$opt_db" ]; then
		cat "${CHROOTDIR-}$NU_PKG_DBDIR/$port_/name"
	elif [ -n "$opt_installed" ]; then
		exit 78
		output=`${CHROOTDIR:+chroot "$CHROOTDIR"} pkg info -qO ${port%%@*}`
		case $port in
			*@*)
				for pkg in $output; do
					if [ ${port##*@} = "`pkg info -qA $pkg | sed -nEe '/^flavor[[:blank:]]*:[[:blank:]]*/{s///;p;}'`" ]; then
						echo $pkg
					fi
				done
			;;
			*)
				if [ -n "$output" ]; then
					echo $output
				fi
			;;
		esac
	else
		local make_conf= retire_make_conf_cmd= flavor=
		prepare_make_conf make_conf retire_make_conf_cmd
		case $port in
			*@*)
				flavor=${port##*@}
			;;
		esac
		metainfo_dir="$(dirname "$(realpath "$0")")/../pkg"
		makeargs="$metainfo_dir/$port_.makeargs"
		cd /usr/ports/${port%%@*}
		make __MAKE_CONF="$make_conf" PORT_DBDIR="$PORT_DBDIR" ${flavor:+FLAVOR=$flavor} `cat "$makeargs" 2>/dev/null` -v PKGNAME
		cd "$OLDPWD"
		$retire_make_conf_cmd make_conf
	fi
}

pkg_orgn () {
	local opt_installed=
	while getopts i OPT; do case $OPT in
		i) opt_installed=y;;
	esac; done; shift $(($OPTIND-1))

	local pkg=$1; shift

	[ $# = 0 ]

	if [ -n "$opt_installed" ]; then
		exit 78
		${CHROOTDIR:+chroot "$CHROOTDIR"} pkg_info -qo $pkg
	else
		(cd /usr/ports && make search name=$pkg | sed -nEe "/^Port:[[:blank:]]*$pkg\$/{N;s|^.*\nPath:[[:blank:]]*/usr/ports/(.*)\$|\1|;p;}")
	fi
}

pkg_deps () {
	local opt_installed= opt_missing= opt_ports=
	while getopts imp OPT; do case $OPT in
		i) opt_installed=y;;
		m) opt_missing=y;;
		p) opt_ports=y;;
	esac; done; shift $(($OPTIND-1))

	local ret_var=$1; shift
	local pkg=$1; shift

	[ $# = 0 ]
	local ret_tmp=
	require_tmp -l $ret_var ret_tmp

	exit 78

	setvar $ret_var "$ret_tmp"
}
