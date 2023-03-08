: ${serial_console_com_port:=1}
: ${serial_console_speed:=115200}

case $serial_console_com_port in
	1)
		# _com_port=0x3F8 # (FYI)
	;;
	2)
		_not_default_com_port=y
		_com_port=0x2F8
	;;
esac

tee -a "$TRGT/boot/loader.conf.local" <<EOF
boot_multicons="YES"
boot_serial="YES"
${_not_default_com_port:+comconsole_port="$_com_port"
}comconsole_speed="$serial_console_speed"
console="comconsole,vidconsole"
EOF

cat > "$TRGT/boot/config" <<EOF
-DhP -S$serial_console_speed
EOF
