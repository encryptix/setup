#!/bin/bash

BACKLIGHT=$(cat /sys/class/leds/smc::kbd_backlight/brightness)
INCREMENT=15
ID="Backlight"
ID_ICON=keyboard
MAX="255"
MIN="0"
ID_FILE="/home/raymond/scripts/data/keyboard_backlight_id"
VALUE_FILE="/home/raymond/scripts/data/keyboard_backlight_value"

# Create files if they dont exist
if [ ! -f $VALUE_FILE ] ; then
    echo "Creating file '"$VALUE_FILE"' With value '"$MIN"'"
    echo $MIN > $VALUE_FILE
fi

if [ ! -f $ID_FILE ] ; then
    echo "Creating file '"$ID_FILE"' With value '"$MIN"'"
    echo $MIN > $ID_FILE
fi

# Root check
if [ $UID -ne 0 ]; then
    echo "Please run this program as superuser"
    notify-send -i $ID_ICON $ID "Please run this program as superuser"
    exit 1
fi

case $1 in
    up)
        TOTAL=`expr $BACKLIGHT + $INCREMENT`
        if [ $TOTAL -gt $MAX ]; then
            exit 1
        fi
        ;;
    down)
        TOTAL=`expr $BACKLIGHT - $INCREMENT`
        if [ $TOTAL -lt $MIN ]; then
            exit 1
        fi
        ;;
    total)
        TOTAL=`expr $MAX`
        ;;
    off)
        TOTAL=`expr $MIN`
        ;;
    restore)
        TOTAL=$(cat $VALUE_FILE)
        if [ $TOTAL -lt $MIN ]; then
            exit 1
        fi
        if [ $TOTAL -gt $MAX ]; then
            exit 1
        fi
        ;;
    *)
        echo "Use: keyboard-light up|down|total|restore|off"
        exit 1
        ;;
esac

PERCENT=$(awk -v m=$m 'BEGIN { print ("'${TOTAL}'"/"'${MAX}'")*100 }')
NOTIFY_ID=$(cat $ID_FILE)
[[ "$NOTIFY_ID" != ?(+|-)+([0-9]) ]] && NOTIFY_ID=0 && echo "no ID number"

NOTIFY_ID=`notify-send -i $ID_ICON $ID "$PERCENT %" -p -r $NOTIFY_ID`

echo $NOTIFY_ID > $ID_FILE
echo $TOTAL > /sys/class/leds/smc::kbd_backlight/brightness
echo $TOTAL > $VALUE_FILE