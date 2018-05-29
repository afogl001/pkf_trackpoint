#!/bin/bash

# Set trackpoint paths based on existence of trackpad
if [ -d /sys/devices/platform/i8042/serio1/serio2 ];
then
  vTrackpointPath=/sys/devices/platform/i8042/serio1/serio2
else
  vTrackpointPath=/sys/devices/platform/i8042/serio1
fi

# Check if OS is using systemd
systemctl --version &> /dev/null
if [ $? != 0 ];
then
  vInitSystem=sysv
else
  vInitSystem=systemd
fi

while :
do

echo ""
echo "1: Check current Trackpoint settings"
echo "2: Set Trackpoint settings"
echo "3: Setup persistent Trackpoint settings"
echo "4: Make current Trackpoint settings persistent"
echo "5: Remove Trackpoint persistent settings (use OS defaults)"
echo "6: Set current Trackpoint settings back to OS defaults"
echo "0: Exit"
echo " "
read vMainMenu

case $vMainMenu in
1 )
  printf "Trackpoint Sensitivity: " && cat $vTrackpointPath/sensitivity
  printf "Trackpoint Speed: " && cat $vTrackpointPath/speed
  printf "Trackpoint Press_To_Select: " && cat $vTrackpointPath/press_to_select
  # Check status of persistence depending on init system
  if [ $vInitSystem = sysv ];
  then
    if [ -f /etc/init.d/trackpoint -a -f /usr/bin/trackpoint.sh ];
    then
      echo "Persistence: Enabled (SysV)"
    elif [ ! -f /etc/init.d/trackpoint -a ! -f /usr/bin/trackpoint.sh ];
    then
      echo "Persistence: Disabled (SysV)"
    else
      echo "Persistence: Broken.  Use option 3 or 5 to fix"
    fi
  else
    if [ -f /etc/systemd/system/trackpoint.service -a -f /etc/systemd/system/trackpoint.timer -a -f /usr/bin/trackpoint.sh ];
    then
      echo "Persistence: Enabled (systemd)"
    elif [ ! -f /etc/systemd/system/trackpoint.service -a ! -f /etc/systemd/system/trackpoint.timer -a ! -f /usr/bin/trackpoint.sh ];
    then
      echo "Persistence: Disabled (systemd)"
    else
      echo "Persistence: Broken.  Use option 3 or 5 to fix"
    fi
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
  if [ $vInitSystem = sysv ];
  then
    cp -r templates/trackpoint /etc/init.d && chmod +x /etc/init.d/trackpoint
    cp -r templates/trackpoint.sh /usr/bin && chmod +x /usr/bin/trackpoint.sh
    update-rc.d trackpoint start 90 5 . stop 90 0 1 2 3 4 6 . > /dev/null
  else
    cp -r templates/trackpoint.service /etc/systemd/system
    cp -r templates/trackpoint.timer /etc/systemd/system
    cp -r templates/trackpoint.sh /usr/bin && chmod +x /usr/bin/trackpoint.sh
    systemctl daemon-reload
    systemctl start trackpoint
    systemctl enable trackpoint.timer
  fi
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
  if [ $vInitSystem = sysv ];
  then
    update-rc.d -f trackpoint remove >> /dev/null
    rm -f /etc/init.d/trackpoint
    rm -f /usr/bin/trackpoint.sh
  else
    systemctl stop trackpoint
    rm -f /etc/systemd/system/trackpoint.service
    rm -f /etc/systemd/system/trackpoint.timer
    rm -f /usr/bin/trackpoint.sh
    systemctl daemon-reload
  fi
;;


6 )
echo 128 > $vTrackpointPath/sensitivity
echo 97 > $vTrackpointPath/speed
echo 0 > $vTrackpointPath/press_to_select
;;

0 | [eE]xit )
  exit
;;

* )
  echo "Pleaes enter a valid option"
esac

done
