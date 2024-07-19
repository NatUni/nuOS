#!/usr/bin/false
echo DO NOT EXECUTE THIS FILE directly or completely. Instead, READ it carefully.
exit 1

# These are notes, with no particular order to them. DO NOT invoke any of these commands blindly;
# study them. Many of these commands are literal and verbatim as used on the systems at operation
# headquarters and in our various development labs for specific usage in particular applications.

# Certain assumptions are as follows:

# The processes documented here are illustrated using a nuOS system by the commands appropriate for
# instructing a nuOS system to accomplish each step but the steps follow a narrative which assumes
# you do not yet have nuOS on the intended target computer. So either the assumption is being made
# that you have at least one nuOS system available to you before installing another nuOS system,
# or, a level of technical proficiency on the platform of your choice is being assumed in order for
# you to translate these actions to those appropriate for the current platform you are using. The
# coverage of this procedure on various alternative platforms is beyond the scope of this document.

# The commands needed to bootstrap the nuOS system should look and work identically to those of
# the FreeBSD operating system (because it does actually comprise the core foundation and much of
# the infrastructure of nuOS). You may start your journey with a FreeBSD system and follow along
# this tutorial exactly or you might feel comfortable performing these steps with another operating
# system. Hopefully, thorough explanation of each step will make your nuOS experience approachable
# and powerful as you discover new and exciting ways to take command of your devices and digital
# lifestyle. Please share your experience and knowledge with us and others early and often through
# your nuOS journey! Don't hesitate to reach out on nuOS.org and/or CropCircle.Systems for help.

# "jedi" is the name used within our organization for the initial system administrator account.
# Replace jedi where you see it with the name you have chosen. If removed/unspecified, the nuOS
# default used is "ninja". The empty string is a valid choice which omits the installation of an
# administrator altogether, which may be a valid configuration in production if your system is
# statically defined or to be managed from a higher layer of greater capability (such as your own
# bespoke programming) or a lower layer of greater authority (such as a virtual machine manager).
# Note this important distinction affecting system behavior between this value being defined to be
# empty versus being left undefined by omission.

# "neo" mentioned below, or "neo.zion.top." is one server device currently running at headquarters
# in central Florida. It accesses a quicker and smaller storage system for primary operations (such
# as booting up, among other things) which is called "nebu". It also accesses and manages a larger,
# slower storage subsystem called "zion". Both can be seen in these [literal] examples documented.

# "tty" in most instances below refers to one personal and individual laptop computer of our Chief
# Technology Operator, Chad Jacob Milios. "tty.zion.top" is the fully qualified DNS hostname for
# that laptop. Technically, "tty" more frequently here actually refers to its internal hard drive
# storage by way of its zpool label or the human-meaningful portion of its GPT label. (A zpool is a
# construct of ZFS, the Zettabyte File System. GPT, the GUID Partition Table, is a construct used
# to provision physical data storage devices, of significance to your system's firmware and early
# bootstrap mechanisms of the software.)

#     Note that tty can also refer generally to a teletype, a construct of UNIX (and so derived)
#     systems: a primitive and powerful interface, historically consisting of a keyboard coupled
#     with a screen of primarily text and little or no graphics, one or more sets of which are
#     connected to a system by way of their own bidirectional serial data communication interfaces.
#     A tty (also known as a terminal) by design lacks any pointing device such as a touchscreen or
#     mouse (although there are protocols which allow the composition of a tty along with certain
#     limited functionality from a pointing device to be sent in band along the serial connection.)

#     Know then that nuOS is one such UNIX derived system. Therefore you may encounter in places
#     some codes, scripts or commands which pertain to teletypes or their functionality and refer
#     to them using that same identifier, "tty". It is an exercise of an expert or so interested
#     reader to determine when it is appropriate to change the mention of "tty" from our specific
#     and individual examples to their own personalized label given to their own systems or on the
#     other hand when it is not appropriate to modify the general use of the generic term, tty.

# nuOS systems typically (but not exclusively) run atop the ZFS data storage subsystem. In systems
# with a modest amount of tightly coupled storage, it is conventional for this storage device(s) to
# be named exactly as the system it is attached to (if it is indeed the storage device containing
# the operating system involved in its day to day use). Storage devices which are loosely coupled
# to the systems accessing and running them are typically given distinct names, especially if the
# storage is an archive or data warehouse intended to evolve beside and to outlive those systems so
# attached and/or associated.

# If you follow our customary practices then systems of operation and execution (computers and so
# forth in their various form factors) are typically named for people or characters; think "bart",
# "lisa" and "milhouse". Devices and systems designed for storage then are named for places; think
# "springfield" or "shelbyville". To make this rule more general, it is also accepted practice to
# name computers for dynamic things or concepts and to label storage as static things/ideas; think
# "rain" and "thunder" vs. "sky" or "ocean". Of course these ideas are entirely subjective and
# these labels are completely arbitrary.

# It has been said and oft repeated that there are only two truly difficult problems in the science
# and engineering of computerized and networked systems: naming things and cache invalidation. (A
# cache is a place to put [a copy of] data which is closer/faster than the authoritative source of
# truth regarding that data; any modern system involves layers and layers ad nauseam of such caches
# in vast hierarchies and networks.) It has also been said that we should treat our systems not as
# pets but rather as livestock. Discussion on the merits and pitfalls of either approach is beyond
# the scope of this document. Valid rationale can be found on both sides and your solution might be
# a composition of both strategies according to the context and use case you're interested in.

# This documentation illustrates a few simple systems and a modest network as concrete examples,
# used in production primarily for our cause of spreading quality open source software to more
# people and fostering interest in digital sovereignty and independence. Hopefully you will enjoy
# your experience with us and participate in our growth and expansion. Thank you for taking the
# time to explore our digital ecosystem!

# The current live boot and installation image is available from https://nuOS.org and retrieved as
# follows. Note that unless you are already using nuOS you might use an alternate method to get it.
fetch https://nuos.org/nuOS-v12.999a0-amd64.dd.xz

# For high security environments a PGP signed fingerprint is also available. The commands below are
# merely illustrative. Note that to download and verify the fingerprint using the same computer and
# network as downloaded the installation image offers negligible added security benefit. Accessing
# the fingerprint via an out of band channel(s) and verifying the integrity of the generated boot
# media using highly trustworthy device(s) is an exercise for a motivated user, situation dependent
# and not covered in this document. Prepared nuOS system drives are available for shipment at a low
# cost from https://CropCircle.Systems although it must be understood that ultimately any device we
# use to run nuOS must still be an implicitly trusted device. nuOS may be quite robust against most
# sorts of attack or infection once it is operational, however any software can be rendered utterly
# powerless to defend against preexisting malware of all but the most rudimentary types. Consider
# a brand new computer for running nuOS offered by a trustworthy vendor of hardware and consulting
# services specializing in security.
fetch https://nuos.org/nuOS-v12.999a0-amd64.dd.sum

# List suitable devices recognized by the system.
geom disk list | grep -wiF -e 'geom name:' -e descr: -e mediasize: -e ident:

# *Output* from the above command looks something like this:
# Geom name: nvd0
#    Mediasize: 256060514304 (238G)
#    descr: Micron MTFDKCD256TFK
#    ident: 232040DE5D6B
# Geom name: da0
#    Mediasize: 125162225664 (117G)
#    descr: SanDisk SanDisk 3.2 Gen1
#    ident: A20038A6280CEB60

# I've recently inserted a SanDisk brand thumb drive of 128 GB capacity so I believe "da0" is our
# target disk as indicated by "Geom name: da0" above. Note the size, description and serial number
# match that of the drive you intend to wipe and use for nuOS.

# WARNING: "da0" seen below is the name of a new blank USB thumb drive (of at least 64 GB in size)
#          when it is attached to tty or neo. Other systems, your system for instance, may have one
#          or more drives that the system has already identified as da0, da1, da2, etc. Therefore
#          BE VERY CERTAIN of WHICH DRIVE you wish to ERASE and format exclusively for installing
#          and running nuOS. (Multi-boot scenarios are an option for the expert or very interested
#          reader and will not be covered in this document.)

# Investigate the current layout of the disk, "da0" in this case. This does not apply modifications.
gpart show da0

# *Output* from the above command will look something like this for a typical drive:
# =>       63  244457409  da0  MBR  (117G)
#          63       1985       - free -  (993K)
#        2048  244455424    1  ntfs  (117G)

# TODO: Include example output from a few other common drive formats.

# If the output from the preceding command does not appear meaningful to you, don't worry; if you
# are certain you're ready to totally wipe the drive clean then you may ignore any output or error
# the previous command may have produced.

# Become the "root" user. Commands from here will require total access and authority in order to
# change the on disk format of a disk and/or install a totally different operating system. Working
# with your system's root account must be done carefully and meticulously. You have been warned.
su -l

###################################################################################################
# WARNING: The following commands will OBLITERATE any data you might have on drive "da0" (for all #
#          intents and purposes). Note that if your actual intention *is* to obliterate the data  #
#          on the drive, this is not the proper and secure way to do that effectively. Again, be  #
#          very certain you are dealing with the correct drive that you intend to erase and use.  #
###################################################################################################

# NOTE: Effectively wiping a drive clean for purposes of confidentiality is beyond the scope of
#       this document. These commands would simply make it highly inconvenient to recover prior
#       data, although not very difficult for a truly motivated adversary. Data destruction or
#       recovery will not be covered in this guide.

# NOTE: Only if you are using a drive that has already been formatted for nuOS in the past, there
#       is the following extra step. This is necessary because the step after that only erases
#       the layout information on the drive, and later steps may replace an identical layout, after
#       which a further step may refuse to overwrite the data contained at areas referenced by the
#       disk layout. If you're unsure whether or not this step is applicable to you and you're very
#       certain that the drive contains no data of value to you then you may include this step and
#       ignore any error it may produce. Importantly, the "p3" after the "da0" in the combined part
#       identifier ("da0p3") is found by referencing the "3" shown in the third column of output by
#       the previous investigative command and may actually be a "2" or a "3" (depending on whether
#       the nuOS (or similarly) formatted drive was used for booting and running a system or merely
#       for storing data.) The key element to realize is that the proper number is found beside and
#       on the same line with the information including the type "freebsd-zfs".

# Clean the partition on the drive of any vestigial nuOS, FreeBSD or ZFS data structures which may
# interfere with the fresh installation.
zpool labelclear -f /dev/da0p3

# Wipe the drive in preparation of installation.
gpart destroy -F da0

# Simultaneously decompress and write the boot/installation image to our blank drive.
xzcat -T0 /home/jedi/nuOS-v12.999a0-amd64.dd.xz | dd of=/dev/da0 ibs=128K iflag=fullblock obs=128K conv=sparse,osync status=progress


# ...more to come...


# Your shell is (t)csh and you want to use the nuOS version your system came with:
setenv PATH ${PATH}:/usr/nuos/bin

# Your shell is (t)csh and you want to use the nuOS version you're developing:
setenv PATH ${PATH}:/home/$USER/nuOS/bin

# Your shell is (ba)sh and you want to use the nuOS version your system came with:
PATH=$PATH:/usr/nuos/bin

# Your shell is (ba)sh and you want to use the nuOS version you're developing:
PATH=$PATH:/home/$USER/nuOS/bin

# WARNING: Passing secrets via the environment or command line is insecure on any multiuser system
#          and any secrets landing in your shell's command history log are hard to keep private.
#          The ADMIN_PASS, USER_PASS and BD_PASS variables support one special value, '?' which
#          will prompt you to enter the password interactively and securely.
env ADMIN_NAME='Jedi Hacker' ADMIN_CPNY='Rebel Alliance' \
    ADMIN_PASS='?' \
    USER_PASS='?' \
    DISPLAY_MANAGER=light \
    TZ=America/Detroit \
    nu_sys -p tty \
        -es 16G \
        -h tty.zion.top \
        -b '' \
        -a jedi \
        -c desktop \
        -l @set_timezone \
        -l @keep_time \
        -l @enable_dynamic_network \
        -l @cache_dns \
        -l @harden_remote_login \
        -l @activate_gui \
        -q

# "joe" is the default user/owner account without administrator privileges. Some examples leave
# this user to be implied by the software while others eliminate this user through use of the empty
# string. An account for "joe" will be included by the preceding command.

# "sumyungai" is the default vendor backdoor administrator account name. As this is a facility for
# vendors and value added resellers to offer bespoke services and customer support (upstream of
# their clients and downstream of the nuOS team) this functionality is disabled at headquarters
# and should be disabled by any end users not acquiring a commercial contract for support services.
# Nonetheless, we want this facility to remain robust, secure and well tested. You are encouraged
# to consider commercial contracts or private agreements of technical support amongst one another,
# building relationships according to each's needs and means. Examples here include "-b ''" where
# this variable is applicable, which entirely omits all such facilities and capabilities from the
# software installation.



### WARNING ###
# Entering the twilight zone. Commands below this line have not been reviewed. Thar be dragons hyar
# matey, arrrggg!

history -S +
nu_exodus local
cp -anv nuos_site_exodus/local/root/.*history `echo /tmp/nu_sys.*.ALT_MNT.*`/root/
cp -anv nuos_site_exodus `echo /tmp/nu_sys.*.ALT_MNT.*`/root/nuos_deliverance

shutdown -r now

patch -N -V none /etc/nuos/exodus.local < ~/nuos_deliverance/exodus.local.diff

patch -N -V none /etc/nuos/backup < ~/nuos_deliverance/local/backup.diff

patch -N -V none /usr/local/etc/wifibox/bhyve.conf < ~/nuos_deliverance/local/wifibox/bhyve.conf.diff
patch -N -V none /usr/local/etc/wifibox/wpa_supplicant/wpa_supplicant.conf < ~/nuos_deliverance/local/wifibox/wpa_supplicant.conf.diff

wpa_passphrase 'My WiFi Network Name' 'theWiFiPa$$w0rd' >> /usr/local/etc/wifibox/wpa_supplicant/wpa_supplicant.conf

enable_svc wifibox
cat >> /etc/rc.conf.local <<EOF
ifconfig_wifibox0="SYNCDHCP"
background_dhclient_wifibox0="YES"
defaultroute_delay="0"
EOF
service wifibox start
service netif restart wifibox0


nu_update -o update.`date +%Y-%m-%d-%H%M%S`.out -fff -aaa -q

nu_build -q

service jail stop

nu_exodus

zfs list -r -H -o name,mounted,mountpoint -S mountpoint nebu/svc | awk '$2 == "yes" && $3 != "-" && $3 != "none" {print $1}' | xargs -n 1 zfs unmount

(umask 77 && nu_backup -p nebu svc jail > ~/nebu-backup.`date +%Y-%m-%d-%H%M%S`.zstream)

zfs destroy -r nebu/svc

nu_jail -dfqj lab0
nu_jail -dfqj nuos-lab0
nu_jail -dfqj base-lab0
nu_jail -dfqj lab1
nu_jail -dfqj nuos-lab1
nu_jail -dfqj base-lab1

nu_jail -dfqj b.ns
nu_jail -dfqj a.ns
nu_jail -dfqj ns
nu_jail -dfqj resolv; rm -v /etc/resolv.conf /etc/resolvconf.conf
nu_jail -dfqj postmaster
nu_jail -dfqj postoffice
nu_jail -dfqj www
nu_jail -dfqj pgsql
nu_jail -dfqj redmine

zfs destroy -r nebu/jail

env ADMIN_PASS= \
    ADMIN_NAME='Jedi Hacker' ADMIN_CPNY='Rebel Alliance' \
    TZ=America/Detroit \
    nu_sys -p nebu \
        -es 48G \
        -h neo.zion.top \
        -b '' \
        -a jedi \
        -u '' \
        -c desktop \
        -l @../examples/install/cargobay_init \
        -q

cp -anv nuos_site_exodus `echo /tmp/nu_sys.*.ALT_MNT.*`/root/nuos_deliverance
cp -anv ~/owner_pass /tmp/nu_sys.*.ALT_MNT.*/root/
cp -anv /usr/local/etc/ssh/ssh_host_*_key* /tmp/nu_sys.*.ALT_MNT.*/usr/local/etc/ssh/
history -S +
cp -anv ~/.*history `echo /tmp/nu_sys.*.ALT_MNT.*`/root/

shutdown -r now


zfs destroy -r nebu/img/spore

env DISPLAY_MANAGER=light nu_release -qHfxd@ -h spore.nuos.org -l @activate_gui
cp -v /root/nuOS-v12.999a0-amd64.dd.* /var/jail/www/home/jedi/nuos.org/www/public/

gpg2 --local-user 5B3FBE91885DE388FED3339FEDB7CB91F1FB7E42 --clear-sign nuOS-v12.999a0-amd64.dd.sum

export GNUPGHOME=$(mktemp -d) && gpg2 --import /usr/nuos/share/key/root\@nuos.org.pub && gpg2 --batch --yes --command-file <(printf 'trust\n5\ny\nsave\nquit\n') --edit-key 5B3FBE91885DE388FED3339FEDB7CB91F1FB7E42 && gpg2 --verify nuOS-v12.999a0-amd64.dd.sum.asc


zpool export spore
nu_img -d spore
zfs destroy -r tty/img/spore

nu_img -C spore

# same `xzcat ... | dd ...` as above

zpool import -R /spore spore
nu_os_install -P spore -p tty -q



rsync -avP --delete ~/nuOS nuos.org:



(cd /usr/obj/usr/src/amd64.amd64 && umask 27 && find . -not -perm +go+r | xargs tar -cv --lz4 -f special_permissions.tlz)
find /usr/ports -depth 3 -type d '(' -name work -or -name 'work-*' ')' | xargs rm -rfv
chown -Rv jedi:jedi /usr/{src,obj,ports}

rsync -avP --delete --exclude ports/distfiles --exclude 'ports/*/*/work*' nuos.org:/usr/{src,obj,ports} /usr/

chown -Rv root:wheel /usr/{src,obj,ports}
(cd /usr/obj/usr/src/amd64.amd64 && tar -xvpf special_permissions.tlz)





zfs list -rH -o mountpoint,name nebu/os/FreeBSD/13.3-RELEASE-p4/amd64.opteron-sse3/r0 | sort | while IFS=$'\t' read -r m d; do mount -t zfs -r $d /mnt$m; done
mount -p | awk '$2 == "/mnt" || $2 ~ "^/mnt/" {print $2}' | tail -r | xargs -n1 umount

env ADMIN_NAME='Jedi Hacker' ADMIN_CPNY='Rebel Alliance' \
    ADMIN_PASS=jizz \
    TZ=America/Detroit \
    PRIMARY_NETIF=igc0 \
    GPU_VENDOR=AMD \
    DISPLAY_MANAGER=light \
    nu_sys -p rick \
        -es 120G \
        -h rick.space.force.us.org \
        -b '' \
        -a jedi \
        -u '' \
        -c desktop \
        -l @set_timezone \
        -l @set_primary_netif \
        -l @enable_dynamic_network \
        -l @soho_mdns \
        -l @cache_dns \
        -l @keep_time \
        -l @harden_remote_login \
        -l @allow_remote_login \
        -l @../examples/install/allow_jedi_in \
        -l @activate_gui \
        -q

env ADMIN_NAME='Jedi Hacker' ADMIN_CPNY='Rebel Alliance' \
    ADMIN_PASS=jizz \
    TZ=America/Detroit \
    PRIMARY_NETIF=re0 \
    GPU_VENDOR=AMD \
    DISPLAY_MANAGER=light \
    nu_sys -p solo \
        -es 72G \
        -h solo.hodl.ceo \
        -b '' \
        -a jedi \
        -u '' \
        -c desktop \
        -l @set_timezone \
        -l @use_proprietary_realtek_driver \
        -l @set_primary_netif \
        -l @enable_dynamic_network \
        -l @soho_mdns \
        -l @cache_dns \
        -l @keep_time \
        -l @harden_remote_login \
        -l @allow_remote_login \
        -l @../examples/install/allow_jedi_in \
        -l @activate_gui \
        -q

env ADMIN_NAME='Jedi Hacker' ADMIN_CPNY='Rebel Alliance' \
    ADMIN_PASS=jizz \
    TZ=America/Detroit \
    PRIMARY_NETIF=re1 \
    GPU_VENDOR=Radeon \
    DISPLAY_MANAGER=light \
    nu_sys -p yoda \
        -s 48G \
        -h yoda.boogaloo.ninja \
        -b '' \
        -a jedi \
        -u '' \
        -c desktop \
        -l @set_timezone \
        -l @use_proprietary_realtek_driver \
        -l @set_primary_netif \
        -l @enable_dynamic_network \
        -l @soho_mdns \
        -l @cache_dns \
        -l @keep_time \
        -l @harden_remote_login \
        -l @allow_remote_login \
        -l @../examples/install/allow_jedi_in \
        -l @activate_gui \
        -q






zpool labelclear -f gpt/bstd0
gpart destroy -F da0
nu_hdd -b -u 100 -p bstd -q da0
nu_os_install -p bstd -c base -q
nu_sys -a '' -u '' -b '' -s 4G -p bstd -c base -h bstd.nuos.org -q

zpool labelclear -f gpt/day0
gpart destroy -F mfid0
nu_hdd -b -u 100 -p day -q mfid0
nu_os_install -p day -q

env ADMIN_PASS= \
    ADMIN_NAME='Jedi Hacker' ADMIN_CPNY='Rebel Alliance' \
    TZ=America/Detroit \
    nu_sys -p day \
        -es 160G \
        -h mohican.zion.top \
        -b '' \
        -a jedi \
        -u '' \
        -c desktop \
        -l @set_timezone \
        -l @harden_remote_login \
        -q

echo 'vfs.root.mountfrom="zfs:'`zpool get -Hpovalue bootfs day`'"' >> /bstd/boot/loader.conf.local
zpool export bstd

zpool labelclear -f gpt/rest0
zpool labelclear -f gpt/rest1
zpool labelclear -f gpt/rest2
zpool labelclear -f gpt/rest3
zpool labelclear -f gpt/rest4
zpool labelclear -f gpt/rest5
gpart destroy -F mfid1
gpart destroy -F mfid2
gpart destroy -F mfid3
gpart destroy -F mfid4
gpart destroy -F mfid5
gpart destroy -F mfid6
nu_hdd -t 5 -p rest -q mfid1 mfid2 mfid3 mfid4 mfid5 mfid6

zpool import -R /spore spore
nu_os_install -P spore -p epic -q

# zpool destroy squr && zpool labelclear -f gpt/squr0 && gpart destroy -F da0x007
nu_hdd -b -p squr -q da0
nu_os_install -d -c server -p squr -q

env ADMIN_PASS= \
    ADMIN_NAME='Jedi Hacker' ADMIN_CPNY='Rebel Alliance' \
    \
    nu_sys -p squr \
        -s 64G \
        -h squr.one \
        -b '' \
        -a jedi \
        -u '' \
        -c server \
        -l @make_administrator_developer \
        -l @../examples/install/allow_jedi_in \
           \
        -l @use_proprietary_realtek_driver \
        -l @enable_dynamic_network         -l @soho_mdns \
        -l @harden_remote_login            -l @allow_remote_login \
           \
        -l @cache_dns \
        -q

env ADMIN_NAME='Jedi Hacker' ADMIN_CPNY='Rebel Alliance' \
    ADMIN_PASS=jizz \
    DISPLAY_MANAGER=light \
    TZ=America/Detroit \
    \
    nu_sys -p munq \
        -s 64G \
        -h munq.zion.top \
        -b '' \
        -a jedi \
        -u '' \
        -c desktop \
        -l @set_timezone \
        -l @make_administrator_developer \
        -l @../examples/install/allow_jedi_in \
           \
        -l @use_proprietary_realtek_driver \
        -l @enable_dynamic_network         -l @soho_mdns \
        -l @harden_remote_login            -l @allow_remote_login \
           \
        -l @cache_dns \
        -l @activate_gui \
        -q

env ADMIN_NAME='Jedi Hacker' ADMIN_CPNY='Rebel Alliance' \
    ADMIN_PASS=jizz \
    DISPLAY_MANAGER=light \
    TZ=America/Detroit \
    \
    nu_sys -p moos \
        -s 8G \
        -h moos.zion.top \
        -b '' \
        -a jedi \
        -u '' \
        -c desktop \
        -l @set_timezone \
        -l @make_administrator_developer \
        -l @../examples/install/allow_jedi_in \
           \
        -l @use_proprietary_realtek_driver \
        -l @enable_dynamic_network         -l @soho_mdns \
        -l @harden_remote_login            -l @allow_remote_login \
           \
        -l @cache_dns \
        -l @activate_gui \
        -q

env ADMIN_NAME='Jedi Hacker' ADMIN_CPNY='Rebel Alliance' \
    ADMIN_PASS=jizz \
    TZ=America/Detroit \
    PRIMARY_NETIF=re2 \
    GPU_VENDOR=Intel \
    DISPLAY_MANAGER=light \
    nu_sys -p epic \
        -s 24G \
        -h artu.bofh.vip \
        -b '' \
        -a jedi \
        -u '' \
        -c desktop \
        -l @set_timezone \
        -l @use_proprietary_realtek_driver \
        -l @set_primary_netif \
        -l @enable_dynamic_network \
        -l @soho_mdns \
        -l @cache_dns \
        -l @keep_time \
        -l @harden_remote_login \
        -l @allow_remote_login \
        -l @../examples/install/allow_jedi_in \
        -l @activate_gui \
        -q


zpool labelclear -f gpt/dusk0
gpart destroy -F da0x007
nu_hdd -b -p dusk -q da0x007
nu_os_install -c desktop -p dusk -q

zpool labelclear -f gpt/dawn0
gpart destroy -F da1x007
nu_hdd -b -p dawn -q da1x007
nu_os_install -d -c desktop -p dawn -q
env ADMIN_PASS= \
    ADMIN_NAME='Jedi Hacker' ADMIN_CPNY='Rebel Alliance' \
    nu_sys -p dawn \
        -s 48G \
        -h dawn.zion.top \
        -b '' \
        -a jedi \
        -u '' \
        -c desktop \
        -l @keep_time \
        -l @cache_dns \
        -l @enable_dynamic_network \
        -l @soho_mdns \
        -l @harden_remote_login \
        -l @allow_remote_login \
        -l @../examples/install/allow_jedi_in \
        -q


env ADMIN_ACCT=jedi ADMIN_PASS= \
    ADMIN_NAME='Jedi Hacker' ADMIN_CPNY='Rebel Alliance' \
    nu_release -Hr a5 -o pixy \
        -h pixy.bofh.vip \
        -c desktop \
        -l @ipxe_boot \
        -l @harden_remote_login \
        -l @allow_remote_login \
        -l @../examples/install/allow_jedi_in \
        -q


zpool labelclear -f gpt/coin0
zpool labelclear -f gpt/luke0
gpart destroy -F ada0x007
gpart destroy -F nvd0x007
nu_hdd -p coin -q ada0x007
nu_hdd -b -p luke -q nvd0x007
nu_os_install -c desktop -p luke -q
env ADMIN_PASS= \
    TZ=America/Detroit \
    DISPLAY_MANAGER=light \
    nu_sys -p luke \
        -es 16G \
        -h luke.mib.wtf \
        -b '' \
        -u '' \
        -c desktop \
        -l @set_timezone \
        -l @keep_time \
        -l @cache_dns \
        -l @enable_dynamic_network \
        -l @harden_remote_login \
        -l @activate_gui \
        -q


ls pkg/*_*/dependencies/all | cut -d / -f 2 | sed -e s,_,/, | xargs pkg check -dnq | cut -wf1 | xargs pkg delete -fyn | grep '^[[:space:]]' | sed -e 's/: /-/' | xargs -n1 > kill
xargs pkg delete -fy < kill
sh -c 'while read -r p; do rm -v /usr/ports/packages/All/$p.pkg; done < kill'
sh -c 'while read -r p; do rm -v /usr/ports/packages/Index.nuOS/FreeBSD-13.3-amd64.opteron-sse3/$p.g????????????.????????????????.pkg; done < kill'
