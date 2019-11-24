#!/bin/bash

## Ensure script is being run as root
if ! [ $(id -u) = 0 ]; then
   echo "Pleaes run this script as root"
   exit 100
fi

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

## Initialize trackpoint varialbes with current values
vSensitivity=$(<$vTrackpointPath/sensitivity)
vSpeed=$(<$vTrackpointPath/speed)
vPress_to_Select=$(<$vTrackpointPath/press_to_select)
vScrolling="9"  # Initialize with 9 to allow test against numerical values

## Check if we need to set TrackPoint wheel
vTrackpointXconfig=$(xinput list-props "TPPS/2 IBM TrackPoint"  2> /dev/null | grep "Evdev Wheel Emulation (")

## Determine and set correct path for X11 xorg.conf.d
if [ $vTrackpointXconfig ]; then
  echo "Searching for \"xorg.conf.d\". This may take a moment..."
  for root_dir in /usr /etc  # Note order precedence from least to greatest (here, the xorg.conf.d in "/etc" will be used
  do
    vXorgDir=$(find ${root_dir} -type d -name xorg.conf.d) &> /dev/null
  done
fi

## Update template with current values (to prevent settings being changed if user uses Optoin 3 to configure persistence)
sed -i "/vSensitivity=/c\vSensitivity=$vSensitivity" templates/trackpoint.sh
sed -i "/vSpeed=/c\vSpeed=$vSpeed" templates/trackpoint.sh
sed -i "/vPress_to_Select=/c\vPress_to_Select=$vPress_to_Select" templates/trackpoint.sh

while :
do
  ## Find and set xinput values for TrackPoint scrolling
  if [ $vTrackpointXconfig ]; then
    # Capture value for scrolling setting
    vTrackpointWheelEnabledValue=$(xinput list-props "TPPS/2 IBM TrackPoint" | grep "Evdev Wheel Emulation (" | cut -d ':' -f 2 | awk '{$1=$1};1')
    # Capture value for scrolling button
    vTrackpointWheelButtonValue=$(xinput list-props "TPPS/2 IBM TrackPoint" | grep "Evdev Wheel Emulation Button (" | cut -d ':' -f 2 | awk '{$1=$1};1')
    # Update template with current values to prevent them changing if persistence is enabled
    sed -i "s/\"EmulateWheel\".*/\"EmulateWheel\"   \"${vTrackpointWheelEnabledValue}\"/" templates/90-trackpoint.conf.${vTrackpointWheelType}
    sed -i "s/\"EmulateWheelButton\".*/\"EmulateWheelButton\"   \"${vTrackpointWheelButtonValue}\"/" templates/90-trackpoint.conf.${vTrackpointWheelType}
    # We don't worry about axis/horz. scrolling as genrally, if scrolling, then horz, else it's not applicable
  fi

  ## Check status of persistence
  systemctl --version &> /dev/null
  if [ $? != 0 ]; then
    vInitSystem=sysv
    if [ -f /etc/init.d/trackpoint -a -f /usr/bin/trackpoint.sh ]; then
      vInitStatus=Enabled
    elif [ ! -f /etc/init.d/trackpoint -a ! -f /usr/bin/trackpoint.sh ]; then
      vInitStatus=Disabled
    else
      vInitStatus='Broken. Use Option 3 or 5'
    fi
  else
    vInitSystem=systemd
    if [ -f /etc/systemd/system/trackpoint.service -a -f /etc/systemd/system/trackpoint.timer -a -f /usr/bin/trackpoint.sh ]; then
      vInitStatus=Enabled
    elif [ ! -f /etc/systemd/system/trackpoint.service -a ! -f /etc/systemd/system/trackpoint.timer -a ! -f /usr/bin/trackpoint.sh ]; then
      vInitStatus=Disabled
    else
      vInitStatus='Broken.  Use Option 3 or 5'
    fi
  fi

echo ""
echo "1: Check current Trackpoint settings"
echo "2: Set Trackpoint settings"
echo "3: Configure scrolling (only required for some GNU/Linux distributions)"
echo "4: Setup persistent Trackpoint settings using current settings"
echo "5: Make current Trackpoint settings persistent"
echo "6: Remove Trackpoint persistent settings (use OS defaults)"
echo "7: Set current Trackpoint settings back to OS defaults"
echo "0: Exit"
echo " "
read vMainMenu

case $vMainMenu in
1 )
  printf "Trackpoint Sensitivity: " && cat $vTrackpointPath/sensitivity
  printf "Trackpoint Speed: " && cat $vTrackpointPath/speed
  printf "Trackpoint Press_To_Select: " && cat $vTrackpointPath/press_to_select
  printf "Persistence: $vInitStatus ($vInitSystem)\n"
;;

2 )
  printf "Sensitivity (1-255): Currently " && cat $vTrackpointPath/sensitivity
  read vTempSensitivity
  if [ "$vTempSensitivity" -lt 1 -o "$vTempSensitivity" -gt 255 ]; then
    echo "Please enter a value between 1 and 255"
    continue
  fi
  printf "Speed (1-255): Currently " && cat $vTrackpointPath/speed
  read vTempSpeed
  if [ "$vTempSpeed" -lt 1 -o "$vTempSpeed" -gt 255 ]; then
    echo "Please enter a value between 1 and 255"
    continue
  fi
  printf "Press_to_Select (0-1): Currently " && cat $vTrackpointPath/press_to_select
  read vTempPress_to_Select
  if [[ "$vTempPress_to_Select" != [0-1] ]]; then
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
  ## Update template with current values (to prevent settings being changed if user uses Optoin 3 to configure persistence)
  sed -i "/vSensitivity=/c\vSensitivity=$vSensitivity" templates/trackpoint.sh
  sed -i "/vSpeed=/c\vSpeed=$vSpeed" templates/trackpoint.sh
  sed -i "/vPress_to_Select=/c\vPress_to_Select=$vPress_to_Select" templates/trackpoint.sh
;;

3 )
  if [ $vTrackpointXconfig]; then
    echo "Toggle scrolling (0 for \"No\", 1 for \"Yes\"): Currently ${vTrackpointWheelEnabledValue}"
    read vScrolling
    if [ $vScrolling = 0 ]; then
      xinput set-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation" 0
      xinput set-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation Button" 3
      xinput set-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation Axes" 0 0 4 5
    elif [ $vScrolling = 1 ]; then
      xinput set-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation" 1
      xinput set-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation Button" 2
      xinput set-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation Axes" 6 7 4 5  # Safe to assume horz. scrolling prefered
    else
      echo "Cancelled scrolling configuration"
    fi
  else
    echo "It doesn't appear wheel emulation is handled by evdev so skipping any configuration
    since it's assumed libinput genrally enables scrolling and this is the desired state"
  fi
;;

4 )
  if [ $vTrackpointXconfig]; then
    echo "Would you like to include scrolling settings in persistence setup?
        (0 for \"No\", 1 for \"Yes\")"
    read vScrolling
    if [ $vScrolling = 1 ]; then
      echo "Copying config file to \"${vXorgDir}\""
      cp -r templates/90-trackpoint.conf.${vTrackpointWheelType} $vXorgDir/90-trackpoint.conf
    fi
  fi

  if [ $vInitSystem = sysv ]; then
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

5 )
if [ "$vInitStatus" = "Enabled" ]; then
  cp -r templates/trackpoint.sh /usr/bin && chmod +x /usr/bin/trackpoint.sh
  if [ $vScrolling = 1 ]; then
    cp -r templates/90-trackpoint.conf $vXorgDir/90-trackpoint.conf
  elif [ $vScrolling = 0 -a -f $vXorgDir/90-trackpoint.conf ]; then
    rm -f $vXorgDir/90-trackpoint.conf
  else
    echo "Skipping scrolling configuration"
  fi
else
  echo "Persistence not enabled.  Please run \"Option 4:\" first"
fi
;;

6 )
  if [ $vInitSystem = sysv -a $vInitStatus = Enabled ]; then
    update-rc.d -f trackpoint remove
    rm -f /etc/init.d/trackpoint
    rm -f /usr/bin/trackpoint.sh
    if [ -f $vXorgDir/90-trackpoint.conf ]; then
      rm -f $vXorgDir/90-trackpoint.conf
    fi
    ## Ensure current setting are not changed
    echo $vSensitivity > $vTrackpointPath/sensitivity
    echo $vSpeed > $vTrackpointPath/speed
    echo $vPress_to_Select > $vTrackpointPath/press_to_select
  elif [ $vInitSystem = systemd -a $vInitStatus = Enabled ]; then
    systemctl disable trackpoint.timer
    systemctl stop trackpoint &> /dev/null  # Output hidden since it warns about service being called by timer, but timer and service are removed below
    rm -f /etc/systemd/system/trackpoint.service
    rm -f /etc/systemd/system/trackpoint.timer
    rm -f /usr/bin/trackpoint.sh
    systemctl daemon-reload
    if [ -f $vXorgDir/90-trackpoint.conf ]; then
      rm -f $vXorgDir/90-trackpoint.conf
    fi
    ## Ensure current setting are not changed
    echo $vSensitivity > $vTrackpointPath/sensitivity
    echo $vSpeed > $vTrackpointPath/speed
    echo $vPress_to_Select > $vTrackpointPath/press_to_select
  else
    echo "Persistence not enabled.  Please run \"Option 4:\" first"
  fi
;;

7 )
echo 128 > $vTrackpointPath/sensitivity
echo 97 > $vTrackpointPath/speed
echo 0 > $vTrackpointPath/press_to_select
if [ $vScrolling < 9 ]; then
  echo "Reseting scrolling configuration not supported as it could potentially affect
  configurations not controlled by this script.  If you used this option, it's likely
  the default was disabled.  Run \"Optoin 3:\" and pass \"0\" to return to a disabled state"
fi
;;

0 | [eE]xit )
  exit
;;

* )
  echo "Pleaes enter a valid option"
esac
done
