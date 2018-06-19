#!/bin/sh

set -e

timedatectl set-ntp true

parted -s /dev/sda mklabel gpt
parted -s -a optimal /dev/sda mkpart ESP fat32 1MiB 551MiB
parted -s /dev/sda set 1 esp on
parted -s -a optimal /dev/sda mkpart boot ext4 551MiB 651MiB
parted -s -a optimal /dev/sda mkpart primary ext4 651MiB 100%

mkfs.vfat -F 32 /dev/sda1
mkfs.ext4 -F -L boot /dev/sda2

cryptsetup -y -v luksFormat --type luks2 /dev/sda3
cryptsetup open /dev/sda3 cryptroot
mkfs.xfs -f -L rootfs /dev/mapper/cryptroot
mount /dev/mapper/cryptroot /mnt

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
  nss-mdns

genfstab -U /mnt >>/mnt/etc/fstab

cp arch-install-chroot.sh /mnt

arch-chroot /mnt ./arch-install-chroot.sh

rm /mnt/arch-install-chroot.sh
umount -R /mnt
systemctl reboot
