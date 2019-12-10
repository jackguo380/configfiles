#!/bin/bash

set -e

script_dir=$(dirname "$(realpath "$0")")

if [ ! -f "$script_dir/soundoutput.sh" ]; then
    echo "Cannot find soundoutput.sh"
    exit 1
fi

pipe=/tmp/soundoutput_yad_$$.pipe

mkfifo $pipe

exec 3<> $pipe

_atexit() {
    echo quit >&3
    rm -f $pipe
}
trap _atexit EXIT

_soundoutput_toggle() {
    output=$(bash "$script_dir/soundoutput.sh")

    case "$output" in
        Spkr)
            echo "tooltip:Sound Output: Speakers" > $pipe
            echo "icon:audio-speakers" > $pipe
            ;;
        Hdph)
            echo "tooltip:Sound Output: Headphones" > $pipe
            echo "icon:audio-headphones" > $pipe
            ;;
        *)
            echo "tooltip:Error" > $pipe
            echo "icon:error" > $pipe
            ;;
    esac
}

export -f _soundoutput_toggle
export script_dir
export pipe

yad --notification \
    --listen \
    --image="audio-speakers" \
    --text="Sound Output: Speakers" \
    --command="bash -c _soundoutput_toggle" \
    <&3
