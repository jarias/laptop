#!/bin/sh

set -e

USERNAME=jarias
USER_FULLNAME=Julio Arias

ln -sf /usr/share/zoneinfo/America/Costa_Rica /etc/localtime

hwclock --systohc

echo en_US.UTF-8 UTF-8 >/etc/locale.gen
echo LANG=en_US.UTF-8 >/etc/locale.conf
locale-gen

echo "gildarts" >/etc/hostname

cat <<EOF >/etc/hosts
127.0.0.1 localhost
::1       localhost
127.0.1.1 gildarts
EOF

cat <<EOF >/etc/mkinitcpio.conf
# vim:set ft=sh

MODULES=()

BINARIES=()

FILES=()

HOOKS=(base udev autodetect keyboard keymap consolefont modconf block encrypt filesystems fsck)
EOF

cat <<EOF >/etc/default/grub
# GRUB boot loader configuration
GRUB_DEFAULT=0
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR="Arch"
GRUB_CMDLINE_LINUX_DEFAULT="quiet"
GRUB_CMDLINE_LINUX="cryptdevice=/dev/sda3:cryptroot"

# Preload both GPT and MBR modules so that they are not missed
GRUB_PRELOAD_MODULES="part_gpt part_msdos"

# Uncomment to enable booting from LUKS encrypted devices
#GRUB_ENABLE_CRYPTODISK=y

# Uncomment to enable Hidden Menu, and optionally hide the timeout count
#GRUB_HIDDEN_TIMEOUT=5
#GRUB_HIDDEN_TIMEOUT_QUIET=true

# Uncomment to use basic console
GRUB_TERMINAL_INPUT=console

# Uncomment to disable graphical terminal
#GRUB_TERMINAL_OUTPUT=console

# The resolution used on graphical terminal
# note that you can use only modes which your graphic card supports via VBE
# you can see them in real GRUB with the command 'vbeinfo'
GRUB_GFXMODE=auto

# Uncomment to allow the kernel use the same resolution used by grub
GRUB_GFXPAYLOAD_LINUX=keep
# Uncomment if you want GRUB to pass to the Linux kernel the old parameter
# format "root=/dev/xxx" instead of "root=/dev/disk/by-uuid/xxx"
#GRUB_DISABLE_LINUX_UUID=true

# Uncomment to disable generation of recovery mode menu entries
GRUB_DISABLE_RECOVERY=true

# Uncomment and set to the desired menu colors.  Used by normal and wallpaper
# modes only.  Entries specified as foreground/background.
#GRUB_COLOR_NORMAL="light-blue/black"
#GRUB_COLOR_HIGHLIGHT="light-cyan/blue"

# Uncomment one of them for the gfx desired, a image background or a gfxtheme
#GRUB_BACKGROUND="/path/to/wallpaper"
#GRUB_THEME="/path/to/gfxtheme"

# Uncomment to get a beep at GRUB start
#GRUB_INIT_TUNE="480 440 1"
# Uncomment to make GRUB remember the last selection. This requires to
# set 'GRUB_DEFAULT=saved' above.
#GRUB_SAVEDEFAULT="true"
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

useradd -c "$USER_FULLNAME" \
  -m \
  -s /bin/bash \
  -G wheel \
  -p '$6$rounds=4096$zLFpzBXFusR1$ckEnstIQ3inB3USRuyQ2zJIMUiYqVQRbeNVFYGbec.iQ9Jl8fKbQkwk27fIhJytnJ3qXW21PVLNn.gm9wCNGV1' \
  $USERNAME
