#!/bin/bash

# Add to /etc/sudoers
# Cmnd_Alias SBL = screen_backlight.sh
# %wheel ALL = (ALL) NOPASSWD: SBL

BACKLIGHT_PATH="/sys/class/backlight/acpi_video0/brightness"
BACKLIGHT=$(cat $BACKLIGHT_PATH)
INCREMENT=1
ID="Backlight"
ID_ICON=display
MAX="15"
MIN="0"
ID_FILE="/home/raymond/scripts/data/screen_backlight_id"
VALUE_FILE="/home/raymond/scripts/data/screen_backlight_value"

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
        # Dont restore to 0
        if [ $TOTAL -lt "1" ]; then
            exit 1
        fi
        if [ $TOTAL -gt $MAX ]; then
            exit 1
        fi
        ;;
    *)
        echo "Use: screen-backlight up|down|total|restore|off"
        exit 1
        ;;
esac

PERCENT=$(awk -v m=$m 'BEGIN { print ("'${TOTAL}'"/"'${MAX}'")*100 }')
NOTIFY_ID=$(cat $ID_FILE)
[[ "$NOTIFY_ID" != ?(+|-)+([0-9]) ]] && NOTIFY_ID=0 && echo "no ID number"

NOTIFY_ID=`notify-send -i $ID_ICON $ID "$PERCENT %" -p -r $NOTIFY_ID`

echo $NOTIFY_ID > $ID_FILE
echo $TOTAL > $BACKLIGHT_PATH
echo $TOTAL > $VALUE_FILE