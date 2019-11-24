# pkf_trackpoint
Configure TrackPoint on GNU/Linux.  This menu-driven script allows the user to
  - Adjust sensitivity, speed, and touch-to-click on the fly (not persistent between reboots)
  - If distribution uses 'evdev' for xinput (such as RHEL/CentOS), toggle TrackPoint scrolling
  - Configure boot script to apply settings on boot (persistent between reboots)
  - Remove boot scripts to restore OS to original configuration

## Usage
### Run "pkf_trackpoint.sh" to configure trackpoint.
  1. Displays current settings and persistence state
  2. Apply trackpoint settings on the fly
  3. Toggle TrackPoint scrolling (only for GNU/Linux distos using "evdev")
  4. Enable persistent settings (using current settings).  User may then manually edit /usr/bin/trackpoint.sh as they desire
  5. Make current settings persistent
  6. Remove all pkf_trackpoint files from initialization daemon
  7. Sets trackpoint back to OS defaults (sensitivity=128, speed=97, press=0)
  0. Exit pkf_trackpoint

### Run "testing.sh" to check status and enable/disable test mode (for development)
Turning on test mode will redirect configuration changes to the embedded "testing" directory.

This can be useful for understanding what pkf_trackpoint is doing as well as assist in testing any changes
  - Displays current state of test mode.
  - Displays whether fake trackpad exists
  1. Switch between testing mode being on or off
  2. Toggles whether a fake trackpad exists or not
  0. Exit

## Files created/modified
  - Files restored every boot (do not delete)
    + /sys/devices/<...>/sensitivity
    + /sys/devices/<...>/speed
    + /sys/devices/<...>/press_to_select
  - Files that remain between reboots (if using persistent settings)
    + /etc/systemd/system/trackpoint.service (systemd)
    + /etc/systemd/system/trackpoint.timer (systemd)
    + /etc/init.d/trackpoint (SysV)
    + /usr/bin/trackpoint.sh
    + /<usr|etc>/.../xorg.conf.d/90-trackpoint.conf

## Should work on...
  - Ubuntu/Kubuntu (15.04 and later)
  - OpenSUSE Leap & Tumbleweed
  - Trisqel
  - KDE Neon
  - CentOS

## Exit codes
  - 100: Script not run as root (required since system file are being changed)
  - 200: Trackpoint not detected (or at least common Trackpoint sys directories do not appear to exist.)

## Variables used
  - file = temporary variable used in FOR loop to capture locations of files named "press_to_select" located in /sys/devices directory
  - dir = temporary variable used in FOR loop to capture the parent directory of each $file found
  - root_dir = temporary variable used in FOR loop to capture starting directory for finding xorg.conf.d (value used for vXorgDir)
  - vTrackpointPath = Path to Trackpoint settings. Varies based on existence of a trackpad ( sys/devices/platform/i8042/serio1 | sys/devices/platform/i8042/serio1/serio2 )
  - vInitSystem = Detected initialization service used ( sysv | systemd )
  - vInitStatus = Current status of persistence ( Enabled | Disabled | Broken. Use Option 3 or 5)
  - vMainMenu = Selected option from menu ( [0-6] )
  - vTempSensitivity = Pre-vallidation value for sensitivity setting ( [1-255] )
  - vTempSpeed = Pre-vallidation value for speed setting ( [1-255] )
  - vTempPress_to_Select = Pre-vallidation value for press_to_select setting ( [0-1] )
  - vSensitivity = Validated value for sensitivity setting ( [1-255] )
  - vSpeed = Validated value for speed setting ( [1-255] )
  - vPress_to_Select = Validated value for press_to_select setting ( [0-1] )
  - vScrolling = Track user selection for TrackPoint scrolling, defaults to "9". "0" is disabled, "1" is enabled. ( [0-1] | 9)
  - vTrackpointXconfig = Holds data if using evdev for xinput, empty if not. (<some output> | <empty> )  
  - vXorgDir = Locatoin of xorg.conf.d for setting scrolling persistence (<xorg.conf.d path> | <empty>)
  - vTrackpointWheelEnabledValue = Current value of "Evdev EmulateWheel. "0" is disabled, "1" is enabled. ([0-1] | <empty>)
  - vTrackpointWheelButtonValue  Current value of "Evdev EmulateWheelButton".  Anything except "2" is in a "disabled" state ([2-4])

## TODO
  - Add support for SysV (non-Debian) & Upstart
  - Find better initialization than timer for systemd
