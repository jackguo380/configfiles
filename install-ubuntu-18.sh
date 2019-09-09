#! /bin/bash

set -e

echo "Installing symlinks"

./install-symlinks.sh

echo "Installing i3"

./i3-install-ubuntu-18.sh

echo "Installing alacritty"

./alacritty-install-ubuntu-18.sh

echo "Installing Hack Font"

sudo apt install fonts-hack-ttf

echo "Done everything"
