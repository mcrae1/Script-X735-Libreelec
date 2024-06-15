#!/bin/bash
# Since kernel version 6.5.x sysfs-gpio is deprecated and could be
# a breaking change in the future too. Also the gpiochip numbering was
# unified for all platforms. Now it's needed to use another offset to
# address the GPIOs at the 40-pin header of the RPi.
# With older kernel versions the offset was 0. Now the offset is: 512
# The design of RPi5 uses the new RP1 I/O chip and the offset differs
# to previous RPi generations: 571
#
# GPIO18 + Offset = GPIO530
#
# Changed on: 2024-06-15 11:40
# Version: 0.0.1
#
# Changelog:
# 0.0.1 2024-06-15
# - offset of 512 for RPi4 added to the GPIO number

BUTTON=530 # GPIO 18

#setup GPIO 18 as output and set to HIGH
echo "$BUTTON" > /sys/class/gpio/export;
echo "out" > /sys/class/gpio/gpio$BUTTON/direction
echo "1" > /sys/class/gpio/gpio$BUTTON/value

SLEEP=4 #4 for shutdown 1 for reboot.

echo "X735 Shutting down..."
/bin/sleep $SLEEP

#restore GPIO 18
echo "0" > /sys/class/gpio/gpio$BUTTON/value
