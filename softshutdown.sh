#!/bin/bash
BUTTON=18

#setup GPIO 18 as output and set to HIGH
echo "$BUTTON" > /sys/class/gpio/export;
echo "out" > /sys/class/gpio/gpio$BUTTON/direction
echo "1" > /sys/class/gpio/gpio$BUTTON/value

SLEEP=4 #4 for shutdown 1 for reboot.

echo "X735 Shutting down..."
/bin/sleep $SLEEP

#restore GPIO 18
echo "0" > /sys/class/gpio/gpio$BUTTON/value
