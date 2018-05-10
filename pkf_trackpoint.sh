#!/bin/bash
if [ -d /sys/devices/platform/i8042/serio1/serio2 ];
then
  vTrackpointPath=/sys/devices/platform/i8042/serio1/serio2
else
  vTrackpointPath=/sys/devices/platform/i8042/serio1
fi

while :
do

echo ""
echo "1: Check current Trackpoint settings"
echo "2: Set Trackpoint settings"
echo "3: Setup systemd for persistent Trackpoint settings"
echo "4: Make current Trackpoint settings persistent"
echo "5: Remove Trackpoint persistent settings (use OS defaults)"
echo "6: Set current Trackpoint settings back to OS defaults"
if [ -f /etc/systemd/system/trackpoint.timer ];
then
  echo "9: ***Cleanup pre-1.5 configurations***"
fi
echo "0: Exit"
echo " "
read vMainMenu

case $vMainMenu in
1 )
  printf "Trackpoint Sensitivity: " && cat $vTrackpointPath/sensitivity
  printf "Trackpoint Speed: " && cat $vTrackpointPath/speed
  printf "Trackpoint Press_To_Select: " && cat $vTrackpointPath/press_to_select
  if [ -f /etc/systemd/system/trackpoint.service -a -f /etc/systemd/system/trackpoint.path -a -f /usr/bin/trackpoint.sh ];
  then
    echo "Persistence: Enabled"
  elif [ ! -f /etc/systemd/system/trackpoint.service -a ! -f /etc/systemd/system/trackpoint.path -a ! -f /usr/bin/trackpoint.sh ];
  then
    echo "Persistence: Disabled"
  else
    echo "Persistence: Broken.  Use option 3 or 5 to fix"
  fi
;;

2 )
  echo "Sensitivity:1-255"
  read vSensitivity
  echo "Speed:1-255"
  read vSpeed
  echo "Press_to_Select:0-1"
  read vPress_to_Select
  echo $vSensitivity > $vTrackpointPath/sensitivity
  echo $vSpeed > $vTrackpointPath/speed
  echo $vPress_to_Select > $vTrackpointPath/press_to_select
;;

3 )
  cp -r templates/trackpoint.service /etc/systemd/system
  cp -r templates/trackpoint.path /etc/systemd/system
  cp -r templates/trackpoint.sh /usr/bin && chmod +x /usr/bin/trackpoint.sh
  systemctl daemon-reload
  systemctl start trackpoint
  systemctl enable trackpoint
;;

4 )
if [ ! -z "$vSensitivity" -a ! -z "$vSpeed" -a ! -z "$vPress_to_Select" ];
then
  echo "#!/bin/bash" > templates/trackpoint.sh
  echo "if [ -d /sys/devices/platform/i8042/serio1/serio2 ];" >> templates/trackpoint.sh
  echo "then" >> templates/trackpoint.sh
  echo "  vTrackpointPath=/sys/devices/platform/i8042/serio1/serio2" >> templates/trackpoint.sh
  echo "else" >> templates/trackpoint.sh
  echo "  vTrackpointPath=/sys/devices/platform/i8042/serio1" >> templates/trackpoint.sh
  echo "fi" >> templates/trackpoint.sh
  echo "echo -n $vSensitivity > \$vTrackpointPath/sensitivity" >> templates/trackpoint.sh
  echo "echo -n $vSpeed > \$vTrackpointPath/speed" >> templates/trackpoint.sh
  echo "echo -n $vPress_to_Select > \$vTrackpointPath/press_to_select" >> templates/trackpoint.sh
  cp -r templates/trackpoint.sh /usr/bin && chmod +x /usr/bin/trackpoint.sh
else
  echo "Settings not configured.  Please run \"Option 2:\" first"
fi
;;

5 )
  systemctl stop trackpoint
  rm -f /etc/systemd/system/trackpoint.service
  rm -f /etc/systemd/system/trackpoint.path
  rm -f /usr/bin/trackpoint.sh
  ##Remove trackpoint.timer from pre-v1.5 versions
  rm -f /etc/systemd/system/trackpoint.timer
  systemctl daemon-reload
;;

6 )
echo 128 > $vTrackpointPath/sensitivity
echo 97 > $vTrackpointPath/speed
echo 0 > $vTrackpointPath/press_to_select
;;

9 )
rm /etc/systemd/system/trackpoint.timer
;;

0 | [eE]xit )
  exit
;;

* )
  echo "Pleaes enter a valid option"
esac

done
