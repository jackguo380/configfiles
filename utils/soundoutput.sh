#! /bin/bash
# A small script to display (and possibly control) the sound output

set -e

if [ -z "$CARD" ] || [ -z "$PACARD" ]; then
    while read -r card cardnum && read -r n name && read -r alsa eq alsanum; do
        echo "Cardnum = $cardnum" >&2
        echo "Name = $name" >&2
        echo "Alsanum = $alsanum" >&2

        [ "$card" = "Card" ] || continue
        [ "$n" = "Name:" ] || continue
        [ "$alsa" = "alsa.card" ] || continue

        name=${name#alsa_card}

        if pactl info | grep "Default Sink" | grep "$name" &> /dev/null; then
            CARD=${alsanum//\"/}
            PACARD=${cardnum//'#'/}
            break
        fi
    done < <(pactl list cards | grep '\(Card #\|Name:\|alsa\.card \)')

    CARD=${CARD:-0}
    PACARD=${PACARD:-0}
fi

echo "Chose Card Alsa $CARD PA $PACARD" >&2

if amixer -c "$CARD" | grep 'control.*Analog Output' &> /dev/null; then
    echo "Xonar DGX Card" >&2
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
            amixer -c "$CARD" sset 'Analog Output' 'Stereo Headphones FP' > /dev/null
            pactl set-card-profile "$PACARD" 'output:analog-stereo+input:analog-stereo'
            ;; 
        #"Stereo Headphones FP")
        #    amixer -c "$CARD" sset 'Analog Output' 'Multichannel' &> /dev/null
        #    pactl set-card-profile "$CARD" 'output:analog-surround-51+input:analog-stereo'
        #    ;;
        #"Stereo Headphones")
        #    amixer -c "$CARD" sset 'Analog Output' 'Multichannel' &> /dev/null
        #    pactl set-card-profile "$CARD" 'output:analog-surround-51+input:analog-stereo'
        #    ;;
        *)
            amixer -c "$CARD" sset 'Analog Output' 'Multichannel' > /dev/null
            pactl set-card-profile "$PACARD" 'output:analog-surround-51+input:analog-stereo'
            ;;
    esac

    # Check which card we ended on
    output=$(amixer -c "$CARD" sget 'Analog Output' |
        grep Item0 | sed -e "s/.*Item0: '\(.*\)'.*/\1/")

    case "$output" in
        Multichannel) echo "Spkr" ;; 
        "Stereo Headphones FP") echo "Hdph" ;;
        *) echo "Error" ;;
    esac
elif amixer -c "$CARD" | grep 'control.*Rear Mic' &> /dev/null; then
    echo "Starship/Matisse Card" >&2
    # Starship/Matisse Card
    sinknum=
    cursinknum=
    while read -r line; do
        if [[ $line =~ ^Sink ]]; then
            cursinknum=${line##*#}
            continue
        fi

        if [ "${line## }" = "alsa.card = \"$CARD\"" ]; then
            sinknum=$cursinknum
            break
        fi
    done < <(pactl list sinks)

    if [ -z "$sinknum" ]; then
        echo "Error"
        exit 0
    fi

    getcurrentport_() {
        local correct_card=0
        while read -r line; do
            if [ "${line## }" = "alsa.card = \"$CARD\"" ]; then
                correct_card=1
                continue
            elif [[ $line =~ ^Sink ]]; then
                correct_card=0
                continue
            fi

            if [ $correct_card = 0 ]; then
                continue
            fi

            if [[ ${line## } =~ 'Active Port:' ]]; then
                echo "${line##*: }"
                break
            fi
        done < <(pactl list sinks)
    }

    case "$(getcurrentport_)" in
        *lineout)
            pactl set-sink-port "$sinknum" analog-output-headphones
            amixer -c "$CARD" sset 'Auto-Mute Mode' Enabled &> /dev/null
            ;; 
        *)
            pactl set-sink-port "$sinknum" analog-output-lineout
            amixer -c "$CARD" sset 'Auto-Mute Mode' Disabled &> /dev/null
            ;;
    esac

    case "$(getcurrentport_)" in
        *lineout) echo "Spkr" ;; 
        *headphones) echo "Hdph" ;;
        *) echo "Error" ;;
    esac
elif amixer -c "$CARD" | grep 'control.*Headphone' &> /dev/null; then
    echo "Generic Card" >&2
    # Generic sound card
    if amixer -c "$CARD" sget Headphone | grep 'Playback.*\[on\]' &> /dev/null; then
        echo "Spkr"
    else
        echo "Hdph"
    fi
else
    echo 'Bad Sound Card'
    exit 1
fi

exit 0

