#! /bin/bash

set -e

repo=$(realpath "$(dirname "$0")")

cd "$HOME/.config"

for dir in alacritty i3 i3blocks; do

    rm -f $dir

    ln -s "$repo/$dir" .
done

echo Done
