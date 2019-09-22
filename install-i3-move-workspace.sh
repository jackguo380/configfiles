#! /bin/bash

set -e

if ! command -v cargo > /dev/null; then
    echo "Install cargo"
    exit 1
fi


cd i3/i3-move-workspace

cargo build --release

cargo install --force --path .
