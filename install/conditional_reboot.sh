#!/usr/bin/env bash

# If chrome is not running - reboot
if ! pgrep -x "chrome" > /dev/null
then
    sudo reboot now
fi