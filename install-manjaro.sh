#! /bin/bash

set -e

echo "Installing symlinks"

./install-symlinks.sh

echo "Installing urxvt"

sudo pamac install rxvt-unicode rxvt-unicode-terminfo

echo "Installing urxvt perls"

sudo pamac install urxvt-perls

echo "Installing Hack Font"

sudo pamac install ttf-hack

echo "Installing fzf"

./install-fzf.sh

echo "Done everything"
