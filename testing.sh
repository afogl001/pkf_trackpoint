#!/bin/bash

while :
do

echo ""
grep "testing/sys/devices" pkf_trackpoint.sh > /dev/null || grep "testing/sys/devices" templates/trackpoint.sh > /dev/null
if [ $? -gt 0 ];
then
  echo "Test mode: False"
  vTestStatus=0
else
  echo "Test mode: True"
  vTestStatus=1
fi

if [ ! -d testing/sys/devices/platform/i8042/serio1/serio2 ];
then
  echo "Trackpad: Disabled"
  vTestTrackpad=0
else
  echo "Trackpad: Enabled"
  vTestTrackpad=1
fi

echo ""
echo "1: Toogle Test Status"
echo "2: Toogle Trackpad existence"
echo "0: Exit"
echo " "
read vTestMenu

case $vTestMenu in
  1 )
  if [ $vTestStatus = 0 ];
  then
    sed -i 's/\/sys\/devices/testing\/sys\/devices/g' pkf_trackpoint.sh
    sed -i 's/\/etc\/systemd/testing\/etc\/systemd/g' pkf_trackpoint.sh
    sed -i 's/\/usr\/bin/testing\/usr\/bin/g' pkf_trackpoint.sh
    sed -i 's/systemctl/#systemctl/g' pkf_trackpoint.sh
    sed -i 's/\/sys\/devices/testing\/sys\/devices/g' templates/trackpoint.sh
  fi
  if [ $vTestStatus = 1 ];
  then
    sed -i 's/testing\/sys\/devices/\/sys\/devices/g' pkf_trackpoint.sh
    sed -i 's/testing\/etc\/systemd/\/etc\/systemd/g' pkf_trackpoint.sh
    sed -i 's/testing\/usr\/bin/\/usr\/bin/g' pkf_trackpoint.sh
    sed -i 's/#systemctl/systemctl/g' pkf_trackpoint.sh
    sed -i 's/testing\/sys\/devices/\/sys\/devices/g' templates/trackpoint.sh
  fi
  exit
  ;;

  2 )
  if [ $vTestTrackpad = 0 ];
  then
    mkdir testing/sys/devices/platform/i8042/serio1/serio2
    echo "128" > testing/sys/devices/platform/i8042/serio1/serio2/sensitivity
    echo "92" > testing/sys/devices/platform/i8042/serio1/serio2/speed
    echo "0" > testing/sys/devices/platform/i8042/serio1/serio2/press_to_select

  fi
  if [ $vTestTrackpad = 1 ];
  then
    rm -r testing/sys/devices/platform/i8042/serio1/serio2
    echo "128" > testing/sys/devices/platform/i8042/serio1/sensitivity
    echo "92" > testing/sys/devices/platform/i8042/serio1/speed
    echo "0" > testing/sys/devices/platform/i8042/serio1/press_to_select
  fi
  exit
  ;;

0 | [eE]xit )
  exit
  ;;

* )
  echo "Pleaes enter a valid option"
  echo " "
esac

done
