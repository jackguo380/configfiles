#! /bin/bash

set -e

echo "Installing symlinks"

./install-symlinks.sh

echo "Installing i3"

./i3-install-ubuntu-18.sh

echo "Installing urxvt"

sudo apt install rxvt-unicode

echo "Installing urxvt perls"

pushd "$HOME"
if [ ! -d urxvt-perls/.git ]; then
    rm -rf urxvt-perls
    git clone https://github.com/muennich/urxvt-perls urxvt-perls
    cd urxvt-perls
    if [ ! -e "$HOME/.urxvt/ext/keyboard-select" ]; then
        mkdir -p "$HOME/.urxvt/ext"
        ln -s "$PWD/keyboard-select" "$HOME/.urxvt/ext/"
    fi
fi

echo "Installing Hack Font"

sudo apt install fonts-hack-ttf

echo "Done everything"
