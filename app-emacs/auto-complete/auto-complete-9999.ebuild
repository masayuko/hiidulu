# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

EGIT_REPO_URI="git://github.com/m2ym/auto-complete.git"

inherit elisp eutils git-2

DESCRIPTION="Auto-complete package"
HOMEPAGE="http://cx4a.org/software/auto-complete/
	http://github.com/m2ym/auto-complete/"
#SRC_URI="http://cx4a.org/pub/${PN}/${P}.tar.bz2"
SRC_URI=""

LICENSE="GPL-3 FDL-1.3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="linguas_ja"

SITEFILE="50${PN}-gentoo.el"

src_prepare() {
	epatch "${FILESDIR}"/border-width.patch
}

src_install() {
	elisp_src_install

	# install dictionaries
	insinto "${SITEETC}/${PN}"
	doins -r dict || die

	dodoc README.txt TODO.txt etc/test.txt || die
	cd doc
	dodoc index.txt manual.txt demo.txt changes.txt *.png || die
	if use linguas_ja; then
		dodoc index.ja.txt manual.ja.txt changes.ja.txt || die
	fi
}
