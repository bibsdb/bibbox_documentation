#! /bin/sh

# Create Elo Devices for communication
/etc/opt/elo-mt-usb/eloCreateFifo.sh

# Load the PC speaker kernel module into memory for Beep-On-Touch 
# Disable this module because ARM platform does not support it

platform_arch=`uname -m`

if [ $platform_arch != "aarch64" ] && [ $platform_arch != "armv7l" ]
then
  modprobe pcspkr
fi

sleep 1

# Load the Elo USB Touchscreen Daemon into memory
/etc/opt/elo-mt-usb/elomtusbd --mtdigitizer

