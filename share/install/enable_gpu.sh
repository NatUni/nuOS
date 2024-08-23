for gpu in ${GPU_VENDOR-}; do
	case $gpu in
		[Nn][Vv][Ii][Dd][Ii][Aa])
			eko hw.nvidiadrm.modeset=1 > "$TRGT/boot/loader.conf.d/nvidia-modeset.conf"
			gpu_kmod=nvidia-drm
			eko 'nuos_gui_nvidia="YES"' >> "$TRGT/etc/rc.conf.d/nuos_gui"
		;;
		[Aa][Mm][Dd]) gpu_kmod=amdgpu;;
		[Ii][Nn][Tt][Ee][Ll]) gpu_kmod=i915kms;;
		[Rr][Aa][Dd][Ee][Oo][Nn]) gpu_kmod=radeonkms;;
		*) error 2 unknown/unsupported GPU_VENDOR
	esac
	push gpu_kmods $gpu_kmod
done
cat >> "$TRGT/etc/rc.conf.local" <<EOF
kld_list="\$kld_list $gpu_kmods"
EOF
