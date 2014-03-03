# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

EGIT_REPO_URI="https://github.com/kiwanami/emacs-deferred.git"

inherit elisp git-2

DESCRIPTION="Simple asynchronous functions for emacs lisp"
HOMEPAGE="https://github.com/kiwanami/emacs-deferred"
SRC_URI=""

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

src_prepare() {
	rm test-*.el
}
