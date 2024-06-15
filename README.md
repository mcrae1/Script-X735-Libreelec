# Geekworm X735 shut down scripts for LibreELEC 12/13

Currently I'm trying to provide a fixed version for the repository of mcrae1 only, because I know about the existing root causes.

Starting with kernel version 6.5.x sysfs-gpio is deprecated and could be a breaking change in the future too. Also the gpiochip numbering was unified for all platforms.

Now it's needed to use another offset to address GPIOs the RPi's 40-pin header.
With older kernel versions the offset was 0. Now the offset is: 512
The new hardware design of RPi5 uses the new RP1 I/O chip and the offset differs to previous RPi generations: 571

I doesn't have such kind of hardware (Geekworm X735, ATXRaspi ...) to test it by self.
If you have such kind of hardware, you are invited to test these scripts against LibreELEC 12/13 and give feedback via the issue tracker.

The origin of that scripts seems here: <https://github.com/LowPowerLab/ATX-Raspi>

## 2024-06-15

These scripts should now work with RPi4 and older generations with LE12, but are currently untested:

- shutdown_x735.sh
- softshutdown.sh
- shutdownirq.py

## Work in progress

- migration of the shell scripts to pinctrl
