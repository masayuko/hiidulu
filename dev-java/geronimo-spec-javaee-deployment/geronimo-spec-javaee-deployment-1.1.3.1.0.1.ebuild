# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

JAVA_PKG_IUSE="source doc"
inherit java-pkg-2 java-ant-2

DESCRIPTION="Apache's Geronimo implementation of J2EE specification (JSR88MR3)"
HOMEPAGE="http://geronimo.apache.org"
MY_TARBALL="geronimo-spec-javaee-deployment-1.1.3.1.0.1.tar.bz2"
SRC_URI="http://osdn.jp/frs/chamber_redir.php?m=iij&f=%2Fusers%2F9%2F9535%2F${MY_TARBALL} -> ${MY_TARBALL}"
# svn export https://svn.apache.org/repos/asf/geronimo/specs/tags/geronimo-javaee-deployment_1.1MR3_spec-1.0.1 geronimo-spec-javaee-deployment-1.1.3.1.0.1
# tar jcf geronimo-spec-javaee-deployment-1.1.3.1.0.1.tar.bz2 geronimo-spec-javaee-deployment-1.1.3.1.0.1

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND=">=virtual/jdk-1.6"
RDEPEND=">=virtual/jre-1.6"

java_prepare() {
	cp "${FILESDIR}/gentoo-build.xml" build.xml
}

EANT_EXTRA_ARGS="-Dproject.name=${PN}"

src_install() {
	java-pkg_dojar target/${PN}.jar

	use doc && java-pkg_dojavadoc target/site/apidocs
	use source && java-pkg_dosrc src/main/java/*
}
