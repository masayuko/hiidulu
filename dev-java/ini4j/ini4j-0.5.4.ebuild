# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5
JAVA_PKG_IUSE="doc source"

inherit java-pkg-2 java-ant-2

DESCRIPTION="Simple Java API Windows style .ini file handling"
HOMEPAGE="http://ini4j.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}-src.zip"

LICENSE="Apache-2.0"
SLOT="0.5"
KEYWORDS="~amd64 ~x86"

IUSE=""

RDEPEND=">=virtual/jre-1.6"
# Preferences api is broken in 1.6 if a later xalan version is in cp
# http://bugs.sun.com/bugdatabase/view_bug.do?bug_id=6519088
DEPEND=">=virtual/jdk-1.6
	java-virtuals/servlet-api:3.0
	${COMMON_DEP}"

JAVA_ANT_ENCODING="utf-8"

java_prepare() {
	epatch "${FILESDIR}/java8-map.patch"

	cp ${FILESDIR}/build.xml ${S}
	mkdir -p ${S}/lib || die
	java-pkg_jar-from --build-only --into lib --virtual servlet-api-3.0 servlet-api.jar
}

EANT_EXTRA_ARGS="-Dproject.name=${PN}"

src_install() {
	java-pkg_dojar dist/${PN}.jar
	use doc && java-pkg_dojavadoc dist/doc/api
	use source && java-pkg_dosrc src/main/java/org
}
