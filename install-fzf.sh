#! /bin/bash

set -e

if ! [ -d ~/.fzf ]; then
    echo "Cloing fzf..."
    git clone https://github.com/junegunn/fzf --depth 1 ~/.fzf
fi

cd ~/.fzf

./install --all

