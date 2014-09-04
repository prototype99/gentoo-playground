# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-crypt/gcr/gcr-3.12.2.ebuild,v 1.8 2014/08/25 10:56:28 ago Exp $

EAPI="5"
GCONF_DEBUG="no"
VALA_MIN_API_VERSION="0.20"
VALA_USE_DEPEND="vapigen"
PYTHON_COMPAT=( python2_7 )

inherit gnome2 python-any-r1 vala virtualx

DESCRIPTION="Libraries for cryptographic UIs and accessing PKCS#11 modules"
HOMEPAGE="https://developer.gnome.org/gcr/"

LICENSE="GPL-2+ LGPL-2+"
SLOT="0/1" # subslot = suffix of libgcr-3
IUSE="debug gtk +introspection vala"
REQUIRED_USE="vala? ( introspection )"
KEYWORDS="alpha amd64 ~arm ia64 ~mips ppc ppc64 ~sh ~sparc x86 ~amd64-fbsd ~x86-fbsd ~amd64-linux ~arm-linux ~x86-linux ~sparc-solaris ~x86-solaris"

COMMON_DEPEND="
	>=app-crypt/gnupg-2
	>=app-crypt/p11-kit-0.19
	>=dev-libs/glib-2.34:2
	>=dev-libs/libgcrypt-1.2.2:0=
	>=dev-libs/libtasn1-1:=
	>=sys-apps/dbus-1
	gtk? ( >=x11-libs/gtk+-3:3[introspection?] )
	introspection? ( >=dev-libs/gobject-introspection-1.34 )
"
RDEPEND="${COMMON_DEPEND}
	!<gnome-base/gnome-keyring-3.3
"
# gcr was part of gnome-keyring until 3.3
DEPEND="${COMMON_DEPEND}
	${PYTHON_DEPS}
	dev-libs/gobject-introspection-common
	dev-libs/libxslt
	dev-util/gdbus-codegen
	>=dev-util/gtk-doc-am-1.9
	>=dev-util/intltool-0.35
	sys-devel/gettext
	virtual/pkgconfig
	vala? ( $(vala_depend) )
"
# eautoreconf needs:
#	dev-libs/gobject-introspection-common

pkg_setup() {
	python-any-r1_pkg_setup
}

src_prepare() {
	# Disable stupid flag changes
	sed -e 's/CFLAGS="$CFLAGS -g"//' \
		-e 's/CFLAGS="$CFLAGS -O0"//' \
		-i configure.ac configure || die

	use vala && vala_src_prepare
	gnome2_src_prepare
}

src_configure() {
	DOCS="AUTHORS ChangeLog HACKING NEWS README"
	gnome2_src_configure \
		$(use_with gtk) \
		$(use_enable introspection) \
		$(use_enable vala) \
		$(usex debug --enable-debug=yes --enable-debug=default) \
		--disable-update-icon-cache \
		--disable-update-mime
}

src_test() {
	unset DBUS_SESSION_BUS_ADDRESS
	Xemake check
}
