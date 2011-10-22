# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
JAVA_PKG_IUSE="doc source"

inherit java-pkg-2 java-ant-2

DESCRIPTION="A text-processing Java classes that serialize objects to XML and back again."
HOMEPAGE="http://xstream.codehaus.org/index.html"
SRC_URI="https://nexus.codehaus.org/content/repositories/releases/com/thoughtworks/${PN}/${PN}-distribution/${PV}/${PN}-distribution-${PV}-src.zip"
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE=""

COMMON_DEPS="
	dev-java/cglib-nodep:2.2
	dev-java/dom4j:1
	dev-java/jdom:1.0
	dev-java/kxml:2
	dev-java/joda-time:0
	dev-java/xom:0
	dev-java/xpp3:0
	dev-java/xml-commons-external:1.4
	dev-java/jettison:0
	dev-java/stax
	java-virtuals/stax-api"
#	test? (
#		dev-java/junit:0
#		dev-java/xml-writer:0
#		dev-java/commons-lang:2.1
#		dev-java/jmock:1.0
#		dev-java/jakarta-oro:2.0
#		dev-java/stax:0
#		dev-java/wstx:3.2
#	)"

DEPEND=">=virtual/jdk-1.5
	${COMMON_DEPS}"
RDEPEND=">=virtual/jre-1.5
	${COMMON_DEPS}"

S="${WORKDIR}/${P}/${PN}"

RESTRICT="test"

#JAVA_ANT_REWRITE_CLASSPATH="true"

java_prepare() {
	rm src/java/com/thoughtworks/xstream/converters/reflection/HarmonyReflectionProvider.java

	mkdir lib
	java-pkg_jar-from --into lib xpp3
	java-pkg_jar-from --into lib jdom-1.0
	java-pkg_jar-from --into lib kxml-2
	java-pkg_jar-from --into lib xom
	java-pkg_jar-from --into lib dom4j-1
	java-pkg_jar-from --into lib joda-time
	java-pkg_jar-from --into lib cglib-nodep-2.2
	java-pkg_jar-from --into lib xml-commons-external-1.4
	java-pkg_jar-from --into lib jettison
	java-pkg_jar-from --into lib stax
	java-pkg_jar-from --into lib --virtual stax-api

#	mkdir ${PN}-benchmark/lib
#	java-pkg_jar-from --into ${PN}-benchmark/lib xpp3
#	java-pkg_jar-from --into ${PN}-benchmark/lib jdom-1.0
#	java-pkg_jar-from --into ${PN}-benchmark/lib kxml-2
#	java-pkg_jar-from --into ${PN}-benchmark/lib xom
#	java-pkg_jar-from --into ${PN}-benchmark/lib dom4j-1
#	java-pkg_jar-from --into ${PN}-benchmark/lib joda-time
#	java-pkg_jar-from --into ${PN}-benchmark/lib cglib-nodep-2.2
#	java-pkg_jar-from --into ${PN}-benchmark/lib xml-commons-external-1.4
#	java-pkg_jar-from --into ${PN}-benchmark/lib jettison
#	java-pkg_jar-from --into ${PN}-benchmark/lib stax
#	java-pkg_jar-from --into ${PN}-benchmark/lib --virtual stax-api

	cp "${FILESDIR}/gentoo-build.xml" build.xml
#	cp "${FILESDIR}/gentoo-build.xml" ${PN}-benchmark/build.xml
}

EANT_EXTRA_ARGS="-Dproject.name=${PN}"

#src_compile() {
#	cd "${PN}"
#	EANT_EXTRA_ARGS="-Dproject.name=${PN}" java-pkg-2_src_compile
#	cd "${S}/${PN}-benchmark"
#	EANT_EXTRA_ARGS="-Dproject.name=${PN}-benchmark" java-pkg-2_src_compile
#}

#EANT_GENTOO_CLASSPATH="xpp3,jdom-1.0,xom,dom4j-1,joda-time,cglib-nodep-2.2
#xml-commons-external-1.4,jettison,stax-api"

#EANT_BUILD_TARGET="benchmark:compile jar"
#EANT_EXTRA_ARGS="-Dversion=${PV}"

#src_test(){
#	EANT_GENTOO_CLASSPATH="${EANT_GENTOO_CLASSPATH}
#		junit,jmock-1.0,commons-lang-2.1,xml-writer,wstx-3.2,stax,jakarta-oro-2.0" \
#		ANT_TASKS="ant-junit ant-trax" eant test || die "Tests failed"
#}

src_install(){
	java-pkg_newjar target/${PN}.jar
#	java-pkg_newjar target/${PN}-benchmark-${PV}.jar ${PN}-benchmark.jar

	use doc && java-pkg_dojavadoc target/javadoc
	use source && java-pkg_dosrc src/java/com
}
