#!/bin/bash
echo -n 150 > /sys/devices/platform/i8042/serio1/serio2/sensitivity
echo -n 150 > /sys/devices/platform/i8042/serio1/serio2/speed
echo -n 0 > /sys/devices/platform/i8042/serio1/serio2/press_to_select
