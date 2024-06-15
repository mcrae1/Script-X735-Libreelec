#!/bin/bash
# Since kernel version 6.5.x sysfs-gpio is deprecated and could be
# a breaking change in the future too. Also the gpiochip numbering was
# unified for all platforms. Now it's needed to use another offset to
# address the GPIOs at the 40-pin header of the RPi.
# With older kernel versions the offset was 0. Now the offset is: 512
# The design of RPi5 uses the new RP1 I/O chip and the offset differs
# to previous RPi generations: 571
#
# GPIO4 + Offset = GPIO516
# GPIO17 + Offset = GPIO529
#
# Changed on: 2024-06-15 11:37
# Version: 0.0.1
#
# Changelog:
# 0.0.1 2024-06-15
# - offset of 512 for RPi4 added to the GPIO number
# - cosmetic changes

SHUTDOWN=516 # GPIO 4
REBOOTPULSEMINIMUM=200
REBOOTPULSEMAXIMUM=600
echo "$SHUTDOWN" > /sys/class/gpio/export
echo "in" > /sys/class/gpio/gpio$SHUTDOWN/direction
BOOT=529 # GPIO 17
echo "$BOOT" > /sys/class/gpio/export
echo "out" > /sys/class/gpio/gpio$BOOT/direction
echo "1" > /sys/class/gpio/gpio$BOOT/value

echo "X735 Shutting down..."

while [ 1 ]; do
  shutdownSignal=$(cat /sys/class/gpio/gpio$SHUTDOWN/value)
  if [ $shutdownSignal = 0 ]; then
    /bin/sleep 0.2
  else
    pulseStart=$(date +%s%N | cut -b1-13)
    while [ $shutdownSignal = 1 ]; do
      /bin/sleep 0.02
      if [ $(($(date +%s%N | cut -b1-13)-$pulseStart)) -gt $REBOOTPULSEMAXIMUM ]; then
        echo "X735 Shutting down", SHUTDOWN, ", halting RPi ..."
        poweroff
        exit
      fi
      shutdownSignal=$(cat /sys/class/gpio/gpio$SHUTDOWN/value)
    done
    if [ $(($(date +%s%N | cut -b1-13)-$pulseStart)) -gt $REBOOTPULSEMINIMUM ]; then
      echo "X735 Rebooting", SHUTDOWN, ", restarting RPi ..."
      reboot
      exit
    fi
  fi
done
