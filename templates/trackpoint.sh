#!/bin/bash
if [ -d /sys/devices/platform/i8042/serio1/serio2 ];
then
  vTrackpointPath=/sys/devices/platform/i8042/serio1/serio2
else
  vTrackpointPath=/sys/devices/platform/i8042/serio1
fi
echo -n 150 > $vTrackpointPath/sensitivity
echo -n 150 > $vTrackpointPath/speed
echo -n 1 > $vTrackpointPath/press_to_select
