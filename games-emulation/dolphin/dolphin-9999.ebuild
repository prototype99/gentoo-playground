# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

PLOCALES="ar ca cs da_DK de el en es fa fr hr hu it ja ko ms_MY nb nl pl pt_BR pt ro_RO ru sr sv tr zh_CN zh_TW"
PLOCALE_BACKUP="en"
#WX_GTK_VER="3.1"

inherit cmake-utils eutils l10n pax-utils toolchain-funcs versionator wxwidgets

if [[ ${PV} == 9999* ]]
then
	EGIT_REPO_URI="https://github.com/${PN}-emu/${PN}.git"
	inherit git-r3
	KEYWORDS=""
else
	SRC_URI="https://github.com/${PN}-emu/${PN}/archive/${PV}.zip -> ${P}.zip"
	KEYWORDS="~amd64"
fi

DESCRIPTION="Gamecube and Wii game emulator"
HOMEPAGE="https://www.dolphin-emu.org/"

LICENSE="GPL-2"
SLOT="0"
IUSE="alsa ao bluetooth doc egl +evdev ffmpeg llvm log lto openal +pch portaudio profile pulseaudio qt5 sdl upnp +wxwidgets"

RDEPEND=">=media-libs/libsfml-2.1
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
	alsa? ( media-libs/alsa-lib )
	ao? ( media-libs/libao )
	bluetooth? ( net-wireless/bluez )
	egl? ( media-libs/mesa[egl] )
	evdev? (
			dev-libs/libevdev
			virtual/udev
	)
	ffmpeg? ( virtual/ffmpeg )
	llvm? ( sys-devel/llvm )
	openal? (
			media-libs/openal
			media-libs/libsoundtouch
	)
	portaudio? ( media-libs/portaudio )
	profile? ( dev-util/oprofile )
	pulseaudio? ( media-sound/pulseaudio )
	qt5? (
		dev-qt/qtcore:5
		dev-qt/qtgui:5
		dev-qt/qtwidgets:5
	)
	sdl? ( media-libs/libsdl2[haptic,joystick] )
	upnp? ( >=net-libs/miniupnpc-1.7 )
	dev-perl/X11-Protocol
	"
#	wxwidgets? (
#				dev-libs/glib:2
#				x11-libs/gtk+:2
#				x11-libs/wxGTK:${WX_GTK_VER}[opengl,X]
#	)
DEPEND="${RDEPEND}
	>=dev-util/cmake-2.8.8
	>=sys-devel/gcc-4.9.0
	dev-cpp/gtest
	app-arch/zip
	media-libs/freetype
	sys-devel/gettext
	virtual/pkgconfig
	"

pkg_pretend() {

	local ver=4.9.0
	local msg="${PN} needs at least GCC ${ver} set to compile."

	if [[ ${MERGE_TYPE} != binary ]]; then
		if ! version_is_at_least ${ver} $(gcc-fullversion); then
			eerror ${msg}
			die ${msg}
		fi
	fi

}

src_prepare() {
	default

	epatch "${FILESDIR}/${P}-retry-open-channels.patch"
	epatch "${FILESDIR}/${P}-microphone.patch"
	epatch "${FILESDIR}/${P}-functional.patch"
	epatch "${FILESDIR}/${P}-wx-contrast-text.patch"

	sed -i -e 's/missing-variable-declarations/missing-declarations/g' CMakeLists.txt || die


	# Remove automatic dependencies to prevent building without flags enabled.
	if use !alsa; then
		sed -i -e '/include(FindALSA/d' CMakeLists.txt || die
	fi
	if use !ao; then
		sed -i -e '/check_lib(AO/d' CMakeLists.txt || die
	fi
	if use !bluetooth; then
		sed -i -e '/check_lib(BLUEZ/d' CMakeLists.txt || die
	fi
	if use !llvm; then
		sed -i -e '/include(FindLLVM/d' CMakeLists.txt || die
	fi
	if use !openal; then
		sed -i -e '/include(FindOpenAL/d' CMakeLists.txt || die
	fi
	if use !pulseaudio; then
		sed -i -e '/check_lib(PULSEAUDIO/d' CMakeLists.txt || die
	fi

	# Remove ALL the bundled libraries, aside from:
	# - SOIL: The sources are not public.
	# - Bochs-disasm: Don't know what it is.
	# - gtest: Their build set up solely relies on the build in gtest.
	# - xxhash: Not on the tree.
	mv Externals/SOIL . || die
	mv Externals/Bochs_disasm . || die
	mv Externals/gtest . || die
	mv Externals/xxhash . || die
	mv Externals/wxWidgets3 . || die
	mv Externals/glslang . || die
	mv Externals/Vulkan . || die
	mv Externals/hidapi . || die
	rm -r Externals/* || die "Failed to delete Externals dir."
	mv Bochs_disasm Externals || die
	mv SOIL Externals || die
	mv gtest Externals || die
	mv xxhash Externals || die
	mv wxWidgets3 Externals || die
	mv glslang Externals || die
	mv Vulkan Externals || die
	mv hidapi Externals || die

	remove_locale() {
		# Ensure preservation of the backup locale when no valid LINGUA is set
		if [[ "${PLOCALE_BACKUP}" == "${1}" ]] && [[ "${PLOCALE_BACKUP}" == "$(l10n_get_locales)" ]]; then
			return
		else
			rm "Languages/po/${1}.po" || die
		fi
	}

	l10n_find_plocales_changes "Languages/po/" "" '.po'
	l10n_for_each_disabled_locale_do remove_locale
}

src_configure() {

#	if use wxwidgets; then
#		need-wxwidgets unicode
#	fi

	local mycmakeargs=(
		"-DUSE_SHARED_ENET=ON"
		-DENCODE_FRAMEDUMPS="$(usex ffmpeg)"
		-DFASTLOG="$(usex log)"
		-DOPROFILING="$(usex profile)"
		-DDISABLE_WX="$(usex wxwidgets OFF ON)"
		-DENABLE_EVDEV="$(usex evdev)"
		-DENABLE_LTO="$(usex lto)"
		-DENABLE_PCH="$(usex pch)"
		-DENABLE_QT2="$(usex qt5)"
		-DENABLE_SDL="$(usex sdl)"
		-DUSE_EGL="$(usex egl)"
		-DUSE_UPNP="$(usex upnp)"
		-DENABLE_MICROPHONE="$(usex portaudio)"
	)

	cmake-utils_src_configure
}

src_compile() {

	cmake-utils_src_compile
}
src_install() {

	cmake-utils_src_install

	dodoc Readme.md
	if use doc; then
		dodoc -r docs/ActionReplay docs/DSP docs/WiiMote
	fi

	doicon -s 48 Data/dolphin-emu.png
	doicon -s scalable Data/dolphin-emu.svg
	doicon Data/dolphin-emu.svg
}

pkg_postinst() {
	# Add pax markings for hardened systems
	pax-mark -m "${EPREFIX}"/usr/games/bin/"${PN}"-emu

	if ! use portaudio; then
		ewarn "If you want microphone capabilities in dolphin-emu, rebuild with"
		ewarn "USE=\"portaudio\""
	fi
}
