# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5
JAVA_PKG_IUSE="doc source"

EGIT_REPO_URI="https://github.com/apache/commons-io.git"

inherit git-r3 java-pkg-2 java-pkg-simple

MY_P="${P}-src"
DESCRIPTION="Commons-IO contains utility classes, stream implementations, file filters, and endian classes."
HOMEPAGE="http://commons.apache.org/io/"
SRC_URI=""

LICENSE="Apache-2.0"
SLOT="1"
KEYWORDS="~amd64 ~ia64 ~ppc ~ppc64 ~x86 ~x86-fbsd"
IUSE=""

DEPEND=">=virtual/jdk-1.7"
RDEPEND=">=virtual/jre-1.7"

S="${WORKDIR}/${P}"

JAVA_SRC_DIR="src/main/java"
