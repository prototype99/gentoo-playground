# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/tuned/tuned-2.4.1.ebuild,v 1.1 2014/10/19 14:20:17 dlan Exp $

EAPI=5

PYTHON_COMPAT=( python2_7 )

inherit python-single-r1 systemd

DESCRIPTION="Daemon for monitoring and adaptive tuning of system devices"
HOMEPAGE="http://www.tuned-project.org/"
if [ ${PV} == 9999 ]; then
	inherit git-r3
	EGIT_REPO_URI=https://github.com/redhat-performance/tuned.git
else
	SRC_URI="https://github.com/redhat-performance/tuned/archive/v${PV}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi
LICENSE="GPL-2"
SLOT="0"
IUSE=""

COMMON_DEPEND="${PYTHON_DEPS}
	dev-python/configobj[${PYTHON_USEDEP}]
	dev-python/decorator[${PYTHON_USEDEP}]
	dev-python/pyudev[${PYTHON_USEDEP}]
"
DEPEND="${COMMON_DEPEND}"
RDEPEND="${COMMON_DEPEND}
	sys-power/powertop
	dev-util/systemtap
"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

src_prepare() {
	sed -i \
		-e "/^UNITDIR = /s:\(.* = \).*:\1$(systemd_get_unitdir):" \
		-e "/^TMPFILESDIR = /s:\(.* = \).*:\1/usr/lib/tmpfiles.d:" \
		-e "/\$(DESTDIR)\/run\/tuned/d" \
		Makefile ||die
}

src_install() {
	# workaround
	[[ -f modules.conf ]] || touch modules.conf

	default
	newinitd "${FILESDIR}"/tuned.initd  tuned

	python_fix_shebang "${ED}"
}
