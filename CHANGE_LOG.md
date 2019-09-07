- v0.0.1:
  + Non-working initial save
- v0.0.2
  + Non-working checkpoint
  + Configure "testing" & "template" directories
  + Add variable null check to option 4
  + Change exit case to "0"
  + Add actual configuration to systemd files
##### v1.0.0
  + Remove redirections to testing directory
  + Change main script's name
- v1.0.1
  + Uncomment systemctl commands
- v1.1.0
  + Add toggle to enable/disable test mode
- v1.1.1
  + Fix README file
- v1.1.2
  + Fix README file
  + Disable test mode
##### v1.2.0
  + Additional info in "Check Settings"
  + Streamline newlines for main menu for pkf_trackpoint and testing
  + Add "Remove persistence" option
  + Update README
- v1.2.1
  + Minor README fix
##### v1.3.0
  + Add compatability with no/disabled trackpad devices
  + Add testing toogle to add/remove trackpad paths.
- v1.3.1
  + Remove trackpad-less TODO from README
  + Add systemd reload when enabling persistence
- v1.3.2
  + Fix typo in setting persistence
  + Set trackpoint.sh initial template to OS defaults
  + Update README with tested laptops
- v1.3.3
  + Fix testing.sh for trackpad testing
  + Change testing.sh trackpoint settings to OS defaults
- v1.3.4
  + Add systemctl stop/daemon-reload to persistence removal
- v1.3.5
  + Fix typo in systemctl stop for persistence removal
##### v1.4.0
  + Add reset current Trackpoint settings to defaults
##### v1.5.0
  + Use path unit instead of timer unit
  + Add conditional option to remove pre-v1.5 settings
- v1.5.1
  + Fix type in timer removal in option 5
  + Change timer to path in persistence check and option 3
  + Change "enable" to "trackpoint" in option 3
- v1.4.1
  + Revert back to v1.4
  + Add condition triggers for systemd service
- v1.4.2
  + Disable testing mode (left enabled by mistake)
##### v1.5.0
  + Removed due to missing features for systemd's path unit
##### v1.6.0
  + Add Sys V init for Debian based distros
  + Add complete addition/removal of testing directory in test toggle
- v1.6.1
  + Make Sys V init only run at level 5
  + Add LSB info to Sys V script
  + Update menu text in pkf_trackpoint
- v1.6.2
  + Allow output of persistence setting but hide systemd service stop (non-applicable warning about being called by timer)
##### v1.7.0
  + Enable stop/restart for persistence settings
  + Add conditional to trackpad detection for if neither exists (exit 200)
  + Reset default setting values in trackpoint.sh when disabling test mode
- v1.7.1
  + Add missing command to apply changes if re-running Option 4 (applying current settings to persistence )
  + Fix SysV output being hidden when using Option 3 (setting up persistence)
  + Update CHANGELOG
- v1.7.2
  + Remove command to start trackpoint.sh in Option 4 (redundant since settings already applied in Option 2)
- v1.7.3
  + Add initially tested OS/Laptops to README
##### v1.8.0
    + Add check for root user
    + Add validation of setting values
    + Prevent using values entered if any are not valid
    + Display current corresponding trackpoint setting when setting new values
    + Add better detection of trackpoint existence
    + Initialize trackpoint variables with current setting values
  - v1.8.1
    + Fix missing validation of persistence before applying option 4 (apply current settings to persistence)
    + Fix redirection of systemd warnings when disabling persistence (can be safely ignored as timer unit is also deleted)
    + Tweak persistence detection and reporting
    + Change systemd timer from "OnBootSec" to "OnActiveSec"
  - v1.8.2
    + Add trackpoint path for KDE Neon
  - v1.8.3
    + Fix typo in KDE Neon support
    + Add systemd conditional for KDE Neon
  - v1.8.4
    + Update template with current settings at start and on setting (Option 2) to prevent settings being undone when setting persistence (Option 3)
