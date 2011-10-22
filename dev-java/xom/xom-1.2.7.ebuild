# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

JAVA_PKG_IUSE="doc source"

inherit java-pkg-2 java-ant-2

DESCRIPTION="XOM is a new XML object model. It is a tree-based API for processing XML with Java that strives for correctness and simplicity."
HOMEPAGE="http://www.xom.nu/"
SRC_URI="http://www.cafeconleche.org/XOM/${PN}-${PV}-src.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc ~ppc64 ~x86 ~x86-fbsd"
IUSE=""

CDEPEND="dev-java/xerces:2"
RDEPEND=">=virtual/jre-1.5
	${CDEPEND}"
DEPEND=">=virtual/jdk-1.5
	dev-java/jaxen:1.1
	dev-java/jarjar:1
	${CDEPEND}
	doc? ( dev-java/tagsoup )"
#	servlet? ( java-virtuals/servlet-api:3.0 )

S="${WORKDIR}/XOM"

java_prepare() {
	epatch ${FILESDIR}/${P}-gentoo.patch

	# remove dependency junit
	rm -rv ${S}/src/nu/xom/tests
	rm -rv ${S}/src/nu/xom/samples/inner

	cd ${S}/lib
	rm -v *.jar
	java-pkg_jar-from --build-only jarjar-1 jarjar-nodep.jar jarjar.jar
	java-pkg_jar-from --build-only jaxen-1.1
	java-pkg_jar-from xerces-2

	#if use servlet; then
	#	mkdir -p ${S}/lib2
	#	cd ${S}/lib2
	#	java-pkg_jar-from --build-only --virtual servlet-api-3.0 servlet-api.jar servlet.jar
	#fi
}

src_compile() {
	local antflags="jar -Ddebug=off"
	if use doc; then
		antflags="${antflags} betterdoc -Dtagsoup.jar=$(java-pkg_getjar --build-only tagsoup tagsoup.jar)"
	fi
	eant ${antflags} || die "Failed Compiling"
}

src_install() {
	java-pkg_newjar build/${PN}.jar
	dodoc Todo.txt

	use doc && java-pkg_dohtml -r apidocs/
	use source && java-pkg_dosrc src/*
}
