# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
JAVA_PKG_IUSE="doc source"

inherit java-pkg-2 java-ant-2

DESCRIPTION="JHighlight is an embeddable pure Java syntax highlighting library"
HOMEPAGE="http://rifers.org/blogs/gbevin/2006/3/13/jhighlight_1_0_released"
MY_TARBALL="jhighlight-1.0.tar.bz2"
SRC_URI="http://osdn.jp/frs/chamber_redir.php?m=iij&f=%2Fusers%2F9%2F9544%2F${MY_TARBALL}"
#SRC_URI="https://jhighlight.dev.java.net/files/documents/3366/30845/${P}-src.zip"
#HOMEPAGE="https://jhighlight.dev.java.net/"
LICENSE="CDDL"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND=">=virtual/jre-1.6"
DEPEND=">=virtual/jdk-1.6
	java-virtuals/servlet-api:3.0"
#	dev-java/jflex"

#S="${WORKDIR}/${P}-src"

src_prepare() {
	#rm -fv ${S}/lib/*.jar
	mkdir ${S}/lib || die
	#java-pkg_jar-from --into lib --build-only jflex
	java-pkg_jar-from --into lib --build-only --virtual servlet-api-3.0 servlet-api.jar
}

EANT_EXTRA_ARGS="-Dproject.name=${PN}"
#EANT_DOC_TARGET="javadocs"

src_install() {
	#java-pkg_newjar build/dist/${P}.jar ${PN}.jar
	java-pkg_dojar target/${PN}.jar

	java-pkg_dolauncher jhighlight --main "com.uwyn.jhighlight.JHighlight"

	#use doc && java-pkg_dojavadoc build/javadocs/${PN}-javadocs-${PV}/docs/api
	#use source && java-pkg_dosrc src/com
	use doc && java-pkg_dojavadoc target/site/apidocs
	use source && java-pkg_dosrc src/main/java/*
}
