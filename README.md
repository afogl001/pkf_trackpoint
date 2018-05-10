# pkf_trackpoint
Configure trackpoint on GNU/Linux.  This menu-driven script allows the user to
  - Adjust sensitivity, speed, and touch-to-click on the fly (not persistent between reboots)
  - Configure boot script to apply settings on boot (persistent between reboots)
  - Remove boot scripts to restore OS to original configuration

## Usage
### Run "pkf_trackpoint.sh" to configure trackpoint.
  1. Displays current settings and persistence state
  2. Apply trackpoint settings on the fly
  3. Enable persistent settings (does not apply settings)
  4. Make current settings persistent
  5. Remove all pkf_trackpoint files from systemd
  6. Sets trackpoint back to OS defaults (sensitivity=128, speed=97, press=0)
  0. Exit pkf_trackpoint

### Run "testing.sh" to check status and enable/disable test mode (for development)
Turning on test mode will redirect configuration changes to the embedded "testing" directory.

This can be useful for understanding what pkf_trackpoint is doing as well as assist in testing any changes
  - Displays current state of test mode.  
  1. Switch between testing mode being on or off and exits
  0. Exit

## Files created/modified
  - Files restored every boot (do not delete)
    + /sys/devices/platform/i8042/serio1/serio2/sensitivity
    + /sys/devices/platform/i8042/serio1/serio2/speed
    + /sys/devices/platform/i8042/serio1/serio2/press_to_select
  - Files that remain between reboots (if using persistent settings)
    + /etc/systemd/system/trackpoint.service
    + /etc/systemd/system/trackpoint.timer
    + /usr/bin/trackpoint.sh

## Tested on...
  -OpenSUSE Leap 42 (T420)

## TODO
  - Add support for SysV & Upstart
  - Combine persistences setup and application to one option
  - Ensure user is root when pkf_trackpoint is run
