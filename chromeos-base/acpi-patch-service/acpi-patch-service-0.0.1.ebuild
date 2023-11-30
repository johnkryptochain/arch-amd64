# Copyright (c) 2023 Jema Innovations Limited and the openJema Authors.
# Distributed under the license specified in the root directory of this project.

EAPI="5"

DESCRIPTION="empty project"
HOMEPAGE="http://jemakey.com"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND=""

DEPEND="${RDEPEND}"

S=$WORKDIR

src_install() {
  insinto /etc/init
  doins ${FILESDIR}/acpi-patch-service.conf  
  exeinto //usr/share/jemaos_shell
  doexe ${FILESDIR}/patch_acpi.sh
}
