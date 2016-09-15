# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit libretro-core

DESCRIPTION="libretro implementation of Dolphin. (Nintendo GC/Wii)"
HOMEPAGE="https://github.com/libretro/dolphin"
SRC_URI="https://github.com/libretro/dolphin/archive/8ae5c4469693db6eeef13b73ae361c98f06be1d0.tar.gz -> ${P}.tar.gz"
RESTRICT="primaryuri"

S="${WORKDIR}/dolphin-8ae5c4469693db6eeef13b73ae361c98f06be1d0"

if [[ ${PV} == 9999 ]]; then
	EGIT_REPO_URI="https://github.com/libretro/dolphin.git"
	KEYWORDS=""
else
	KEYWORDS="amd64 x86"
fi

LICENSE="GPL-2"
SLOT="0"

RDEPEND=""
DEPEND=">=media-libs/libsfml-2.1
	>net-libs/enet-1.3.7
	>=net-libs/mbedtls-2.1.1
	dev-libs/lzo
	media-libs/libpng:=
	sys-libs/glibc
	sys-libs/readline:=
	sys-libs/zlib
	x11-libs/libXext
	x11-libs/libXi
	x11-libs/libXrandr
	virtual/libusb:1
	virtual/opengl
	>=dev-util/cmake-2.8.8
	>=sys-devel/gcc-4.9.0
	app-arch/zip
	media-libs/freetype
	sys-devel/gettext
	virtual/pkgconfig
		${RDEPEND}"

S="${S}"/libretro

src_prepare() {
	pushd ..
	epatch_user
	popd

	#fixing ARCH detection
	sed -i Makefile \
		-e 's:$(ARCH):$(REAL_ARCH):' || die
	sed -i Makefile \
		-e 's:ARCH = $(shell uname -m):REAL_ARCH = $(shell uname -m):' || die
}
