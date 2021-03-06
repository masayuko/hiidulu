# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
JAVA_PKG_IUSE="doc source"

inherit java-pkg-2 java-ant-2

MY_P="${PN}-jdk16-${PV/./}"
DESCRIPTION="Java cryptography APIs"
HOMEPAGE="http://www.bouncycastle.org/java.html"
#SRC_URI="http://www.bouncycastle.org/download/${MY_P}.tar.gz"
SRC_URI="http://polydistortion.net/bc/download/${MY_P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86 ~x86-fbsd"

# The src_unpack find needs a new find
# https://bugs.gentoo.org/show_bug.cgi?id=182276
COMMON_DEP="~dev-java/bcprov-${PV}
	~dev-java/bcmail-${PV}"
DEPEND=">=virtual/jdk-1.6
	${COMMON_DEP}
	userland_GNU? ( >=sys-apps/findutils-4.3 )
	app-arch/unzip"
RDEPEND=">=virtual/jre-1.6
	${COMMON_DEP}"

IUSE="userland_GNU"

S="${WORKDIR}/${MY_P}"

src_unpack() {
	unpack ${A}
	cd "${S}"
	mkdir -p src/main/java
	unzip -qq ./src.zip -d src/main/java
}

java_prepare() {
	# so that we don't need junit
	echo "Removing testcases' sources:"
	find . -path '*test/*.java' -print -delete \
		|| die "Failed to delete testcases."
	find . -name '*Test*.java' -print -delete \
		|| die "Failed to delete testcases."

	cp "${FILESDIR}/gentoo-build.xml" build.xml

	mkdir lib
	cd lib
	java-pkg_jar-from bcprov
	java-pkg_jar-from bcmail
}

JAVA_ANT_ENCODING="iso-8859-1"
EANT_EXTRA_ARGS="-Dproject.name=${PN}"

src_install() {
	java-pkg_dojar target/${PN}.jar

	use doc && java-pkg_dojavadoc target/site/apidocs
	use source && java-pkg_dosrc src/main/java/*
}
