#!/bin/sh

set -e

timedatectl set-ntp true

parted -s /dev/nvme0n1 mklabel gpt
parted -s -a optimal /dev/nvme0n1 mkpart ESP fat32 1MiB 551MiB
parted -s /dev/nvme0n1 set 1 esp on
parted -s -a optimal /dev/nvme0n1 mkpart boot ext4 551MiB 651MiB
parted -s -a optimal /dev/nvme0n1 mkpart primary ext4 651MiB 100%

mkfs.vfat -F 32 /dev/nvme0n1p1
mkfs.ext4 -F -L boot /dev/nvme0n1p2

cryptsetup -y -v luksFormat --type luks2 /dev/nvme0n1p3
cryptsetup open /dev/nvme0n1p3 cryptroot
mkfs.xfs -f -L rootfs /dev/mapper/cryptroot
mount /dev/mapper/cryptroot /mnt

mkdir /mnt/boot
mount /dev/nvme0n1p2 /mnt/boot

mkdir /mnt/boot/EFI
mount /dev/nvme0n1p1 /mnt/boot/EFI

pacstrap /mnt \
  base \
  base-devel \
  python \
  ansible \
  grub \
  efibootmgr \
  openssh \
  sudo \
  ntp \
  intel-ucode \
  lm_sensors \
  networkmanager \
  cups \
  fwupd \
  nfs-utils \
  nss-mdns \
  terminus-font \
  git

genfstab -U /mnt >>/mnt/etc/fstab

cp arch-install-chroot.sh /mnt

arch-chroot /mnt ./arch-install-chroot.sh

rm /mnt/arch-install-chroot.sh
umount -R /mnt
systemctl reboot
