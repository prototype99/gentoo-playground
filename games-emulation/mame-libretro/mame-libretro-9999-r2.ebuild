# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit libretro-core

DESCRIPTION="libretro implementation of MAME 2015. (Arcade)"
HOMEPAGE="https://github.com/libretro/mame"
SRC_URI=""

PATCHES=( "${FILESDIR}/genie-version-null-check.patch" )

if [[ ${PV} == 9999 ]]; then
	EGIT_REPO_URI="https://github.com/libretro/mame.git"
	KEYWORDS=""
else
	KEYWORDS="amd64 x86"
fi

LICENSE="MAME-GPL"
SLOT="0"

RDEPEND=""
DEPEND="${RDEPEND}"

src_prepare() {
	default
	epatch "${FILESDIR}/genie-version-null-check.patch"
}

src_compile() {
	emake -f Makefile.libretro || die "emake failed"
}

src_install() {
	insinto ${LIBRETRO_DATA_DIR}/mame_libretro
	doins "${S}"/docs/LICENSE
	libretro-core_src_install
}
