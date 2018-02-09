#!/bin/bash

while :
do

echo "1: Check current Trackpoint settings"
echo "2: Set Trackpoint settings"
echo "3: Setup systemd for persistent Trackpoint settings"
echo "4: Make current Trackpoint settings persistent"
echo "0: Exit"
echo " "
read vMainMenu

case $vMainMenu in
1 )
  printf "Trackpoint Sensitivity: " && cat /sys/devices/platform/i8042/serio1/serio2/sensitivity
  printf "Trackpoint Speed: " && cat /sys/devices/platform/i8042/serio1/serio2/speed
  printf "Trackpoint Press_To_Select: " && cat /sys/devices/platform/i8042/serio1/serio2/press_to_select
  echo " "
;;

2 )
  echo "Sensitivity:1-255"
  read vSensitivity
  echo "Speed:1-255"
  read vSpeed
  echo "Press_to_Select:0-1"
  read vPress_to_Select
  echo $vSensitivity > /sys/devices/platform/i8042/serio1/serio2/sensitivity
  echo $vSpeed > /sys/devices/platform/i8042/serio1/serio2/speed
  echo $vPress_to_Select > /sys/devices/platform/i8042/serio1/serio2/press_to_select
  echo " "
;;

3 )
  cp -r templates/trackpoint.service /etc/systemd/system
  cp -r templates/trackpoint.timer /etc/systemd/system
  cp -r templates/trackpoint.sh /usr/bin && chmod +x /usr/bin/trackpoint.sh
  systemctl start trackpoint
  systemctl enable trackpoint.timer
;;

4 )
if [ ! -z "$vSensitivity" -a ! -z "$vSpeed" -a ! -z "$vPress_to_Select" ];
then
  echo "#!/bin/bash" > templates/trackpoint.sh
  echo "echo -n $vSensitivity > /sys/devices/platform/i8042/serio1/serio2/sensitivity" >> templates/trackpoint.sh
  echo "echo -n $vSpeed > /sys/devices/platform/i8042/serio1/serio2/speed" >> templates/trackpoint.sh
  echo "echo -n $vPress_to_Select > /sys/devices/platform/i8042/serio1/serio2/press_to_select" >> templates/trackpoint.sh
  cp -r templates/trackpoint.sh /usr/bin && chmod +x /usr/bin/trackpoint.sh
else
  echo "Settings not configured.  Please run \"Option 2:\" first"
  echo ""
fi
;;

0 | [eE]xit )
  exit
;;

* )
  echo "Pleaes enter a valid option"
  echo " "
esac

done
