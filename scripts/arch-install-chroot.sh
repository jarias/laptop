#!/bin/sh

set -e

USERNAME=jarias
USER_FULLNAME="Julio Arias"
HOSTNAME=gildarts

ln -sf /usr/share/zoneinfo/America/Costa_Rica /etc/localtime

hwclock --systohc

echo en_US.UTF-8 UTF-8 >/etc/locale.gen
echo LANG=en_US.UTF-8 >/etc/locale.conf
locale-gen

echo "${HOSTNAME}" >/etc/hostname

cat <<EOF >/etc/hosts
127.0.0.1 localhost
::1       localhost
127.0.1.1 ${HOSTNAME}
EOF

cat <<EOF >/etc/vconsole.conf
FONT=ter-132n
EOF

cat <<EOF >/etc/mkinitcpio.conf
# vim:set ft=sh

MODULES=(i915)

BINARIES=()

FILES=()

HOOKS=(base udev autodetect keyboard keymap consolefont modconf block encrypt filesystems fsck)
EOF

systemctl enable sshd.service
systemctl enable ntpd.service
systemctl enable NetworkManager.service

mkinitcpio -p linux

grub-install --target=x86_64-efi --efi-directory=/boot/EFI --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

echo 'root ALL=(ALL) ALL' >/etc/sudoers
echo '%wheel ALL=(ALL) ALL' >>/etc/sudoers
echo '#includedir /etc/sudoers.d' >>/etc/sudoers

#default password 123
useradd -c "$USER_FULLNAME" \
  -m \
  -s /bin/bash \
  -G wheel \
  -p '$6$rounds=4096$zLFpzBXFusR1$ckEnstIQ3inB3USRuyQ2zJIMUiYqVQRbeNVFYGbec.iQ9Jl8fKbQkwk27fIhJytnJ3qXW21PVLNn.gm9wCNGV1' \
  $USERNAME
