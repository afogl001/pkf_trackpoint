#!/bin/bash

while :
do

grep "testing/sys/devices" pkf_trackpoint.sh > /dev/null
if [ $? -gt 0 ];
then
  echo "Test mode: False"
  vTestStatus=0
else
  echo "Test mode: True"
  vTestStatus=1
fi
echo ""
echo "1: Toogle Test Status"
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
  fi
  if [ $vTestStatus = 1 ];
  then
    sed -i 's/testing\/sys\/devices/\/sys\/devices/g' pkf_trackpoint.sh
    sed -i 's/testing\/etc\/systemd/\/etc\/systemd/g' pkf_trackpoint.sh
    sed -i 's/testing\/usr\/bin/\/usr\/bin/g' pkf_trackpoint.sh
    sed -i 's/#systemctl/systemctl/g' pkf_trackpoint.sh
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
