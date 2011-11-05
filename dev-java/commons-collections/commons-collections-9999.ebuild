# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
JAVA_PKG_IUSE="doc source test"

ESVN_REPO_URI="https://svn.apache.org/repos/asf/commons/proper/collections/trunk"

inherit subversion java-pkg-2 java-ant-2 eutils

DESCRIPTION="Jakarta-Commons Collections Component"
HOMEPAGE="http://commons.apache.org/collections/"
SRC_URI=""

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc ~ppc64 ~x86 ~x86-fbsd"
IUSE="test-framework"

COMMON_DEP="test-framework? ( dev-java/junit:0 )"
DEPEND=">=virtual/jdk-1.5
	test? ( dev-java/ant-junit:0 )
	${COMMON_DEP}"
RDEPEND=">=virtual/jre-1.5
	${COMMON_DEP}"

JAVA_ANT_ENCODING="iso-8859-1"

src_compile() {
	local antflags
	if use test-framework; then
		antflags="tf.jar -Djunit.jar=$(java-pkg_getjars junit)"
		#no support for installing two sets of javadocs via dojavadoc atm
		#use doc && antflags="${antflags} tf.javadoc"
	fi
	eant jar $(use_doc) ${antflags}
}

src_test() {
	if [[ "${ARCH}" = "ppc" ]]; then
		einfo "Tests are disabled on ppc"
	else
		ANT_TASKS="ant-junit" eant testjar -Djunit.jar="$(java-pkg_getjars junit)"
	fi
}

src_install() {
	java-pkg_newjar build/${PN}*.jar ${PN}.jar
	use test-framework && \
		java-pkg_newjar build/${PN}-testframework*.jar \
			${PN}-testframework.jar

	dodoc README.txt || die
	java-pkg_dohtml *.html || die
	if use doc; then
		java-pkg_dojavadoc build/docs/apidocs
		#use test-framework && java-pkg_dojavadoc build/docs/testframework
	fi
	use source && java-pkg_dosrc src/java/*
}