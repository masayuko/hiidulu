# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

EGIT_REPO_URI="git://git.kernel.org/pub/scm/linux/hotplug/udev.git"
EGIT_BRANCH="master"
#EGIT_REPO_URI="git://github.com/kaysievers/udev.git"

inherit eutils flag-o-matic multilib toolchain-funcs linux-info git-2 autotools
DESCRIPTION="Linux dynamic and persistent device naming support (aka userspace devfs)"
HOMEPAGE="http://www.kernel.org/pub/linux/utils/kernel/hotplug/udev.html"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="selinux extras introspection +gudev"

COMMON_DEPEND="selinux? ( sys-libs/libselinux )
	sys-apps/acl
	>=sys-apps/usbutils-0.82
	virtual/libusb:0
	sys-apps/pciutils[-zlib]
	dev-libs/glib:2
	sys-apps/kmod
	introspection? (
		>=dev-libs/gobject-introspection-0.6.9
	)"

DEPEND="${COMMON_DEPEND}
	dev-util/gperf
	>=sys-kernel/linux-headers-2.6.34
	app-text/docbook-xsl-stylesheets
	app-text/docbook-xml-dtd
	dev-util/gtk-doc"
RDEPEND="${COMMON_DEPEND}
	!sys-apps/coldplug
	!<sys-fs/lvm2-2.02.45
	!sys-fs/device-mapper
	>=sys-apps/baselayout-2.1.6"

# required kernel options
CONFIG_CHECK="INOTIFY_USER SIGNALFD !SYSFS_DEPRECATED !SYSFS_DEPRECATED_V2
	!IDE"

# We need the lib/rcscripts/addon support
PROVIDE="virtual/dev-manager"

pkg_setup() {
	linux-info_pkg_setup

	udev_libexec_dir="/$(get_libdir)/udev"

	[ "$ROOT" != "/" ] && return 0
	local fkv="$(uname -r)"
	local kv="${fkv%-*}"
	local k2="${kv%.*}"
	local kmin="${kv##*.}"
	echo $USE
	if ! use bindist && [ "$k2" == "2.6" ] && [ "$kmin" -lt 27 ] && [ "${FEATURES/safetydance/}" = "${FEATURES}" ]
	then
		eerror
		eerror "Current kernel version: $kv"
		eerror "Minimum kernel version: 2.6.27"
		eerror
		ewarn "You are installing a version of udev that is incompatible with your"
		ewarn "currently-running kernel. This version of udev requires a kernel"
		ewarn "version of 2.6.27 or greater. Please use an earlier version of udev"
		ewarn "with your running kernel by masking this version of udev, by adding"
		ewarn "the following line to /etc/portage/package.mask:"
		ewarn
		ewarn ">=sys-fs/udev-160"
		ewarn
		ewarn "Alternatively, you may choose to upgrade to a compatible kernel, update"
		ewarn "your boot loader and reboot your system so that the new kernel is"
		ewarn "active. Then this version of udev will be compatible with your kernel"
		ewarn "and the udev merge will then proceed without warning."
		ewarn
		ewarn "If you know what you are doing and want to override this safety check,"
		ewarn "add 'safetydance' to FEATURES as follows:"
		ewarn
		ewarn "FEATURES=\"safetydance\" emerge <emerge arguments here>"
		ewarn
		ewarn "This will cause this runtime safety check to be skipped."
		die
	fi
	return 0
}

sed_libexec_dir() {
	sed -e "s#/lib/udev#${udev_libexec_dir}#" -i "$@"
}

src_prepare() {
	sed -e "s#/lib/modules/#/$(get_libdir)/modules/#" -i src/udevd.c

	# change rules back to group uucp instead of dialout for now - eventually
	# fix baselayout -

	sed -e 's/GROUP="dialout"/GROUP="uucp"/' \
		-i rules/{rules.d,arch,misc}/*.rules \
	|| die "failed to change group dialout to uucp"

	sed_libexec_dir \
		src/extras/rule_generator/write_*_rules \
		|| die "sed failed"
#		rules/rules.d/50-udev-default.rules \
#		rules/rules.d/78-sound-card.rules \

	gtkdocize --copy
	eautoreconf
}

src_compile() {
	filter-flags -fprefetch-loop-arrays

	# sys-fs/lvm2 may require static libs - generate them just to be on the safe
	# side. shared libs get generated too.

	econf \
		--prefix=/usr \
		--sysconfdir=/etc \
		--sbindir=/sbin \
		--libdir=/usr/$(get_libdir) \
		--with-rootlibdir=/$(get_libdir) \
		--libexecdir="${udev_libexec_dir}" \
		--enable-logging \
		--enable-static \
		--with-pci-ids-path="${EPREFIX}/usr/share/misc/pci.ids" \
		--with-usb-ids-path="${EPREFIX}/usr/share/misc/usb.ids" \
		$(use_enable gudev) \
		$(use_with selinux) \
		$(use_enable introspection) \
		--without-systemdsystemunitdir

	emake || die "compiling udev failed"
}

src_install() {
	into /
	emake DESTDIR="${D}" install || die "make install failed"

	exeinto "${udev_libexec_dir}"
	keepdir "${udev_libexec_dir}"/state
	keepdir "${udev_libexec_dir}"/devices

	local x
	for x in net.sh move_tmp_persistent_rules.sh write_root_link_rule shell-compat.sh shell-compat-addon.sh
	do
		doexe "${FILESDIR}/${PVR}/${x}" || die "${x} not installed properly"
	done

	# Use Funtoo's "realdev" command to create initial set of device nodes in
	# /lib/udev/devices. This set of device nodes will be copied to /dev when
	# udev starts.

	$ROOT/sbin/realdev ${D}${udev_libexec_dir}/devices || die

	# create symlinks for these utilities to /sbin
	# where multipath-tools expect them to be (Bug #168588)
	dosym "..${udev_libexec_dir}/vol_id" /sbin/vol_id
	dosym "..${udev_libexec_dir}/scsi_id" /sbin/scsi_id

	# Add gentoo stuff to udev.conf
	echo "# If you need to change mount-options, do it in /etc/fstab" \
	>> "${D}"/etc/udev/udev.conf

	# let the dir exist at least
	keepdir /etc/udev/rules.d

	# Now installing rules
	cd "${S}"/rules
	insinto "${udev_libexec_dir}"/rules.d/

	# support older kernels
	doins misc/30-kernel-compat.rules

	# Our rules files
	doins "${FILESDIR}"/${PVR}/??-*.rules

	# Adding arch specific rules
	if [[ -f arch/40-${ARCH}.rules ]]
	then
		doins "arch/40-${ARCH}.rules"
	fi
	cd "${S}"

	# The udev-post init-script
	local x
	for x in udevd udev-save udev-mount udev-postmount
	do
		newinitd "${FILESDIR}"/${PVR}/${x}.initd ${x} \
			|| die "initscript $x install error"
	done

	# config file for init-script and start-addon
	newconfd "${FILESDIR}/${PVR}/udev.confd" udev \
		|| die "udev.confd install error"

	insinto /etc/modprobe.d
	newins "${FILESDIR}/${PVR}/blacklist-146" blacklist.conf
	newins "${FILESDIR}/${PVR}/pnp-aliases" pnp-aliases.conf

	# convert /lib/udev to real used dir
	# "${D}/$(get_libdir)"/rcscripts/addons/*.sh \
	sed_libexec_dir \
		"${D}/${udev_libexec_dir}"/write_root_link_rule \
		"${D}/${udev_libexec_dir}"/rules.d/* \
		"${D}"/etc/conf.d/udev \
		"${D}"/etc/init.d/udev* \
		"${D}"/etc/modprobe.d/*

	sed -i -e 's:/lib/librc.so:/'"$(get_libdir)"'/librc.so:' "${D}/${udev_libexec_dir}"/shell-compat.sh

	# keep doc in just one directory, Bug #281137
	rm -rf "${D}/usr/share/doc/${PN}"
	if use extras; then
		dodoc src/extras/keymap/README.keymap.txt || die "failed installing docs"
	fi

	echo "CONFIG_PROTECT_MASK=\"/etc/udev/rules.d\"" > 20udev
	doenvd 20udev
}

modfix() {
	local mod

	# We want to move any old modprobe.d conf files to the new file name so
	# config file protection works correctly.

	for mod in blacklist pnp-aliases
	do
		if [ -e $ROOT/etc/modprobe.d/$mod ]
		then
			mv $ROOT/etc/modprobe.d/$mod $ROOT/etc/modprobe.d/${mod}.conf || die "mv failed"
		fi
	done
}

pkg_preinst() {
	modfix

	if [[ -d ${ROOT}/lib/udev-state ]]
	then
		mv -f "${ROOT}"/lib/udev-state/* "${D}"/lib/udev/state/
		rm -r "${ROOT}"/lib/udev-state
	fi

	if [[ -f ${ROOT}/etc/udev/udev.config &&
		 ! -f ${ROOT}/etc/udev/udev.rules ]]
	then
		mv -f "${ROOT}"/etc/udev/udev.config "${ROOT}"/etc/udev/udev.rules
	fi

	rm -f /etc/conf.d/udev #FORCE UPDATE
}

# from the openrc-0.3.0.22081113 ebuild :)
add_init() {
	local runl=$1
	if [ ! -e ${ROOT}/etc/runlevels/${runl} ]
	then
		install -d -m0755 ${ROOT}/etc/runlevels/${runl}
	fi
	for initd in $*
	do
		# if the initscript is not going to be installed and  is not currently installed, return
		[[ -e ${D}/etc/init.d/${initd} || -e ${ROOT}/etc/init.d/${initd} ]] || continue
		[[ -e ${ROOT}/etc/runlevels/${runl}/${initd} ]] && continue
		elog "Auto-adding '${initd}' service to your ${runl} runlevel"
		ln -snf /etc/init.d/${initd} "${ROOT}"/etc/runlevels/${runl}/${initd}
	done
}

# See Bug #129204 for a discussion about restarting udevd
restart_udevd() {
	#if [[ ${NO_RESTART} = "1" ]]; then
	#	ewarn "Not restarting udevd, as your kernel is too old!"
	#	return
	#fi

	# need to merge to our system
	[[ ${ROOT} = / ]] || return

	# check if root of init-process is identical to ours (not in chroot)
	[[ -r /proc/1/root && /proc/1/root/ -ef /proc/self/root/ ]] || return

	# abort if there is no udevd running
	[[ -n $(pidof udevd) ]] || return

	# abort if no /dev/.udev exists
	[[ -e /dev/.udev ]] || return

	elog
	elog "restarting udevd now."

	killall -15 udevd &>/dev/null
	sleep 1
	killall -9 udevd &>/dev/null

	#/sbin/udevd --daemon
	"${udev_libexec_dir}"/udevd --daemon
	sleep 3
	if [[ ! -n $(pidof udevd) ]]; then
		eerror "FATAL: udev died, please check your kernel is"
		eerror "new enough and configured correctly for ${P}."
		eerror
		eerror "Please have a look at this before rebooting."
		eerror "If in doubt, please downgrade udev back to your old version"
		ebeep
	fi
}

pkg_postinst() {
	# disable coldplug script
	rm -f $ROOT/etc/runlevels/*/coldplug

	# disable any old udev script
	rm -f $ROOT/etc/runlevels/*/udev

	rm -f $ROOT/etc/runlevels/*/udev-postmount

	restart_udevd

	add_init sysinit udev-mount
	add_init sysinit udevd
	add_init boot udev-postmount
	add_init shutdown udev-save

	# requested in Bug #225033:
	elog
	elog "persistent-net does assigning fixed names to network devices."
	elog "If you prefer to disable persistent-net, this can be done via"
	elog "/etc/conf.d/udev."

	ewarn
	ewarn "mount options for directory /dev are no longer"
	ewarn "set in /etc/udev/udev.conf, but in /etc/fstab"
	ewarn "as for other directories."

	elog
	elog "For more information on udev on Gentoo, writing udev rules, and"
	elog "         fixing known issues visit:"
	elog "         http://www.gentoo.org/doc/en/udev-guide.xml"
}
