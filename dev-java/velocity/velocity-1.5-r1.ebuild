# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=1
JAVA_PKG_IUSE="examples doc source test"

inherit java-pkg-2 java-ant-2 eutils

DESCRIPTION="A Java-based template engine that allows easy creation/rendering of documents that format and present data."
HOMEPAGE="http://velocity.apache.org"
SRC_URI="mirror://apache/${PN}/engine/${PV}/${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE=""

CDEPEND="dev-java/commons-lang:2.1
	dev-java/commons-collections
	dev-java/jdom:1.0
	dev-java/log4j
	>=dev-java/jakarta-oro-2.0
	dev-java/tomcat-servlet-api:2.5
	dev-java/ant-core"
DEPEND=">=virtual/jdk-1.5
	test? (
		dev-java/ant-junit
		dev-java/ant-antlr
		dev-db/hsqldb
	)
	${CDEPEND}"
RDEPEND=">=virtual/jre-1.5
	${CDEPEND}"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch ${FILESDIR}/${P}-jaxen.patch
	rm src/java/org/apache/velocity/runtime/log/AvalonLogChute.java || die
	rm src/java/org/apache/velocity/runtime/log/AvalonLogSystem.java || die
	rm src/java/org/apache/velocity/runtime/log/VelocityFormatter.java || die

	rm -v *.jar lib/test/*.jar lib/*.jar || die

	mkdir -p bin/lib
	cd bin/lib || die

	java-pkg_jar-from commons-lang-2.1
	java-pkg_jar-from tomcat-servlet-api-2.5 servlet-api.jar
	java-pkg_jar-from jdom-1.0,log4j
	java-pkg_jar-from ant-core,commons-collections
	java-pkg_jar-from jakarta-oro-2.0
}

src_compile () {
	cd "${S}/build"
	eant jar -Dskip-download=true #prebuilt javadocs
}

src_test() {
	mkdir bin/test-lib -p || die
	cd bin/test-lib || die
	java-pkg_jar-from junit,hsqldb,tomcat-servlet-api-2.5
	cd "${S}/build"
	ANT_TASKS="ant-junit ant-antlr" eant test -Dskip-download=true
}

src_install () {
	java-pkg_newjar bin/*.jar

	dodoc NOTICE README.txt || die
	# has other stuff besides api too
	use doc && java-pkg_dohtml -r docs/*
	use examples && java-pkg_doexamples examples
	use source && java-pkg_dosrc src/java/*
}
