# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

JAVA_PKG_IUSE="doc source"

WANT_ANT_TASKS="dev-java/saxon:9.3 dev-java/testng:0"

inherit java-pkg-2 java-ant-2

DESCRIPTION="Multi-format schema converter based on RELAX NG"
HOMEPAGE="http://thaiopensource.com/relaxng/jing.html"
SRC_URI="https://github.com/relaxng/jing-trang/archive/V${PV}.tar.gz -> jing-trang-${PV}.tar.gz"
LICENSE="BSD Apache-1.1"
SLOT="0"
KEYWORDS="amd64 ~ppc x86"
IUSE=""
COMMON_DEPEND="
	dev-java/xerces:2
	dev-java/xml-commons-resolver"
RDEPEND=">=virtual/jre-1.6
	${COMMON_DEPEND}"
DEPEND=">=virtual/jdk-1.6
	dev-java/xalan
	dev-java/iso-relax
	dev-java/saxon:9.3
	dev-java/ant-core
	dev-java/javacc
	${COMMON_DEPEND}"

JAVA_PKG_BSFIX="off"

S="${WORKDIR}/jing-trang-${PV}"

java_prepare() {
	find -type f -exec sed -i -e 's/com.icl.saxon/net.sf.saxon/g' {} \;

	rm -fv lib/*.jar
	cd lib
	java-pkg_jar-from iso-relax iso-relax.jar isorelax.jar
	java-pkg_jar-from xerces-2
	java-pkg_jar-from xalan xalan.jar
	java-pkg_jar-from saxon-9.3 saxon9.jar
	rm ${S}/mod/schematron/src/main/com/thaiopensource/validate/schematron/OldSaxonSchemaReaderFactory.java
	java-pkg_jar-from xml-commons-resolver xml-commons-resolver.jar resolver.jar
	java-pkg_jar-from --build-only ant-core
	java-pkg_jar-from --build-only javacc
}

src_compile() {
	eant modbuild
	java-ant_bsfix_one modbuild.xml
	java-pkg-2_src_compile
}

src_install() {
	#java-pkg_dojar build/jing.jar
	java-pkg_dojar build/trang.jar
	#java-pkg_dojar build/dtdinst.jar
	#java-pkg_register-ant-task
#	java-pkg_dolauncher ${PN}-${SLOT} --main com.thaiopensource.relaxng.util.Driver
	#java-pkg_dolauncher ${PN} --main com.thaiopensource.relaxng.util.Driver
	java-pkg_dolauncher ${PN} --main com.thaiopensource.relaxng.translate.Driver
	use doc && java-pkg_dohtml -r doc/* readme.html
	use source && java-pkg_dosrc src/com
}
