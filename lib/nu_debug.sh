#!/usr/bin/false
set -e; set -u; set -C

# nuOS 0.0.12.99a0 - lib/nu_debug.sh
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

nuos_lib_ver=0.0.12.99a0
[ $nuos_lib_ver = "$NUOS_VER" ]
[ -n "${nuos_lib_system_loaded-}" ]
nuos_lib_debug_loaded=y

debug_wrap () {
# WARNING from `man sh`:
#   Using aliases in scripts is discouraged because the command that defines them must be
#   executed before the code that uses them is parsed. This is fragile and not portable.
# NOTE:
#   The script parser will not activate the alias needed to make this feature work until
#   backing all the way out of any control flow keywords, to the "root" context of the file
#   calling this library function.

    test -n "$1"
    local cmd=$1 f=_nu_`jot -r -c -s '' 16 A Z`_wrapped
    shift
    if [ $# -gt 0 ]; then
		debug_wrap "$@"
	fi

	require_tmp -l debug_wraps -d _debug_wrap_logdir
	eko "# DEBUG: nuOS-debug_wrap - setup of $cmd" | tee -a "$_debug_wrap_logdir/$cmd.in" >> "$_debug_wrap_logdir/$cmd.out"

    eval "$f () {
		eko \"# DEBUG: nuOS-debug_wrap - call to $cmd\${*+ w/ \$# args}\" | tee -a \"$_debug_wrap_logdir/$cmd.in\" >> \"$_debug_wrap_logdir/$cmd.out\"
		if [ \$# -gt 0 ]; then
			local __dbw_i= __dbw_arg=
			while [ \"\${__dbw_i:=1}\" -le \$# ]; do
				eval \"__dbw_arg=\\\$\$__dbw_i\"
				spill -p \"# \$__dbw_i\" __dbw_arg >> \"$_debug_wrap_logdir/$cmd.in\"
				__dbw_i=\$((\$__dbw_i + 1))
			done
		fi
		tee -a \"$_debug_wrap_logdir/$cmd.in\" | \"$cmd\" \${*+\"\$@\"} | tee -a \"$_debug_wrap_logdir/$cmd.out\"
		eko \"# DEBUG: nuOS-debug_wrap - return from $cmd\" | tee -a \"$_debug_wrap_logdir/$cmd.in\" >> \"$_debug_wrap_logdir/$cmd.out\"
	}"
    alias $cmd=$f
}
