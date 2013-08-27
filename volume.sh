#!/bin/bash

INCREMENT=1
ID_FILE="/home/raymond/scripts/data/volume_id"
MAX=100
ID="Volume"

# Create files if they dont exist
if [ ! -f $ID_FILE ] ; then
    echo "Creating file '"$ID_FILE"' With value '0'"
    echo 0 > $ID_FILE
fi

case $1 in
    up)
		level=`amixer get Master | egrep 'Playback.*?' | egrep -o '\[.*%' | cut -c2- | rev | cut -c2- | rev`
		set_level=`expr $level + $INCREMENT`
		new_level=`amixer set Master $set_level% | egrep 'Playback.*?' | egrep -o '\[.*%' | cut -c2- | rev | cut -c2- | rev`
		echo "Set to: "$new_level
		icon="audio-volume-high"
		;;
    down)
        current_level=`amixer get Master | egrep 'Playback.*?' | egrep -o '\[.*%' | cut -c2- | rev | cut -c2- | rev`
		new_level=$current_level
		set_level=`expr $current_level - $INCREMENT`

		while [ $new_level -ge $current_level ]
		do
	  		new_level=`amixer set Master $set_level% | egrep 'Playback.*?' | egrep -o '\[.*%' | cut -c2- | rev | cut -c2- | rev`
	  		set_level=`expr $set_level - $INCREMENT`
		done
		echo "Set to: "$new_level
		icon="audio-volume-low"
		;;
    mute_toggle)
		CURRENT_STATE=`amixer get Master | egrep 'Playback.*?\[o' | egrep -o '\[o.+\]'`
		if [[ $CURRENT_STATE == '[on]' ]]; then
    	    amixer set Master mute
	    	amixer set Speaker mute
	    	amixer set Headphone mute
	    	result="Muted"
	    	echo $result
	    	icon="audio-volume-muted"
		else
    	    amixer set Master unmute
    	    amixer set Speaker unmute
    	    amixer set Headphone unmute
	    	result="Unmuted"
	    	echo $result
	    	icon="audio-volume-medium"
		fi
		;;
    *)
		echo "Use: volume up|down|mute_toggle"
		exit 1
		;;
esac

NOTIFY_ID=$(cat $ID_FILE)
[[ "$NOTIFY_ID" != ?(+|-)+([0-9]) ]] && NOTIFY_ID=0 && echo "no ID number"

if [[ $1 == 'mute_toggle' ]]; then
	NOTIFY_ID=`notify-send -i $icon $ID $result -p -r $NOTIFY_ID`
else
	PERCENT=$(awk -v m=$m 'BEGIN { print ("'${new_level}'"/"'${MAX}'")*100 }')
	NOTIFY_ID=`notify-send -i $icon $ID "$PERCENT %" -p -r $NOTIFY_ID`
fi

echo $NOTIFY_ID > $ID_FILE
canberra-gtk-play -i audio-volume-change &