# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"
JAVA_PKG_IUSE="doc source examples"

inherit java-pkg-2 java-ant-2 java-osgi

DESCRIPTION="JSch is a pure Java implementation of SSH2."
HOMEPAGE="http://www.jcraft.com/jsch/"
SRC_URI="mirror://sourceforge/${PN}/${P}.zip"
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 ~ia64 ppc ppc64 x86 ~x86-fbsd"
IUSE="zlib"

COMMON_DEP="zlib? ( dev-java/jzlib:0 )"
RDEPEND=">=virtual/jdk-1.6
	${COMMON_DEP}"
DEPEND=">=virtual/jdk-1.6
	${COMMON_DEP}"

EANT_BUILD_TARGET="dist"
JAVA_ANT_REWRITE_CLASSPATH="true"

src_compile() {
	if use zlib; then
		EANT_EXTRA_ARGS="-Djzlib.available=true"
		EANT_GENTOO_CLASSPATH="jzlib"
	fi
	java-pkg-2_src_compile
}

src_install() {
	java-osgi_newjar dist/lib/jsch*.jar "com.jcraft.jsch" "JSch" \
		"com.jcraft.jsch, com.jcraft.jsch.jce;x-internal:=true, \
com.jcraft.jsch.jcraft;x-internal:=true"

	dodoc README ChangeLog || die
	use doc && java-pkg_dojavadoc javadoc
	use source && java-pkg_dosrc src/*
	use examples && java-pkg_doexamples examples
}
