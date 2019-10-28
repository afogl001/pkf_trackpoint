#!/bin/bash

## Determine and set correct path for trackpoint
for file in $(find /sys/devices -name press_to_select)
do
  dir=$(dirname $file)
  if [ -f $dir/speed -a -f $dir/sensitivity ]; then
    vTrackpointPath=$dir
    break
  fi
done

if ! [ $vTrackpointPath ]; then
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
