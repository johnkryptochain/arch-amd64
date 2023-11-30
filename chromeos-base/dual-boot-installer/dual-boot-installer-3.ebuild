# Copyright (c) 2023 Jema Innovations Limited and the openJema Authors.
# Distributed under the license specified in the root directory of this project.

EAPI=5
EGIT_REPO_URI="${OPENJEMA_GIT_HOST_URL}/jemaos-refind-theme.git"
EGIT_BRANCH="main"

inherit git-r3

DESCRIPTION="Script to configure JemaOS to boot alongside existing OS."
HOMEPAGE="https://jemakey.com"

SLOT="0"
KEYWORDS="amd64 x86"
IUSE="jemaos"
LICENSE="GPL-3"

RDEPEND="
	sys-apps/diffutils
	sys-apps/gptfdisk[-ncurses]
    sys-boot/efibootmgr
	sys-block/parted
"

DEPEND="
	${RDEPEND}
	chromeos-base/chromeos-initramfs
	chromeos-base/chromeos-installer
"
grub_args=(
    -c embedded.cfg
    part_gpt test fat ext2 hfs hfsplus normal boot chain loopback gptpriority
    efi_gop configfile linux search echo cat
  )

src_compile() {
  cat ${SYSROOT}/usr/sbin/chromeos-install | \
	   sed -e "s/\/sbin\/blockdev\ --rereadpt/partx\ -a/g" > \
	   chromeos-install.sh
  echo 'configfile $cmdpath/grub.cfg' > embedded.cfg

  if use jemaos; then
	 grub-mkimage -O x86_64-efi -o bootx64.efi -p "/efi/jemaos" "${grub_args[@]}"
  else
     grub-mkimage -O x86_64-efi -o bootx64.efi  -p "/efi/openjema" "${grub_args[@]}"
  fi
}

src_install() {
    local dual_dir=${FILESDIR}/dualboot
    insinto /usr/share/dualboot

    if use jemaos; then
       doins -r "${dual_dir}/jemaos"
    else
       doins -r "${dual_dir}/openjema"
    fi

    doins -r ${dual_dir}/refind

    doins ${dual_dir}/script/BOOT.CSV

    if use jemaos; then
       insinto /usr/share/dualboot/jemaos
    else
        insinto /usr/share/dualboot/openjema
    fi

    doins bootx64.efi

    exeinto /usr/share/dualboot
    doexe ${dual_dir}/script/*.sh
    doexe chromeos-install.sh

    insinto /usr/share/dualboot/initrd
    doins ${SYSROOT}/var/lib/initramfs/*.cpio

    insinto /usr/share/dualboot/refind/rEFInd-minimal
    doins -r icons
    doins *.png
    doins theme.conf
    doins LICENSE
}
