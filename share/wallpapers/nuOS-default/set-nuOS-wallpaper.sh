log=/tmp/nuOS-plasma-login.$$.set_wallpaper
mkdir $log || exit 1
while ! dbus-send --session --dest=org.kde.plasmashell --type=method_call --print-reply /PlasmaShell org.kde.PlasmaShell.evaluateScript 'string:
	var Desktops = desktops();
	for (i = 0; i < Desktops.length; i++) {
		d = Desktops[i];
		d.wallpaperPlugin = "org.kde.image";
		d.currentConfigGroup = Array("Wallpaper", "org.kde.image", "General");
		d.writeConfig("Image", "/usr/local/share/wallpapers/nuOS-default/");
	}'; do sleep 0.5; done 2> $log/err > $log/out &
[ x$i = x${i%set-nuOS-wallpaper.sh} ] || rm $i
