#JemaOS 2020-08-24 Author: John
defaultA=0
defaultB=1
set img=/jemaos/jemaos_dual_boot.img
search --label --set root JEMAOS-DUAL-BOOT
loopback loopdev $img
gptpriority loopdev 2 prioA
gptpriority loopdev 4 prioB
if [ $prioA -lt $prioB ]; then
  set default=$defaultB
else
  set default=$defaultA
fi

set timeout=1

# NOTE: find rootfs by label (not partion label)

menuentry "JemaOS multi-boot A" {
  linux (loopdev,gpt12)/syslinux/vmlinuz.A init=/sbin/init root=%ROOTDEV% boot=local rootwait noresume noswap ro loglevel=7 console= i915.modeset=1 cros_efi cros_debug  jemaos_dualboot %EXTRA_FLAG%
  initrd /boot/dual_boot_ramfs.cpio
}

menuentry "JemaOS multi-boot B" {
  linux (loopdev,gpt12)/syslinux/vmlinuz.B init=/sbin/init root=%ROOTDEV% boot=local rootwait noresume noswap ro loglevel=7 console= i915.modeset=1 cros_efi cros_debug  jemaos_dualboot %EXTRA_FLAG%
  initrd /boot/dual_boot_ramfs.cpio
}

menuentry "JemaOS Recovery Tools" {
  linux /boot/jemaos_vmlinuzB init=/sbin/init root=%ROOTDEV% boot=local rootwait noresume noswap ro loglevel=7 console= i915.modeset=1 cros_efi cros_debug %EXTRA_FLAG%
  initrd /boot/core_util_ramfs.cpio
}
