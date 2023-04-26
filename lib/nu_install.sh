#!/usr/bin/false
set -e; set -u; set -C

# nuOS 0.0.12.99a0 - lib/nu_install.sh
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
[ -n "${nuos_lib_make_loaded-}" ]
[ -n "${nuos_lib_ports_loaded-}" ]
[ -n "${nuos_lib_collection_loaded-}" ]
[ -z "${nuos_lib_install_loaded-}" ]
nuos_lib_install_loaded=y

build_vars_init () {
	: ${HOST:=`hostname`}
	echo 'pool name       -p POOL_NAME      ' ${POOL_NAME:=$POOL_BOOT_NAME}
	echo 'port db dir        PORT_DBDIR     ' $PORT_DBDIR
	echo 'make jobs          MAKE_JOBS      ' ${MAKE_JOBS:=$((2+`sysctl -n kern.smp.cpus`))}
	echo 'target arch        TRGT_ARCH      ' $TRGT_ARCH
	echo 'target proc        TRGT_PROC      ' $TRGT_PROC
	echo 'target kern        TRGT_KERN      ' ${TRGT_KERN:=NUOS}
	echo 'target optimize    TRGT_OPTZ      ' $TRGT_OPTZ
	echo 'git server         GIT_SERVER     ' ${GIT_SERVER=git.FreeBSD.org}
	echo 'git path           GIT_PATH       ' ${GIT_PATH:=src}
	echo 'git branch         GIT_BRANCH     ' ${GIT_BRANCH:=releng/13.2}
}

install_vars_init () {
	: ${HOST:=`hostname`}
	canhas ${1-} || echo 'pool name       -p POOL_NAME      ' ${POOL_NAME:=$POOL_BOOT_NAME}
	echo -n 'swap size       -s SWAP_SIZE       ' && [ -z "${OPT_BASE_OS-}" ] && echo ${SWAP_SIZE:=2G} || echo n/a
	echo 'new host name   -h NEW_HOST       ' ${NEW_HOST:=$POOL_NAME.${HOST#*.}}
	canhas ${1-} || echo 'target arch        TRGT_ARCH      ' $TRGT_ARCH
	canhas ${1-} || echo 'target proc        TRGT_PROC      ' $TRGT_PROC
	canhas ${1-} || echo 'target kern        TRGT_KERN      ' ${TRGT_KERN:=NUOS}
	echo -n 'copy src           COPY_SRC        ' && [ -n "${COPY_SRC-}" ] && echo set || echo null
	echo -n 'copy ports src     COPY_PORTS      ' && [ -n "${COPY_PORTS-}" ] && echo set || echo null
	echo -n 'copy git repos     COPY_GIT        ' && [ -n "${COPY_GIT-}" ] && ([ -n "${COPY_GIT-}" ] && echo set || echo null) || echo n/a
	echo -n 'copy all pkgs      COPY_DEV_PKGS   ' && [ -n "${COPY_DEV_PKGS-}" ] && echo set || echo null
}

require_git () {
	which git > /dev/null || sister nu_install_pkg devel/git
}

require_base_src () {
	local opt_nomake=
	if [ x${1-} = x-n ]; then
		opt_nomake=y; shift
	fi
	if [ ! -f /usr/src/Makefile ]; then
		require_git
		
		try 3 -p 5 git clone --branch "$GIT_BRANCH" https://$GIT_SERVER/$GIT_PATH.git /usr/src

		baseos_init
		reset_pkg_collection
	fi
	local make_conf= retire_make_conf_cmd= src_conf= retire_src_conf_cmd=
	if ! [ -d /usr/obj/usr/src/bin -o -d /usr/obj/usr/src/$TRGT_ARCH.$TRGT_PROC/bin ]; then
		prepare_make_conf make_conf retire_make_conf_cmd
		prepare_src_conf src_conf retire_src_conf_cmd
		[ $TRGT_OPTZ = `cd /var/empty && make -V CPUTYPE` ]
		srsly $opt_nomake || (cd /usr/src && make -j $MAKE_JOBS "__MAKE_CONF=$make_conf" "SRCCONF=$src_conf" buildworld)
		$retire_make_conf_cmd make_conf
		$retire_src_conf_cmd src_conf
	fi
	
	[ -f /usr/obj/usr/src/$TRGT_ARCH.$TRGT_PROC/toolchain-metadata.mk ] || old_build=y
	[ -f /usr/obj/usr/src/compiler-metadata.mk ] || new_build=y
	[ y = "${old_build-}${new_build-}" ]
	
	local kconf=/usr/src/sys/$TRGT_ARCH/conf/NUOS
	if [ $TRGT_KERN = NUOS ] && [ ! -e $kconf -o $kconf -ot "$NUOS_CODE/share/kern/NUOS" ]; then
		cp -p "$NUOS_CODE/share/kern/NUOS" $kconf
	fi
	
	local kobj=/usr/obj/usr/src${new_build:+/$TRGT_ARCH.$TRGT_PROC}/sys/$TRGT_KERN
	if [ ! -d $kobj -o $kobj -ot $kconf ]; then
		prepare_make_conf make_conf retire_make_conf_cmd
		prepare_src_conf src_conf retire_src_conf_cmd
		srsly $opt_nomake || (cd /usr/src && make -j $MAKE_JOBS "__MAKE_CONF=$make_conf" "SRCCONF=$src_conf" KERNCONF=$TRGT_KERN buildkernel)
		$retire_make_conf_cmd make_conf
		$retire_src_conf_cmd src_conf
	fi
}

freeze () {
	while getopts r OPT; do case $OPT in
		r) opt_remount=y;;
	esac; done; shift $(($OPTIND-1))
	local rds=$1 ds= mp= dmp= src= mode= uid= gid= flags=

	zfs list -H -r -t filesystem -o mountpoint,name $rds | sort | tail -r | while IFS=$'\t' read -r mp ds; do
		if canhas "${ALT_MNT-}"; then
			eval `stat -f "mode=%OMp%03OLp uid=%Du gid=%Dg flags=%Of" "$mp"`
		fi
		umount "$mp"
		ro=`zfs get -H -o value -s local,received org.nuos:origin_readonly $ds`
		if canhas "${ALT_MNT-}"; then
			src=`zfs get -H -o source mountpoint $ds`
			if [ local = "$src" -o received = "$src" ]; then
				dmp="${mp#$POOL_MNT}"
				: ${dmp:=/}
			else
				dmp=
			fi
		else
			dmp=
		fi
		zfs set canmount=noauto ${ro:+readonly=$ro} ${dmp:+mountpoint=$dmp} $ds
		if [ -n "${ALT_MNT-}" -a -z "$dmp" ]; then
			zfs inherit mountpoint $ds
			if [ ! -d "$mp" ]; then
				mkdir -p "$mp"
				chown $uid:$gid "$mp"
				chmod $mode "$mp"
				chflags $flags "$mp"
			fi
		fi
		if canhas $ro; then
			zfs inherit org.nuos:origin_readonly $ds
		fi
	done
	if srsly ${opt_remount-}; then
		zfs list -H -r -t filesystem -o mountpoint,name $rds | sort | while IFS=$'\t' read -r mp ds; do
			canhas ${ALT_MNT-} || mp="${mp#$POOL_MNT}"
			mount -t zfs $ds "$POOL_MNT/${mp%/}"
		done
	fi
}

find_next_monotonic () {
	local ds=$2 id=${3-} rev=0
	if canhas $id; then
		eko $ds/$id
	else
		while
			ret=$ds/v$rev
			zfs list $ret
		do
			rev=$(($rev + 1))
		done
		setvar $1 $ret
	fi
}
