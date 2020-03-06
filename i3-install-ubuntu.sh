#! /bin/bash

set -e

sudo echo

if ! dpkg -l sur5r-keyring &> /dev/null; then
    cd /tmp

    /usr/lib/apt/apt-helper download-file https://debian.sur5r.net/i3/pool/main/s/sur5r-keyring/sur5r-keyring_2020.02.03_all.deb keyring.deb SHA256:c5dd35231930e3c8d6a9d9539c846023fe1a08e4b073ef0d2833acd815d80d48

    sudo dpkg -i ./keyring.deb

    rm keyring.deb
fi

if [ ! -f /etc/apt/sources.list.d/sur5r-i3.list ]; then
    echo "deb http://debian.sur5r.net/i3/ bionic universe" | sudo tee /etc/apt/sources.list.d/sur5r-i3.list
fi

sudo apt update

sudo apt install i3 i3lock-fancy i3blocks suckless-tools compton dunst i3status

cd

exit 0

if [ ! -d i3-gnome/.git ]; then
    rm -r -f i3-gnome
    git clone https://github.com/i3-gnome/i3-gnome i3-gnome
fi

cd i3-gnome

git pull

sudo make install

echo Done
