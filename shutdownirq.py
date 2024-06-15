#!/usr/bin/python3
# ATXRaspi interrupt based shutdown/reboot script
# Script based on Tony Pottier, Felix Rusu
# modified by Juergen Schweighoer
# migrated to lgpio for LE12 by HungerHa
#
# Changed on: 2024-06-15 18:48
# Version: 0.0.1
#
# Changelog:
# 0.0.1 2024-06-15
# - removed infinity loop and some other logic errors
# - cosmetic changes
# - migrated from RPi.GPIO to lgpio

import os
import time
import sys
sys.path.append("/storage/.kodi/addons/virtual.rpi-tools/lib")

# workaround for lgpio issue
# https://github.com/gpiozero/gpiozero/issues/1106
os.environ['LG_WD'] = '/tmp'
import lgpio

REBOOTPULSEMINIMUM = 0.2 # reboot pulse signal should be at least this long (second)
REBOOTPULSEMAXIMUM = 1.0 # reboot pulse signal should be at most this long (seconds)
SHUTDOWN = 4             # GPIO used for shutdown signal
BOOT = 17                # GPIO used for boot signal

pulseStart = 0.0
power_btn_triggered = False

# Initialize GPIO
lgpio.exceptions = False
h = lgpio.gpiochip_open(4)
if h >= 0:
    # Pi5 mapping
    chip = 4
else:
    # Old mapping
    chip = 0
    h = lgpio.gpiochip_open(0)
lgpio.exceptions = True

# Set BOOT pin to high level to signal that the PI has booted up
lgpio.gpio_claim_output(h, BOOT, 1, lFlags=lgpio.SET_PULL_NONE)

# Set SHUTDOWN pin with pull down as interrupt (rising edge) for the shutdown signal
lgpio.gpio_claim_alert(h, SHUTDOWN, eFlags=lgpio.RISING_EDGE, lFlags=lgpio.SET_PULL_DOWN)

def power_btn_pressed(chip=None, gpio=None, level=None, timestamp=None):
    global power_btn_triggered
    power_btn_triggered = True

cb_power_btn = lgpio.callback(h, SHUTDOWN, edge=lgpio.RISING_EDGE, func=power_btn_pressed)

print ("\n==========================================================================================")
print (" ATXRaspi shutdown IRQ script started, to observe power button events")
print (" Pin configuration: SHUTDOWN = GPIO" + str(SHUTDOWN) + " (input, LOW) / BOOT = GPIO" + str(BOOT) + " (output, HIGH)")
print (" Waiting for GPIO" + str(SHUTDOWN) + " to become HIGH (short pulse = REBOOT, long pulse = SHUTDOWN)")
print ("==========================================================================================")
try:
    while True:
        # wait for rising edge at SHUTDOWN pin
        time.sleep(0.01)
        if power_btn_triggered:
            power_btn_triggered = False
            # get the current state of SHUTDOWN pin and measure time window
            shutdownSignal = lgpio.gpio_read(h, SHUTDOWN)
            pulseStart = time.time() # register time at which the button was pressed
            while shutdownSignal == 1:
                if (time.time()-pulseStart) > REBOOTPULSEMAXIMUM:
                    print ("\n=====================================================================================")
                    print (" SHUTDOWN request from GPIO" + str(SHUTDOWN) + ", halting RPi ...")
                    print ("=====================================================================================")
                    os.system("poweroff")
                    sys.exit()
                time.sleep(0.01)
                shutdownSignal = lgpio.gpio_read(h, SHUTDOWN)
            if (time.time()-pulseStart) > REBOOTPULSEMINIMUM:
                print ("\n=====================================================================================")
                print (" REBOOT request from GPIO " + str(SHUTDOWN) + ", restarting RPi ...")
                print ("=====================================================================================")
                print ("Delta time: ",time.time() - pulseStart)
                os.system("reboot")
                sys.exit()
except:
    pass
finally:
    cb_power_btn.cancel()
    cb_power_btn = None
    lgpio.gpio_free(h, SHUTDOWN)
    lgpio.gpiochip_close(h)
