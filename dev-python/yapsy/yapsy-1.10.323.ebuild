# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

MY_P="Yapsy-${PV}"
PYTHON_COMPAT=( python{2_7,3_2,3_3,3_4} )

inherit distutils-r1

DESCRIPTION="A fat-free DIY Python plugin management toolkit"
HOMEPAGE="http://yapsy.sourceforge.net/"
SRC_URI="mirror://pypi/Y/Yapsy/${MY_P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86"

DEPEND="dev-python/setuptools[${PYTHON_USEDEP}]"
RDEPEND=""

S="${WORKDIR}/${MY_P}"

python_test() {
	esetup.py test
}