# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
EHG_REPO_URI="https://projectkenai.com/hg/jna-posix~mercurial"
#EHG_REPO_URI="https://hg.kenai.com/hg/jna-posix~mercurial"

JAVA_PKG_IUSE="source"
inherit mercurial java-pkg-2 java-ant-2

DESCRIPTION="Lightweight cross-platform POSIX emulation layer for Java"
HOMEPAGE="http://kenai.com/projects/jna-posix"
#SRC_URI="http://dev.gentooexperimental.org/~chewi/distfiles/${P}.tar.bz2"
SRC_URI=""
LICENSE="|| ( CPL-1.0 GPL-2 LGPL-2.1 )"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=virtual/jre-1.5
		dev-java/jna"

DEPEND=">=virtual/jdk-1.5
		dev-java/jna"

#S="${WORKDIR}/${PN}~mercurial/"

java_prepare() {
	java-pkg_jar-from --into lib jna
}

src_install() {
	java-pkg_dojar dist/${PN}.jar
	use source && java-pkg_dosrc src/*
}
