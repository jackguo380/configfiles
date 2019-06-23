#! /bin/bash

set -e

sudo echo

if ! dpkg -l sur5r-keyring &> /dev/null; then
    cd /tmp

    /usr/lib/apt/apt-helper download-file http://debian.sur5r.net/i3/pool/main/s/sur5r-keyring/sur5r-keyring_2019.02.01_all.deb keyring.deb SHA256:176af52de1a976f103f9809920d80d02411ac5e763f695327de9fa6aff23f416
    sudo dpkg -i ./keyring.deb

    rm keyring.deb
fi

if [ ! -f /etc/apt/sources.list.d/sur5r-i3.list ]; then
    echo "deb http://debian.sur5r.net/i3/ bionic universe" | sudo tee /etc/apt/sources.list.d/sur5r-i3.list
fi

sudo apt update

sudo apt install i3 i3lock-fancy i3blocks suckless-tools compton

cd

if [ ! -d i3-cinnamon/.git ]; then
    rm -r -f i3-cinnamon
    git clone https://github.com/jbbr/i3-cinnamon i3-cinnamon
fi

cd i3-cinnamon

git pull

sudo make install

echo Done
