#!/bin/bash

## Ensure script is being run as root
if ! [ $(id -u) = 0 ]; then
   echo "Pleaes run this script as root"
   exit 100
fi

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


## Initialize trackpoint varialbes with current values
vSensitivity=$(<$vTrackpointPath/sensitivity)
vSpeed=$(<$vTrackpointPath/speed)
vPress_to_Select=$(<$vTrackpointPath/press_to_select)

## Check if OS is using systemd
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
  ## Check status of persistence depending on init system
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
  printf "Sensitivity (1-255): Currently " && cat $vTrackpointPath/sensitivity
  read vTempSensitivity
  if [ "$vTempSensitivity" -lt 1 -o "$vTempSensitivity" -gt 255 ];
  then
    echo "Please enter a value between 1 and 255"
    continue
  fi
  printf "Speed (1-255): Currently " && cat $vTrackpointPath/speed
  read vTempSpeed
  if [ "$vTempSpeed" -lt 1 -o "$vTempSpeed" -gt 255 ];
  then
    echo "Please enter a value between 1 and 255"
    continue
  fi
  printf "Press_to_Select (0-1): Currently " && cat $vTrackpointPath/press_to_select
  read vTempPress_to_Select
  if [[ "$vTempPress_to_Select" != [0-1] ]];
  then
    echo "Please enter either 0 (disabled) or 1 (enabled)"
    continue
  fi
  ## Since all values are valid, assign to corrisponding variables
  vSensitivity=$vTempSensitivity
  vSpeed=$vTempSpeed
  vPress_to_Select=$vTempPress_to_Select
  echo $vSensitivity > $vTrackpointPath/sensitivity
  echo $vSpeed > $vTrackpointPath/speed
  echo $vPress_to_Select > $vTrackpointPath/press_to_select
;;

3 )
  if [ $vInitSystem = sysv ];
  then
    cp -r templates/trackpoint /etc/init.d && chmod +x /etc/init.d/trackpoint
    cp -r templates/trackpoint.sh /usr/bin && chmod +x /usr/bin/trackpoint.sh
    update-rc.d trackpoint start 90 5 . stop 90 0 1 2 3 4 6 .
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
  sed -i "/vSensitivity=/c\vSensitivity=$vSensitivity" templates/trackpoint.sh
  sed -i "/vSpeed=/c\vSpeed=$vSpeed" templates/trackpoint.sh
  sed -i "/vPress_to_Select=/c\vPress_to_Select=$vPress_to_Select" templates/trackpoint.sh
  cp -r templates/trackpoint.sh /usr/bin && chmod +x /usr/bin/trackpoint.sh
else
  echo "Settings not configured.  Please run \"Option 2:\" first"
fi
;;

5 )
  if [ $vInitSystem = sysv ];
  then
    update-rc.d -f trackpoint remove
    rm -f /etc/init.d/trackpoint
    rm -f /usr/bin/trackpoint.sh
  else
    systemctl disable trackpoint.timer
    systemctl stop trackpoint > /dev/null  # Output hidden since it warns about service being called by timer, but timer and service are removed below
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
