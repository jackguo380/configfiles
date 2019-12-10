#! /bin/bash

set -e

repo_dir=$(realpath "$(dirname "$0")")

i3baseconfig=$repo_dir/i3/baseconfig
i3config=$repo_dir/i3/config

i3statusbaseconfig=$repo_dir/i3status/baseconfig
i3statusconfig=$repo_dir/i3status/config

config_regex='^[ #]*\(.*\)#[ ]*--\([^#]\+\)--[ ]*$' 
mapfile -t configs < <( \
    grep -h "$config_regex" "$i3baseconfig" "$i3statusbaseconfig" |
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


echo "Copying $i3baseconfig to $i3config"
cp "$i3baseconfig" "$i3config"

echo "Copying $i3statusbaseconfig to $i3statusconfig"
cp "$i3statusbaseconfig" "$i3statusconfig"

echo "Commenting Out Unwanted Lines in $i3config $i3statusconfig"
sed -i -e "s/$config_regex/#\1 # --\2--/" "$i3config" "$i3statusconfig"

for configuration in "${configurations[@]}"; do
    echo "Enabling Wanted Lines for $configuration in $i3config $i3statusconfig"
    curconfig_regex="^[ #]*\(.*\)#[ ]*--$configuration--[ ]*$"
    sed -i -e "s/$curconfig_regex/\1/" "$i3config" "$i3statusconfig"
done

echo DONE

