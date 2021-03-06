# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

JAVA_PKG_IUSE="doc source"

inherit java-pkg-2 java-ant-2

MY_P="slf4j-${PV}"
DESCRIPTION="The Simple Logging Facade for Java"
HOMEPAGE="http://www.slf4j.org/"
SRC_URI="http://www.slf4j.org/dist/${MY_P}.tar.gz"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

COMMON_DEP="~dev-java/slf4j-api-${PV}
	dev-java/commons-logging"
DEPEND=">=virtual/jdk-1.6
	${COMMON_DEP}"
RDEPEND=">=virtual/jre-1.6
	${COMMON_DEP}"

S="${WORKDIR}/${MY_P}/${PN}"

java_prepare() {
	cp ${FILESDIR}/gentoo-build.xml build.xml

	mkdir ${S}/lib || die
	cd ${S}/lib
	java-pkg_jar-from slf4j-api
	java-pkg_jar-from commons-logging
}

JAVA_ANT_ENCODING="iso-8859-1"
EANT_EXTRA_ARGS="-Dproject.name=${PN}"

src_install() {
	java-pkg_dojar target/${PN}.jar

	use doc && java-pkg_dojavadoc target/site/apidocs
	use source && java-pkg_dosrc src/main/java/*
}
