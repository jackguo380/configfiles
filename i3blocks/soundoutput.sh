#! /bin/bash
# A small script to display (and possibly control) the sound output

set -e

LABEL="${LABEL:-Audio Out}:"

CARD=${CARD:-0}

if amixer -c "$CARD" | grep 'control.*Analog Output' &> /dev/null; then
    # Xonar DGX (snd-oxygen driver)
    # In order to swap between front-panel aux and regular surround output
    # we need to set:
    # Alsa output - this does the actual change between outputs
    # Pulse audio profile - this makes it so that volume control actually works properly

    # Toggle between cards, skip "Stereo Headphones" as that is not very useful
    output=$(amixer -c "$CARD" sget 'Analog Output' |
        grep Item0 | sed -e "s/.*Item0: '\(.*\)'.*/\1/")

    case "$output" in
        Multichannel)
            amixer -c "$CARD" sset 'Analog Output' 'Stereo Headphones FP' &> /dev/null
            pactl set-card-profile "$CARD" 'output:analog-stereo+input:analog-stereo'
            ;; 
        "Stereo Headphones FP")
            amixer -c "$CARD" sset 'Analog Output' 'Multichannel' &> /dev/null
            pactl set-card-profile "$CARD" 'output:analog-surround-51+input:analog-stereo'
            ;;
        "Stereo Headphones")
            amixer -c "$CARD" sset 'Analog Output' 'Multichannel' &> /dev/null
            pactl set-card-profile "$CARD" 'output:analog-surround-51+input:analog-stereo'
            ;;
        *) echo "$LABEL Unknown" ;;
    esac

    # Check which card we ended on
    output=$(amixer -c "$CARD" sget 'Analog Output' |
        grep Item0 | sed -e "s/.*Item0: '\(.*\)'.*/\1/")

    case "$output" in
        Multichannel) echo "$LABEL Speakers (Multi)" ;; 
        "Stereo Headphones FP") echo "$LABEL Headphones" ;;
        "Stereo Headphones") echo "$LABEL Speakers" ;;
        *) echo "$LABEL Unknown" ;;
    esac
elif amixer -c "$CARD" | grep 'control.*Headphone' &> /dev/null; then
    # Generic sound card
    if amixer -c "$CARD" sget Headphone | grep 'Playback.*\[on\]' &> /dev/null; then
        echo "$LABEL Headphones"
    else
        echo "$LABEL Speakers"
    fi
else
    echo 'Bad Sound Card'
fi

exit 0

