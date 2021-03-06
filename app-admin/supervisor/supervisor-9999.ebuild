# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python{2_7,3_5,3_6,3_7} )
# xml.etree.ElementTree module required.
PYTHON_REQ_USE="xml"

EGIT_REPO_URI="https://github.com/Supervisor/supervisor.git"

inherit distutils-r1 systemd git-r3

MY_PV="${PV/_beta/b}"

DESCRIPTION="A system for controlling process state under UNIX"
HOMEPAGE="http://supervisord.org/ http://pypi.python.org/pypi/supervisor"
#SRC_URI="mirror://pypi/${P:0:1}/${PN}/${PN}-${MY_PV}.tar.gz"

LICENSE="repoze ZPL BSD HPND GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="test"

RDEPEND=">=dev-python/meld3-0.6.10-r1[${PYTHON_USEDEP}]
	dev-python/setuptools[${PYTHON_USEDEP}]"
DEPEND="${RDEPEND}
	test? ( dev-python/mock[${PYTHON_USEDEP}] )"

# package uses namespaces which makes tests use installed packages
RESTRICT="test"

S="${WORKDIR}/${PN}-${MY_PV}"

DOCS=( CHANGES.txt TODO.txt )

#python_prepare_all() {
#	# write missing MANIFEST.in file, otherwise required files get lost due to
#	# egg_info being passed to setup.py
#	cat > MANIFEST.in << EOF
#include supervisor/*.txt
#recursive-include supervisor/skel *.conf
#recursive-include supervisor/ui *.html *.css *.gif *.png
#recursive-include supervisor/tests *.conf *.txt
#EOF
#}

python_test() {
	esetup.py test
}

python_install_all() {
	newinitd "${FILESDIR}/init.d-r1" supervisord
	newconfd "${FILESDIR}/conf.d" supervisord

	systemd_dounit "${FILESDIR}/supervisord".{service,socket}

	insinto /etc
	doins "${FILESDIR}/supervisord.conf"

	keepdir /etc/supervisor.d
}
