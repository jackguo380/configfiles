#! /bin/bash

set -e

repo_dir=$(realpath "$(dirname "$0")")

i3baseconfig=$repo_dir/i3/baseconfig
i3config=$repo_dir/i3/config

config_regex='^[ #]*\(.*\)#[ ]*--\([^#]\+\)--[ ]*$' 
mapfile -t configs < <( \
    grep "$config_regex" "$i3baseconfig" |
    sed -e "s/$config_regex/\2/" |
    sort -u)

echo "Configurations: ${configs[*]}"

if [ $# -lt 1 ]; then
    echo "Usage: $0 <configurations...>"
    exit 1
fi

configurations=( "$@" )

for configuration in "${configurations[@]}"; do
    ok=0
    for conf in "${configs[@]}"; do
        if [ "$configuration" = "$conf" ]; then
            ok=1
            break
        fi
    done

    if [ "$ok" != 1 ]; then
        echo "Invalid Config: $conf"
        exit 1
    fi
done


echo "Copying $baseconfig to $i3config"
cp "$i3baseconfig" "$i3config"

echo "Commenting Out Unwanted Lines in $i3config"
sed -i -e "s/$config_regex/#\1 # --\2--/" "$i3config"

for configuration in "${configurations[@]}"; do
    echo "Enabling Wanted Lines for $configuration in $i3config"
    curconfig_regex="^[ #]*\(.*\)#[ ]*--$configuration--[ ]*$"
    sed -i -e "s/$curconfig_regex/\1/" "$i3config"
done

echo DONE

