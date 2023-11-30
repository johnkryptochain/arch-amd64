#!/bin/busybox sh
set -x

JEMAOS_ROOT="/openjema"
BOOT="/boot"
JEMAOS_KERNEL="${BOOT}/vmlinuz"
JEMAOS_KERNEL_A="openjema_vmlinuzA"
JEMAOS_KERNEL_B="openjema_vmlinuzB"
JEMAOS_IMG="${JEMAOS_ROOT}/openjema_dual_boot.img"
ROOT_MNT="${JEMAOS_ROOT}/root"
# The maximum length of fs label is 16
DUAL_BOOT_LABEL="OJEMA-DUAL-BOOT"

create_dir() {
  if [ ! -d $1 ]; then
    mkdir -p $1
  fi
}

get_boot_dev() {
  local loopdev=$1
  local RootA="${loopdev}p3"
  local RootB="${loopdev}p5"
  local prioA=$(cgpt show -i2 -P $loopdev)
  local prioB=$(cgpt show -i4 -P $loopdev)
  if [ $prioA -lt $prioB ]; then
    echo $RootB
  else
    echo $RootA
  fi
}

get_dualboot_dev() {
  cgpt find -l ${DUAL_BOOT_LABEL}
}

mount_dualboot_partiton() {
  local root=$1
  local dualboot_dev=$(get_dualboot_dev)
  mount $dualboot_dev $root
}

mount_image() {
  local root="$1"
  mount_dualboot_partiton $root
  local img=$(ls ${root}${JEMAOS_IMG})
  local loopdev=$(losetup -f)
  losetup $loopdev $img > /dev/null 2>&1
  partx -a $loopdev > /dev/null 2>&1
  local bootdev=$(get_boot_dev  $loopdev)
  ROOT_MNT="${root}${ROOT_MNT}"
  create_dir $ROOT_MNT
  mount -o,ro $bootdev $ROOT_MNT > /dev/null 2>&1
  echo $ROOT_MNT
}

get_release_version_from_lsb() {
	local loop_root=$1
    local ver=$(grep CHROMEOS_RELEASE_VERSION ${loop_root}/etc/lsb-release)
    echo ${ver#*=}
}

get_release_version_from_kernel() {
	local origin_root=$1
	local kernel=$(readlink "${origin_root}/boot/${JEMAOS_KERNEL_A}")
	echo ${kernel#*-}
}

update_kernel() {
	local origin_root=$1
	local loop_root=$2
	local source="${loop_root}${JEMAOS_KERNEL}"
  local version="$(get_release_version_from_lsb ${loop_root})"
	local target="${origin_root}${JEMAOS_KERNEL}-${version}"
	cp -f $source $target
	cd ${origin_root}${BOOT}
	local second_kernel="$(readlink ${JEMAOS_KERNEL_A})"
  local old_kernel="$(readlink ${JEMAOS_KERNEL_B})"
	ln -s -f $second_kernel $JEMAOS_KERNEL_B
	ln -s -f $(basename $target) $JEMAOS_KERNEL_A
  if [ "${old_kernel}" != "${second_kernel}" ]; then
      rm -f ${old_kernel}
  fi
  cd -
}
