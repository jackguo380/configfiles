#! /bin/bash

set -e

if ! command -v rustup; then
    echo "Install Rust to continue"
    exit 1
fi

cd

if [ ! -d alacritty/.git ]; then
    rm -r -f alacritty
    git clone https://github.com/jwilm/alacritty alacritty
fi

cd alacritty

git pull

git checkout cd8d537bed98559ed49c1465db84ecec5393119f

rustup update stable

cargo install cargo-deb

sudo apt update

sudo apt install cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev python3

cargo build --release

cargo deb --install

echo Done
