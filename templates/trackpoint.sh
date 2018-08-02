#!/bin/bash

## Determine and set correct path for trackpoint
if [ -f /sys/devices/platform/i8042/serio1/serio2/sensitivity ];
then
  vTrackpointPath=/sys/devices/platform/i8042/serio1/serio2
elif [ -f /sys/devices/platform/i8042/serio1/sensitivity ];
then
  vTrackpointPath=/sys/devices/platform/i8042/serio1
else
  echo "Trackpoint not detected"
  exit 200
fi

## Set trackpoint setting variable values
vSensitivity=128
vSpeed=92
vPress_to_Select=0

## Apply settings based on option "start" or "stop" being passed
case $1 in
  [Ss]tart )
    echo -n $vSensitivity > $vTrackpointPath/sensitivity
    echo -n $vSpeed > $vTrackpointPath/speed
    echo -n $vPress_to_Select > $vTrackpointPath/press_to_select
  ;;

  [Ss]top )
    echo 128 > $vTrackpointPath/sensitivity
    echo 97 > $vTrackpointPath/speed
    echo 0 > $vTrackpointPath/press_to_select
  ;;

  * )
    echo "Usage: {start|stop}"
esac
