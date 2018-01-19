#!/bin/bash
echo -n 1 > /sys/devices/platform/i8042/serio1/serio2/press_to_select
echo -n 200 > /sys/devices/platform/i8042/serio1/serio2/sensitivity
echo -n 200 > /sys/devices/platform/i8042/serio1/serio2/speed
