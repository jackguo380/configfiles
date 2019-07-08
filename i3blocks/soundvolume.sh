#! /bin/bash

set -e

function parse_vol {
    local IFS=:

    local vol newvol

    while read -r -d , k v; do
        newvol=$(echo "$v" | sed -e 's/[^\/]*\/[ ]*\([0-9]\+%\).*/\1/')

        if [ -z "$vol" ]; then
            vol=$newvol
        elif [ "$vol" != "$newvol" ]; then
            echo "$vol (!=)"
            return 0
        fi
    done

    echo "$vol"
}

if [ -z "$CARD" ]; then
    while read n name && read m mute && read v volume && read basevol; do
        [ "$n" = "Name:" ] || continue
        [ "$m" = "Mute:" ] || continue
        [ "$v" = "Volume:" ] || continue

        if pactl info | grep "Default Sink" | grep "$name" &> /dev/null; then
            if [ "$mute" = yes ]; then
                echo "Vol: Mute"
            else
                echo "Vol: $(echo "$volume" | parse_vol)"
            fi

            exit 0
        fi
    done < <(pactl list sinks | grep '\(Name:\|Volume:\|Mute:\)')

    echo Error
fi
