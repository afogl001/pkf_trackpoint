#!/bin/bash

while : 
do

echo "1: Check current Trackpoint settings"
echo "2: Set Trackpoint settings"
echo "3: Setup systemd for persistent Trackpoint settings"
echo "4: Make current Trackpoint settings persistent"
echo "9: Exit"
echo " "
read vMainMenu

case $vMainMenu in
1 ) 
  printf "Trackpoint Sensitivity: " && cat sensitivity
  printf "Trackpoint Speed: " && cat speed
  printf "Trackpoint Press_To_Select: " && cat press_to_select
  echo " "
;;

2 )
  echo "Sensitivity:???"
  read vSensitivity
  echo "Speed:???"
  read vSpeed
  echo "Press_to_Select:?"
  read vPress_to_Select
  echo $vSensitivity > sensitivity
  echo $vSpeed > speed
  echo $vPress_to_Select > press_to_select
  echo " "
;;

3 )
  cp trackpoint.service /etc/systemd/system
  cp trackpoint.timer /etc/systemd/system
  cp trackpoint.sh /usr/bin && chmod +x /usr/bin/trackpoint.sh
  systemctl start trackpoint
  systemctl enable trackpoint.timer
;;
 
4 )
  echo "#!/bin/bash" > trackpoint.sh
  echo "echo -n $vPress_to_Select > /sys/devices/platform/i8042/serio1/serio2/press_to_select" >> trackpoint.sh
  echo "echo -n $vSensitivity > /sys/devices/platform/i8042/serio1/serio2/sensitivity" >> trackpoint.sh
  echo "echo -n $vSpeed > /sys/devices/platform/i8042/serio1/serio2/speed" >> trackpoint.sh
;;

9 | [eE]xit ) 
  exit
;;

* ) 
  echo "Pleaes enter a valid option"
  echo " "
esac

done
