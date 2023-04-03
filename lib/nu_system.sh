#!/usr/bin/false
set -e; set -u; set -C

# nuOS 0.0.12.99a0 - lib/nu_system.sh
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
[ -z "${nuos_lib_system_loaded-}" ]
[ -z "${nuos_lib_common_loaded-}" ]
nuos_lib_system_loaded=y
nuos_lib_common_loaded=y

: ${TMPDIR:=/tmp}
: ${NUOS_CODE:="$(dirname "$(realpath "$0")")/.."}

load_lib () {
	local lib=
	for lib in "$@"; do
		. "$NUOS_CODE/lib/$lib.sh"
		push NUOS_LOADED_LIBS $lib
	done
}

baseos_init () {
	if [ -r /usr/src/sys/conf/newvers.sh ]; then
		local TYPE REVISION BRANCH
		eval `grep -E '^(TYPE|REVISION|BRANCH)=' /usr/src/sys/conf/newvers.sh`
		BASEOS_TYPE=$TYPE
		BASEOS_VER=$REVISION-$BRANCH
	else
		BASEOS_TYPE=`uname -s`
		BASEOS_VER=`uname -r`
	fi
	if [ -q != "${1-}" ]; then
		echo 'base opsys                        ' $BASEOS_TYPE
		echo 'base opsys v#                     ' $BASEOS_VER
	fi
}

maybe_pause () {
	local secs="${1-}"
	if [ -z "${OPT_QUICK-}" ]; then
		echo
		echo beginning in ${secs:=10} seconds
		echo
		sleep $secs
		echo
	fi
}

maybe_yell () {
	if [ -n "${OPT_VERBOSE-}" ]; then
		set -v; set -x
		trap 'set >| /tmp/`basename "$0"`.$$.set' EXIT
	fi
}

srsly () {
	case "${1-}" in
		y) return 0;;
		'') return 1;;
		*) echo ERROR: confusing boolean "($*)"; exit 88;;
	esac
}

canhas () {
	if [ -n "${1-}" ]; then
		return 0
	else
		return 1
	fi
}

first () {
	case "$2" in
		of)
			if [ "$1" = "${3%% *}" ]; then
				return 0
			else
				return 1
			fi
		;;
		*) exit 88;;
	esac
}

incr () {
	local var=$1; shift
	if eval [ -z "\"\${$var-}\"" ]; then
		setvar $var $1
	elif eval [ \$$var -ge ${2-9223372036854775806} ]; then
		return 1
	else
		eval setvar $var "\$((1+\$$var))"
	fi
}

push () {
	local _push_var=$1 _push_old_val= _push_prepend= _push_new_val=; shift
	unset _push_new_val
	eval _push_old_val=\"\${$_push_var-}\"
	if canhas "$*"; then
		_push_prepend="${_push_old_val:+$_push_old_val }"
		_push_new_val="$_push_prepend$*"
	fi
	setvar $_push_var "${_push_new_val-$_push_old_val}"
}

push_set () {
	local _push_set_var=$1 _push_set_val=; shift
	for _push_set_val in $*; do
		if ! { eval eko \"\${$_push_set_var-}\" | grep -q -w "$_push_set_val"; }; then
			push $_push_set_var "$_push_set_val"
		fi
	done
}

eko () {
	printf '%s\n' "$*"
}

re_pattern () {
	local multiple= naked= whole=;
	while getopts mn OPT; do case $OPT in
		m) multiple=y;;
		n) naked=y;;
	esac; done; shift $(($OPTIND-1))
	srsly ${naked-} || whole=y
	local var=$1; shift
	if srsly ${multiple-}; then
		setvar ${var}_re `{
			srsly ${naked-} || printf %s ^
			while [ $# -gt 0 ]; do
				printf %s "$1"
				shift
				[ $# -gt 0 ] && printf '\0'
			done | sed -e 's/\./\\\./g' | tr '\0' '|'
			srsly ${naked-} || printf %s '$'
			eko
		}`
	else
		setvar ${var}_re "${whole:+^}`eval eko \\"\\$$var\\" | sed -e 's/\./\\\./g'`${whole:+\$}"
	fi
}

humanize () {
	if [ -n "$1" -a 0 -lt "$1" ]; then
		if [ "$((($1 / 1125899906842624) * 1125899906842624))" = "$1" ]; then
			eko "$(($1 / 1125899906842624)) PB"
		elif [ "$((($1 / 1099511627776) * 1099511627776))" = "$1" ]; then
			eko "$(($1 / 1099511627776)) TB"
		elif [ "$((($1 / 1073741824) * 1073741824))" = "$1" ]; then
			eko "$(($1 / 1073741824)) GB"
		elif [ "$((($1 / 1048576) * 1048576))" = "$1" ]; then
			eko "$(($1 / 1048576)) MB"
		elif [ "$((($1 / 1024) * 1024))" = "$1" ]; then
			eko "$(($1 / 1024)) KB"
		else
			eko "$1 B"
		fi
	else
		eko '0 B'
	fi
}

dehumanize () {
	[ -n "$1" ]
	local n=`eko $1 | tr -dc [[:digit:]].` u=`eko $1 | tr -d '[[:digit:]].,Bb '`
	case $u in
		[Pp]) eko "$(($n * 1125899906842624))";;
		[Tt]) eko "$(($n * 1099511627776))";;
		[Gg]) eko "$(($n * 1073741824))";;
		[Mm]) eko "$(($n * 1048576))";;
		[Kk]) eko "$(($n * 1024))";;
		'') eko "$n";;
		*) error 22 "invalid argument \"$1\""
	esac
}

error () {
	local ex=$1; shift
	printf '%s\n' "ERROR: $*" | tr -dc [[:graph:]][[:space:]] 2>&1
	exit $ex
}

warn () {
	printf '%s\n' "WARNING: $*" | tr -dc [[:graph:]][[:space:]] 2>&1
}

strlen () {
	# returns chars according to locale, not bytes
	while [ $# -gt 0 ]; do
		printf %s "$1" | wc -m | xargs
		shift
	done
}

spill () {
	if [ x-e = "x${1-}" ]; then
		local __nuOS_lib_system_spill_explicit_unset=y
		shift
	else
		local __nuOS_lib_system_spill_explicit_unset=
	fi
	while [ $# -gt 0 ]; do
		case "${1-}" in
			-p)
				shift
				local __nuOS_lib_system_spill_printed_variable_name=$1
				shift
			;;
			*) local __nuOS_lib_system_spill_printed_variable_name=$1;;
		esac
		local __nuOS_lib_system_spill_read_variable_name=$1 __nuOS_lib_system_spill_variable_value=
		shift
		if eval [ -z \"\${$__nuOS_lib_system_spill_read_variable_name-}\" -a -n \"\${$__nuOS_lib_system_spill_read_variable_name-x}\" ]; then
			if srsly $__nuOS_lib_system_spill_explicit_unset; then
				echo unset $__nuOS_lib_system_spill_printed_variable_name
			fi
			continue
		fi
		eval setvar __nuOS_lib_system_spill_variable_value \"\$$__nuOS_lib_system_spill_read_variable_name\"
		echo -n "$__nuOS_lib_system_spill_printed_variable_name="
		printf %s "$__nuOS_lib_system_spill_variable_value" | case y in
			`printf %s "$__nuOS_lib_system_spill_variable_value" | grep -q \' && echo y`)
					echo -n \"
					sed -e 's/\\/\\\\/g;s/`/\\`/g;s/"/\\"/g;s/\$/\\&/g'
					echo \"
			;;
			`printf %s "$__nuOS_lib_system_spill_variable_value" | awk 'NR==2{print "$";exit}{print $0}' | grep -qE '[^[:alnum:]./_@%^+=:-]' && echo y`)
					echo -n \'
					cat
					echo \'
			;;
			*)
					cat
					echo
			;;
		esac
	done
}

mnt_dev () {
	if [ -c "${1-}/dev/null" ]; then
		return 1
	else
		mount -t devfs devfs "${1-}/dev"
		devfs -m "${1-}/dev" ruleset 1
		devfs -m "${1-}/dev" rule applyset
		devfs -m "${1-}/dev" rule -s 2 applyset
	fi
}

get_host_ent () {
	local chrootdir= opt_one= opt_ip4= opt_ip6= opt_full= fcmd= icmd= ocmd=
	while getopts C:146f OPT; do case $OPT in
		1) opt_one=y;;
		4) opt_ip4=y;;
		6) opt_ip6=y;;
		C) chrootdir=$OPTARG;;
		f) opt_full=y;;
	esac; done; shift $(($OPTIND-1))
	
	fcmd () {
		if srsly ${opt_full-}; then
			cat
		else
			cut -wf1
		fi
	}
	icmd () {
		if srsly ${opt_ip4-}; then
			awk '$1 ~ /\./ {print $1}'
		elif srsly ${opt_ip6-}; then
			grep :
		else
			cat
		fi
	}
	ocmd () {
		if srsly ${opt_one-}; then
			head -n 1
		else
			cat
		fi
	}
	
	grep -v '^#' "${chrootdir-}/etc/hosts" | grep -q -E "[[:blank:]]$1([[:blank:]]|\$)" && \
		grep -v '^#' "${chrootdir-}/etc/hosts" | grep -E "[[:blank:]]$1([[:blank:]]|\$)" |\
		icmd | fcmd | ocmd
}

sister () {
	local chrootdir= jailname=; unset chrootdir jailname
	while getopts C:j: OPT; do case $OPT in
		C) chrootdir=$OPTARG;;
		j) jailname=$OPTARG;;
	esac; done; shift $(($OPTIND-1))
	local bin=$1; shift
	
	if [ -n "${jailname-}" ]; then
		chrootdir="`jls -j $jailname path`"
		[ -n "$chrootdir" ] || { echo "could not find running jail thusly named." >&2 && return 85; }
	fi
	
	if [ -n "${chrootdir-}" ]; then
		local nuos_src
		require_tmp -c -C "$chrootdir" -d nuos_src
		mount -t nullfs -r "$(dirname "$(realpath "$0")")/.." "$nuos_src"
		local devfs_mounted=
		if mnt_dev "$chrootdir"; then
			devfs_mounted=y
		fi
		if [ -n "${jailname-}" ]; then
			jexec -l "$jailname" sh "${nuos_src#"$chrootdir"}/bin/$bin" "$@"
		else
			chroot "$chrootdir" sh "${nuos_src#"$chrootdir"}/bin/$bin" "$@"
		fi
		if [ -n "$devfs_mounted" ]; then
			umount "$chrootdir/dev"
		fi
		umount "$nuos_src"
		retire_tmp nuos_src
	else
		sh "$NUOS_CODE/bin/$bin" "$@"
	fi
}

require_tmp () {
	local opt_chroot= chrootdir= opt_dir= label=; unset chrootdir label
	while getopts cC:dl: OPT; do case $OPT in
		c) opt_chroot=y;;
		C) chrootdir=$OPTARG;;
		d) opt_dir=y;;
		l) label=$OPTARG;;
	esac; done; shift $(($OPTIND-1))
	
	[ $# = 1 ]
	[ -n "$1" ]
	
	: ${label=$1}
	: ${TMPDIR:=/tmp}
	
	if eval [ -n \"\${$1-}\" ]; then
		eval [ -w \"\$$1\" ]
	else
		setvar "$1" "$(env TMPDIR="${opt_chroot:+${chrootdir-$CHROOTDIR}}$TMPDIR" mktemp ${opt_dir:+-d} -t "$(basename "$0").$$${label:+.$label}")"
	fi
}

retire_tmp () {
	local opt_keep=
	while getopts k OPT; do case $OPT in
		k) opt_keep=y;;
	esac; done; shift $(($OPTIND-1))
	
	[ $# = 1 ]
	[ -n "$1" ]
	
	if [ -z "$opt_keep" ]; then
		if [ -n "${OPT_DEBUG-}" ]; then
			require_tmp -d -l debug_out _retire_tmp_debug_out
			if eval [ -e \"\$_retire_tmp_debug_out\/\$1\" ]; then
				eval mv -n \"\$_retire_tmp_debug_out\/\$1\" \"\$_retire_tmp_debug_out\/0.\$1\"
			fi
			local i; unset i
			while eval [ -e \"\$_retire_tmp_debug_out\/${i:-0}.\$1\" ]; do
				: ${i:=0}
				i=$(($i+1))
			done
			eval mv -n \"\$$1\" \"\$_retire_tmp_debug_out\/${i:+$i.}\$1\"
		else
			eval rm -r \"\$$1\"
		fi
	fi
	eval unset "$1"
}

underscore () {
	if [ $# -eq 0 ]; then
		sed -e s+/+_+
	else
		while [ $# -gt 0 ]; do
			if eval [ "\${$1}" = "\${$1%%/*}" ]
				then eval setvar ${1}_ "\${$1}"
				else eval setvar ${1}_ "\${$1%%/*}_\${$1#*/}"
			fi
			shift
		done
	fi
}

sets_union () {
	local ret_var=$1; shift
	
	[ $# -ge 1 ]
	
	local ret_tmp=
	require_tmp -l $ret_var ret_tmp
	
	cat "$@" | sort -u >| "$ret_tmp"
	setvar $ret_var "$ret_tmp"
}

sets_sym_diff () {
	local ret_var=$1; shift
	
	[ $# = 2 ]
	
	local ret_tmp=
	require_tmp -l $ret_var ret_tmp
	
	cat "$@" | sort | uniq -u >| "$ret_tmp"
	setvar $ret_var "$ret_tmp"
}

sets_intrsctn () {
	local ret_var=$1; shift
	
	[ $# -ge 2 ]
	
	local ret_tmp=
	require_tmp -l $ret_var ret_tmp
	
	case $# in
		2)
			cat "$@" | sort | uniq -d >| "$ret_tmp"
			;;
		*)
			cat "$@" | sort | uniq -c | sed -nEe "/^[[:blank:]]*$# /{s///;p;}" >| "$ret_tmp"
	esac
	setvar $ret_var "$ret_tmp"
}

rev_zone () {
	echo $1 | awk -F . 'OFS="."{print $4,$3,$2,$1,"in-addr.arpa"}'
}

try () {
	local pause=1 tries=$1; shift
	if [ x-p = "x$1" ]; then
		pause=$2; shift 2
	fi
	for n in `seq 1 $tries`; do
		if "$@"; then
			return
		else
			sleep $pause
		fi
	done
	return 1
}

next_ip () {
	echo "${1%.*}.$((${1##*.}+1))"
}

save_git_info () {
	local code_dir= opt_rev= r=
	if [ x-r = "x${1-}" ]; then
		opt_rev=y; shift
	fi
	code_dir="${1:-`realpath .`}"
	if ! [ "$code_dir/.git/info.txt" -nt "$code_dir/.git/FETCH_HEAD" ]; then
		which git > /dev/null
		cat >| "$code_dir/.git/info.txt" <<EOF
Commit: `git -C "$code_dir" rev-parse HEAD`
Last Changed Date: `git -C "$code_dir" show -s --format=%ci HEAD`
EOF
	fi
	if srsly ${opt_rev-}; then
		r=`grep ^Commit: "$code_dir/.git/info.txt" | cut -w -f 2 | head -c 12`
		: ${r:=0}
		echo g$r
	fi
}


nuos_init () {
	: ${NUOS_CODE:="$(dirname "$(realpath "$0")")/.."}
	if [ -d /etc/nuos ]; then
		CONF_DIR=/etc/nuos
	fi
	for conf_file in /usr/nuos/conf /etc/nuos.conf ${CONF_DIR:+$CONF_DIR/conf}; do
		if [ -r "$conf_file" ]; then
			. "$conf_file"
		fi
		if [ -r "${CHROOTDIR-}$conf_file" ]; then
			. "${CHROOTDIR-}$conf_file"
		fi
	done
	
	: ${NUOS_SUPPORTED:=UNSUPPORTED}
	: ${HOSTOS_TYPE:=$BASEOS_TYPE}
	: ${HOSTOS_VER:=$BASEOS_VER}
	: ${HOSTOS_ARCH:=`uname -m`}
	: ${HOSTOS_PROC:=`uname -p`}
	if [ $HOSTOS_ARCH = $HOSTOS_PROC ]; then
		HOSTOS_MACH=$HOSTOS_ARCH
	else
		HOSTOS_MACH=$HOSTOS_ARCH.$HOSTOS_PROC
	fi

	PKG_DBLOC=/var/db/nuos/pkg
	: ${PKG_DBDIR=$PKG_DBLOC}
	
	if [ -q != "${1-}" ]; then
		echo 'nuos app v#                       ' $NUOS_VER
		echo 'nuos support       NUOS_SUPPORTED ' "$NUOS_SUPPORTED"
		echo 'host opsys                        ' "$HOSTOS_TYPE"
		echo 'host opsys v#                     ' $HOSTOS_VER
		echo "host pkg collec'n                 " ${HOSTOS_PKG_COLLECTION-<n/a>}
		echo "host pkg db dir                   " ${PKG_DBDIR-<none>}
	fi
}

set_pool_root_mnt_vars () {
	if canhas "${ALT_MNT-}"; then
		POOL_MNT="$ALT_MNT"
	else
		POOL_MNT=`zpool get -H -o value altroot $1`
		[ -n "$POOL_MNT" ]
		if [ x- = "x$POOL_MNT" ]; then
			require_tmp -d ALT_MNT
			POOL_MNT="$ALT_MNT"
			export ALT_MNT 
		else
			ALT_MNT=
		fi
	fi
}

nuos_ssl_init () {
	if [ -x /usr/local/bin/openssl ]; then
		SSL_CMD=/usr/local/bin/openssl
		SSL_SUITE=openssl-port
		SSL_CONF=/usr/local/openssl/openssl.cnf
		[ -e $SSL_CONF ] || cp $SSL_CONF.sample $SSL_CONF
	else
		SSL_CMD=/usr/bin/openssl
		SSL_SUITE=openssl-freebsd-base
		SSL_CONF=/etc/ssl/openssl.cnf
	fi
	: ${HOST:=`hostname`}
	: ${ACME_PROVIDER:=letsencrypt.org}
	: ${ACME_SERVER:=letsencrypt}
	if [ ${HOST%%.*} != "`readlink /etc/ssl/certs.installed/localhost`" ]; then
		mkdir -p /etc/ssl/certs.installed/${HOST%%.*}
		ln -sf ${HOST%%.*} /etc/ssl/certs.installed/localhost
	fi
}

nuos_ssh_init () {
	if [ -x /usr/local/bin/ssh ]; then
		SSH_CMD=/usr/local/bin/ssh
		SSH_SUITE=openssh-port
	else
		SSH_CMD=/usr/bin/ssh
		SSH_SUITE=openssh-freebsd-base
	fi
}

nuos_sha_fngr () {
	local makeconf= make_conf= bytes=24
	while getopts b:fm: OPT; do case $OPT in
		b) bytes=$OPTARG; [ $bytes -ge 1 -a $bytes -le 43 ];;
		f) opt_force=y;;
		m) makeconf=$OPTARG;;
	esac; done; shift $(($OPTIND-1))
	[ $# -ge 1 ]
	[ $bytes -le 42 -o -n "${opt_force-}" ]

	if canhas $makeconf; then
		[ -r "$makeconf" ]
		require_tmp make_conf
		grep -vE '^CPUTYPE\>' "$makeconf" >| "$make_conf"
	fi
	
	cat ${makeconf:+"$make_conf"} "$@" 2>/dev/null |
		sha256 -q |
		(echo 16i; echo -n FF; tr a-f A-F; echo P) | dc | tail -c +2 |
		b64encode - |
		sed -nEe "
			/^begin-base64 /{
				n
				s/=?=\$//
				y|+/|-_|
				s/^(.{$bytes}).*\$/\1/
				p
				q
			}"

	canhas $makeconf && retire_tmp make_conf
}

ns_master_zone () {
	local opt_chroot= alternate= chrootdir= zone= host_name=; unset alternate chrootdir
	while getopts A:cC:j: OPT; do case $OPT in
		A) alternate=$OPTARG;;
		c) opt_chroot=y;;
		C) chrootdir=$OPTARG;;
		j) jailname=$OPTARG;;
	esac; done; shift $(($OPTIND-1))
	[ $# -eq 1 ]
	host_name=$1; shift
	zone=$host_name
	
	if [ -n "${jailname-}" ]; then
		chrootdir="`jls -j $jailname path`"
		opt_chroot=y
		[ -n "$chrootdir" ] || { echo "could not find running jail thusly named." >&2 && return 85; }
	fi
	
	while [ ! -f "${opt_chroot:+${chrootdir-$CHROOTDIR}}/var/db/knot${alternate:+_${alternate}}/$zone.zone" ]; do
		echo $zone | grep -q '\.' || { echo "could not find zone file (are we the configured master of a parent zone?)" >&2 && return 85; }
		zone=${zone#*.}
	done
	echo $zone
}

set_primary_phys_netif () {
	local primary_if=$1
	local trgt=${2-}
	sed -i '' -E -e '/^ifconfig_.+_name="?net0"?/d' "$trgt/etc/rc.conf.local"
	cat >> "$trgt/etc/rc.conf.local" <<EOF
ifconfig_${primary_if}_name="net0"
EOF
}

strip_csv_header () {
	tail -n +2
}

lower_case () {
	case $# in
		0) tr '[[:upper:]]' '[[:lower:]]';;
		1) eko "$1" | lower_case;;
		*)
			for v in $@; do
				[ "x$v" != x-s ] || continue
				setvar ${v}_lc "`eval lower_case '"$'$v'"'`"
			done
		;;
	esac
}

ip_to_int () {
	local a= b= c= d= v=
	case $# in
		0)
			while IFS=. read -r a b c d; do
				eko $(( ($a * 16777216) + ($b * 65536) + ($c * 256) + $d ))
			done
		;;
		*)
			for v in $@; do
				eko $v | ip_to_int
			done
		;;
	esac
}

int_to_ip () {
	local a= b= c= d= n= o= v= x=
	case $# in
		0)
			while read -r n; do
				for o in d c b a; do
					x=$(( $n % 256 ))
					setvar $o $x
					n=$(( ($n - $x) / 256 ))
				done
				eko $a.$b.$c.$d
			done
		;;
		*)
			for v in $@; do
				eko $v | int_to_ip
			done
		;;
	esac
}
