#!/bin/sh

/usr/bin/tarsnap -c \
  --keyfile ${HOME}/.tarsnap.key \
  --cachedir ${HOME}/.cache/tarsnap \
  -f "$(uname -n)-$(date +%Y-%m-%d_%H-%M-%S)" \
  ${HOME}/Documents \
  ${HOME}/Pictures \
  ${HOME}/.ssh \
  ${HOME}/.local/share/buku \
  ${HOME}/.password-store \
  ${HOME}/.homesick
