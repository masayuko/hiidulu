# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=1

DESCRIPTION="Manages ECJ symlinks"
HOMEPAGE="http://www.gentoo.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ~ia64 ~ppc ~ppc64 x86 ~x86-fbsd ~x86-freebsd ~amd64-linux ~x86-linux ~sparc-solaris ~x86-solaris"
IUSE=""

RDEPEND=">=app-admin/eselect-1.2.3"
PDEPEND="
|| (
	dev-java/eclipse-ecj:3.6
	dev-java/eclipse-ecj:3.5
	dev-java/eclipse-ecj:3.4
	>=dev-java/eclipse-ecj-3.3.0-r2:3.3
	dev-java/ecj-gcj:3.5
)"

src_install() {
	insinto /usr/share/eselect/modules
	newins "${FILESDIR}/ecj-${PV}.eselect" ecj.eselect || die "newins failed"
}
