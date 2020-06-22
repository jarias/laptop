#!/bin/sh

set -e

ROOT_DEVICE=/dev/nvme0n1
ESP_PARTITION=${ROOT_DEVICE}p1
BOOT_PARTITION=${ROOT_DEVICE}p2
ROOT_PARTITION=${ROOT_DEVICE}p3

timedatectl set-ntp true

parted -s $ROOT_DEVICE mklabel gpt
parted -s -a optimal $ROOT_DEVICE mkpart ESP fat32 1MiB 551MiB
parted -s $ROOT_DEVICE set 1 esp on
parted -s -a optimal $ROOT_DEVICE mkpart boot ext4 551MiB 651MiB
parted -s -a optimal $ROOT_DEVICE mkpart primary ext4 651MiB 100%

mkfs.vfat -F 32 -n esp $ESP_PARTITION
mkfs.ext4 -F -L boot $BOOT_PARTITION

cryptsetup -y -v luksFormat --type luks2 $ROOT_PARTITION
cryptsetup open $ROOT_PARTITION cryptroot
mkfs.xfs -f -L rootfs /dev/mapper/cryptroot
mount /dev/mapper/cryptroot /mnt

mkdir /mnt/boot
mount $BOOT_PARTITION /mnt/boot

mkdir /mnt/boot/EFI
mount $ESP_PARTITION /mnt/boot/EFI

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

sed -i "s@GRUB_CMDLINE_LINUX=.*@GRUB_CMDLINE_LINUX=\"cryptdevice=${ROOT_PARTITION}:cryptroot\"@g" /mnt/etc/default/grub

cp arch-install-chroot.sh /mnt

arch-chroot /mnt ./arch-install-chroot.sh

rm /mnt/arch-install-chroot.sh
umount -R /mnt
systemctl reboot
