#!/bin/bash
if [ -d testing/sys/devices/platform/i8042/serio1/serio2 ];
then
  vTrackpointPath=testing/sys/devices/platform/i8042/serio1/serio2
else
  vTrackpointPath=testing/sys/devices/platform/i8042/serio1
fi
echo -n 150 > $vTrackpointPath/sensitivity
echo -n 150 > $vTrackpointPath/speed
echo -n 1 > $vTrackpointPath/press_to_select
