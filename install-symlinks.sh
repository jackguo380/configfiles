#! /bin/bash

set -e

repo_dir=$(realpath "$(dirname "$0")")

create_symlink() {
    local target link link_real

    if [ ! -e "$1" ]; then
        echo "target $1 does not exist"
        return 1
    fi

    target=$(realpath "$1")
    link=$2

    if [ -e "$link" ]; then
        link_real=$(realpath "$link")

        if [ "$target" != "$link_real" ]; then
            # something else is already in the location
            echo "$link already exists, delete and try again"
            return 1
        else
            echo "symlink $link -> $target already exists"
            return 0
        fi
    else
        echo "creating symlink $link -> $target"
        mkdir -p "$(dirname "$link")"
        ln -s "$target" "$link"
        echo "done"
    fi

    return 0
}


config_dir=$HOME/.config

config_links=(
    compton.conf
    dunst
    i3
    i3blocks
    i3status
    chromium-flags.conf
    )

for link in "${config_links[@]}"; do
    create_symlink "$repo_dir/$link" "$config_dir/$link"
done

urxvt_dir=$HOME/.urxvt/ext

for ext in "$repo_dir"/urxvt_ext/*; do
    ext_name=$(basename "$ext")

    create_symlink "$ext" "$urxvt_dir/$ext_name"
done

home_links=(
    .bashrc
    .inputrc
    .bash_aliases
    .Xdefaults
    .profile
    )

for link in "${home_links[@]}"; do
    create_symlink "$repo_dir/$link" "$HOME/$link"
done
