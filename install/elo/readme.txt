===============================================================================

              Elo Touchscreen Linux Driver - Multi Touch (MT) USB

   Intel i686 (32 bit) or AMD64/Intel (64 bit) or ARMv7l (32 bit) or ARMv8 (64 bit)

              Installation/Calibration/Uninstallation Instructions

--------------------------------------------------------------------------------

                                 Version 4.3.0 
                               November 04, 2022
                              Elo Touch Solutions

================================================================================

Elo Linux MT USB Driver package contains userspace Linux drivers designed for 
Linux kernel 5.x, 4.x, 3.x, video alignment utility and control panel utilities 
for Elo touchmonitors. This driver requires the presence of libusb-1.0 shared 
library and uinput kernel module on the target system for its operation.The 
standard driver supports a single and multiple touchscreens setup.


This readme file is organized as follows:

  1. Supported Touchmonitors and Elo Touchscreen Controllers
  2. System Requirements
  3. Installing the Elo Touchscreen USB Driver
  4. USB Driver Commandline Options and Usage
  5. Calibrating the Touchscreen
  6. Accessing the Control Panel
  7. Uninstalling the Elo Touchscreen USB Driver
  8. Troubleshooting
  9. Contacting Elo Touch Solutions




==========================================================
1. Supported Touchmonitors and Elo Touchscreen Controllers
==========================================================

 - Elo Multi-Touch(MT) USB Controllers
    TouchPro PCAP controllers,
    IntelliTouch Plus/iTouch Plus 2515-07(non HID), 2521, 2515-00, 3200XX,
    Multi Touch IR controllers

 - Elo Single-Touch(ST) USB Controllers 
    IntelliTouch(R) 2701, 2700, 2600, 2500U, 
    CarrollTouch(R) 4501, 4500U, 4000U, 
    Accutouch(R) 2218, 2216, 3000U,
    Surface Capacitive 5020, 5010, 5000,
    Accoustic Pulse Recognition(APR) Smartset 7010
    and other Elo Smartset ST USB controllers 

 - Elo Multiple touch monitors


======================
2. System Requirements
======================

Visit the Linux downloads section at www.elotouch.com to download the driver
package for your 32 bit Intel, 64 bit AMD/Intel, 32 bit ARM v7l, 64 bit ARM v8 Linux.

 - 32 bit Intel i686 (x86) platform (or)
   64 bit AMD/Intel x86_64 platform 
   32 bit ARM v7l platform
   64 bit ARM v8 platform

 - Kernels supported:
    Kernel version 5.x.x
    Kernel version 4.x.x
    Kernel version 3.x.x

 - Xorg Xwindows version supported:
    Xorg version 6.8.2 - 7.2
    Xorg Xserver version 1.3 and newer

 - Motif versions supported:
    Motif version 3.0 (libXm.so.3)

 - libusb versions supported:
    libusb version 1.0.9 or later

 - Uinput kernel module versions supported:
    uinput version 0.4 or later




===============================================
3. Installing the Elo Touchscreen USB Driver
===============================================

Important:
==========
a.) Must have root or administrator access rights on the Linux machine to 
    install the Elo Touchscreen USB Driver.

b.) Ensure all earlier Elo drivers are uninstalled from the system. Follow the 
    uninstallation steps from the old driver's readme.txt file to remove the old 
    driver completely.

c.) The Elo Touchscreen driver components require libusb-1.0 library support 
    (older libusb-0.1 library will not work). Most Linux distributions have 
    started shipping this library (update to the popular libusb-0.1 library) as 
    a part of their standard release. Customers can also download and compile 
    the libusb-1.0 library from source (requires gcc v4.0.0 or later) available 
    at libusb website. This driver will NOT work with the older libusb-0.1 
    library.

d.) Do not extract the downloaded binary package on a Windows system.

e.) Motif 3.0 (libXm.so.3) library is required to use the Graphic User Interface 
    (GUI) based control panel (/etc/opt/elo-mt-usb/cpl). Openmotif or lesstif 
    installation packages provide the required libXm.so.3 library.



Step I:
-------

Copy the elo driver files from the binary folder to the default elo folder.
Change the permissions for all the elo driver files. These broad permissions 
are provided to suit most systems. Please change them to tailor it to your 
access control policy and for specific groups or users.

  a.) Copy the driver files to /etc/opt/elo-mt-usb folder location.

       # cp -r ./bin-mt-usb/  /etc/opt/elo-mt-usb


  b.) Use the chmod command to set full permissions for all the users for the 
      /etc/opt/elo-mt-usb folder (read/write/execute). These broad permissions 
      are provided to suit most systems. Please change them to tailor it to your 
      access control policy and for specific groups or users.

       # cd /etc/opt/elo-mt-usb
       # chmod 777 *
       # chmod 444 *.txt


  c.) Copy the udev rules file to /etc/udev/rules.d/ folder location. Please 
      edit touchscreen device permissions to tailor it to your access control 
      policy and for specific groups or users.

       # cp /etc/opt/elo-mt-usb/99-elotouch.rules /etc/udev/rules.d




Step II: [Linux distributions with systemd init system]
--------

Install a script to invoke Elo service through systemd init at system startup. 
Check if systemd init is being used in your Linux distribution and then proceed
with this installation step. If systemd init is not active, proceed with Step 
III of the installation.

Check for active systemd init process.

 # ps -eaf | grep [s]ystemd
 # ps -eaf | grep init
 # ls -l /sbin/init 


If systemd init system is active, copy and enable the elo.service systemd 
script to load the elo driver at startup. Proceed to Step IV of the 
installation.

 # cp /etc/opt/elo-mt-usb/elo.service /etc/systemd/system/
 # systemctl enable elo.service
 # systemctl status elo.service


Note:
----
From MTUSB v4.2, to run on VMWare machine, we need to use --vm option
  edit file:        /etc/opt/elo-mt-usb/loadEloMultiTouchUSB.sh
  add --vm option:  /etc/opt/elo-mt-usb/elomtusbd --mtdigitizer --vm



Step III: [Linux distributions with sysvinit or Upstart or older init system]
---------

Install a script to invoke Elo service on older init systems (non systemd) at 
system startup. 

Redhat, Fedora, Mandrake, Slackware, Mint, Debian and Ubuntu systems:
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Add the following line at the end of daemon configuration script in 
"/etc/rc.local" file.

[ rc.local file might also be at location /etc/rc.d/rc.local. Use the
"# find /etc -name rc.local" command to locate the rc.local file.]


  /etc/opt/elo-mt-usb/loadEloMultiTouchUSB.sh


Update:
  - For Ubuntu v18.04.x LTS or later, if there is no rc.local file, we need to 
    create it by following steps:

      1. Create rc.local file under /etc folder, and enter following texts.

         #!/bin/sh -e

         /etc/opt/elo-mt-usb/loadEloMultiTouchUSB.sh  
         exit 0

      2. Save the file
      3. Change the file to execable mode by following command:
         # chmod 755 rc.local

  - For RedHat and its family OS,due to OS security permission setting, you can disable the SELinux by editing the /etc/selinux/config:

     # This file controls the state of SELinux on the system.
   	 # SELINUX= can take one of these three values:
   	 # enforcing - SELinux security policy is enforced.
   	 # permissive - SELinux prints warnings instead of enforcing.
   	 # disabled - No SELinux policy is loaded.
   	 SELINUX=disabled
         # SELINUXTYPE= can take one of these three values:
         # targeted - Targeted processes are protected
         # minimum -Modification of targeted policy. Only selected processes are protected.
         # mls - Multi Level Security protection.
         SELINUXTYPE=targeted



SUSE Systems:
- - - - - - -

Add the following line at the end of the configuration script in
"/etc/init.d/boot.local" file.


  /etc/opt/elo-mt-usb/loadEloMultiTouchUSB.sh



Step IV:
--------

Plug in the USB touchscreen and reboot the system to complete the driver
installation process.

  # shutdown -r now




===========================================
4. USB Driver Commandline Options and Usage
===========================================

The USB (elomtusbd) driver commandline options are listed below. If required, 
modify the /etc/opt/elo-mt-usb/loadEloMultiTouchUSB.sh script file to add 
commandline options to the elomtusbd driver startup.   

  --help                                           
      Print usage information and available options

  --version                                        
      Display USB touchscreen driver version information

  --absmouse
      Set the input device to absolute mouse. Absolute mouse input device sends 
      mouse events corresponding to the primary touch only. In this mode the 
      MTUSB driver sends BTN_LEFT, ABS_X and ABS_Y input events. This mode is 
      useful to support legacy applications or older Linux kernels, which are 
      not aware of ST or MT digitizer devices or digitizer events. Use evtest
      application to test the touchscreen in this mode.

  --stdigitizer
      Set the input device to Single Touch(ST) digitizer. The ST digitizer input 
      device sends single touch digitizer events corresponding to the primary 
      touch only. In this mode the MTUSB driver sends BTN_TOUCH, ABS_PRESSURE, 
      ABS_X and ABS_Y input events. This mode is useful to support legacy 
      applications or older Linux kernels, which are not aware of MT digitizer 
      devices or multi touch digitizer events. It can be used to retrict the 
      number of touches sent to Linux kernel to just one(primary touch) and 
      avoid triggering multi touch system gestures. Use evtest application to 
      test the touchscreen in this mode.

  --mtdigitizer 
      Set the input device to Multi Touch(MT) digitizer. The MT digitizer input 
      device is the default selection and it sends multi touch digitizer events 
      corresponding to the Linux Multi Touch protocol. In this mode the MTUSB 
      driver sends ABS_MT_PRESSURE, ABS_MT_POSITION_X and ABS_MT_POSITION_Y 
      input events. This mode is useful to support the latest multi touch aware 
      applications or multi touch system gestures on newer Linux kernels. Please 
      note that the number of touches reported to the top level application 
      depends on the Linux distribution and some multi touch events could be 
      filtered to report system level gestures. Some Linux desktop elements 
      including the mouse pointer may not respond in this pure multitouch mode, 
      since they listen to mouse or ST digitizer events only. Use evtest or QT5 
      multitouch aware applications to test the touchscreen in this mode.



Usage Examples:    
---------------

  elomtusbd --help                              
    Print usage information and available options

  elomtusbd --version   
    Display USB touchscreen driver version information

  elomtusbd --absmouse               
    Set the input device to absolute mouse - BTN_LEFT, ABS_X and ABS_Y events

  elomtusbd --stdigitizer               
    Set the input device to single touch digitizer - BTN_TOUCH, ABS_X, ABS_Y and 
    ABS_PRESSURE events

  elomtusbd --mtdigitizer                     
    Set the input device to multi touch digitizer - ABS_MT_PRESSURE, 
    ABS_MT_POSITION_X and ABS_MT_POSITION_Y events




==============================
5. Calibrating the Touchscreen
==============================

Important:
==========

Users must have read and write access to "/dev/elo-mt-usb" and 
"/etc/opt/elo-mt-usb" directories to perform the touchscreen calibration. All 
long commandline options in elova calibration utility use the "--" format. 
(example: "--help")

Type "# /etc/opt/elo-mt-usb/elova --help" for available command line
parameters and usage.


Note 1:
  If the touch coordinators are corrected, please do not use “elova” to transform 
  a touch coordinator again.

Use cases:
  The “elova” utility is designed for touch calibration on legacy Elo monitors such
  as AT, IT monitor models.  By default, the touch coordinators of the AT, IT monitors
  are not corrected, we need to use “elova” utility to correct them.

  In the case of rotated AT, IT touch monitors, we also need “elova” to re-calibrate
  for the touch coordinators.  However, when we rotate the touchscreen with a
  transformation matrix applied, the touch coordinators are rotated with a 
  touchscreen; then, we do not need to run “elova” tool. 
 
  On the other hand, most of the cases of rotating PCAP touch monitors, the touch 
  coordinators are automatically rotated with the touchscreen (handled by the OS). We 
  don’t need to use “elova” to transform the touch coordinators again.


Note 2:
  For multiple touch monitors, please do configure "map-to-output" first before using elova
  to transform the touch coordination.




Step I:
-------

Run the calibration utility from a command window in X Windows from the
/etc/opt/elo-mt-usb directory for a single or multiple video setup
(supports Xorg Xinerama, Xorg non-Xinerama and Nvidia Twinview options).

  # cd /etc/opt/elo-mt-usb
  # ./elova


In a multiple video setup, the calibration target(s) will be shown on the
first video screen and switch to the next video screen after a 30 second
default timeout for each target or screen. Once the touchscreen is
calibrated the data is stored in a configuration file on the hard disk. To
display the calibration targets on just one specific video
screen(example:videoscreen[1]) use the command shown below.

  # cd /etc/opt/elo-mt-usb
  # ./elova --videoscreen=1


To change or disable the default calibration timeout for each target or
screen, use the command shown below. [Timeout Range: Min=0 (no timeout),
Max=300 secs, Default=30 secs]

  # cd /etc/opt/elo-mt-usb

  # ./elova --caltargettimeout=0      [Disable the calibration timeout for all 
                                       targets and videoscreens]

  # ./elova --caltargettimeout=45     [Modify the calibration timeout to 45 
                                       seconds]


To view a list of video and USB touch devices available for calibration,
use the command shown below.

  # cd /etc/opt/elo-mt-usb
  # ./elova --viewdevices


To view all the available options and specific usage for elova calibration
program, use the command shown below.

  # cd /etc/opt/elo-mt-usb
  # ./elova --help


Step II:
--------

Touch the target(s) from a position of normal use. The calibration data is
written to the driver at the end of calibration.




==============================
6. Accessing the Control Panel 
==============================

The control panel application allows the user to easily set the available driver 
configuration options. After the driver package is installed, change to the 
/etc/opt/elo-mt-usb directory and run the control panel application(cpl or cplcmd). 


Important:
==========

Users must have read and write access to "/dev/elo-mt-usb" folder to run the 
control panel applications.


Step I:
-------

Run the control panel utility with root privileges from a command window in X 
Windows from the /etc/opt/elo-mt-usb directory. Motif version 3.0 (libXm.so.3) is 
required to use the GUI based control panel (/etc/opt/elo-mt-usb/cpl). If Motif or 
GUI control panel(cpl) is not present, use the command line version of the 
application(cplcmd) in Step III.

  # cd /etc/opt/elo-mt-usb
  # sudo ./cpl 


Step II:
--------

Navigate through the various tabs by clicking on them. Here is an overview of 
information related to each tab.

  General       - Perform touchscreen calibration
  Sound         - Change Beep on Touch Parameters (Enable/Disable Beep, Beep 
                  Tone, Beep Duration)
  Touchscreen-0 - Display data related to the USB touchscreen 0.
  About         - Information about the package. Click on the Readme button to 
                  open this Readme file.
	

Step III:
---------

If Motif is not installed or GUI control panel(cpl) is not present, use the 
command line version of the application(cplcmd) to access the control panel. Run 
the command line application from a command window in X Windows from the 
/etc/opt/elo-mt-usb directory.

  # cd /etc/opt/elo-mt-usb
  # sudo ./cplcmd




=================================================
7. Uninstalling the Elo Touchscreen USB Driver
=================================================


Important:
==========
Must have root or administrator access rights on the Linux machine to uninstall 
the Elo Touchscreen USB Driver.



Step I:
-------

Delete the script or commands that invoke Elo service at startup.

Linux with Systemd init system:
-------------------------------

Disable and remove the elo.service startup script registered with systemd init 
system in Step II of Installation section.

  # systemctl status elo.service
  # systemctl stop elo.service
  # systemctl disable elo.service
  # systemctl status elo.service
  # rm -rf /etc/systemd/system/elo.service


Linux with sysvinit or Upstart or older init system:
----------------------------------------------------

SUSE systems:
- - - - - - -
Remove the following entry created in Step III of Installation section from the 
configuration script in"/etc/init.d/boot.local" file.

  /etc/opt/elo-mt-usb/loadEloMultiTouchUSB.sh


Redhat, Fedora, Mandrake, Slackware, Mint, Debian and Ubuntu systems:
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Remove the following entry created in Step III of Installation section from the 
configuration script in "/etc/rc.local" file. (or "/etc/rc.d/rc.local" file)

  /etc/opt/elo-mt-usb/loadEloMultiTouchUSB.sh



Step II:
--------

Delete all the elo driver files from the system.

  a.) Delete the main elo driver folder.

        # rm -rf /etc/opt/elo-mt-usb


  b.) Delete the elo related device folder and files.

        # rm -rf /dev/elo-mt-usb
        # rm -rf /etc/udev/rules.d/99-elotouch.rules



Step III:
---------

Reboot the system to complete the driver uninstallation process.

  # shutdown -r now




==================
8. Troubleshooting
==================

A. Make sure libusb-1.0 library is installed on the target Linux system. The 
   driver will NOT work with the older libusb-0.1 library. Most Linux 
   distributions ship with the newer libusb-1.0 library installed by default. It 
   can also be installed by downloading and compiling the library source 
   (requires gcc v4.0.0 or later) from the libusb-1.0 website.


B. If touch is not working, check if the elomtusbd driver is loaded and 
   currently available in memory. Some Xorg Xserver versions terminate the 
   touchscreen driver upon user logout. The current workaround in this situation 
   is to startup the driver from Xwindows startup script or reboot the system.

     # ps -e |grep elo

   Check the driver log file for any errors that have been reported.

     # gedit /var/log/elo-mt-usb/EloUsbErrorLog.txt

   If the driver is not present then load the driver again. Root access is
   needed to load the driver manually. Normal users will have to restart the 
   system so that the elomtusbd daemon is loaded again during system startup. 
   Normal users may be able to load the driver manually depending on access 
   control and file permissions that are setup.

     # /etc/opt/elo-mt-usb/elomtusbd


C. If starting the Elo touchscreen driver from the normal startup locations like 
   rc.local or boot.local does not work, first test if the touchscreen is 
   working by manually launching the driver from a terminal window within 
   XWindows graphics desktop session.

     # sudo /etc/opt/elo-mt-usb/loadEloMultiTouchUSB.sh

   If the touchscreen works when the driver is launched manually, try to add the 
   touchscreen driver startup line to the end of one of the XWindows startup 
   scripts. The Xwindows startup scripts are located usually in the following 
   path /etc/X11/xinit/xinitrc.d/. Running the touchscreen driver from the 
   Xwindows startup script will provide touch input ONLY after the user has 
   logged in successfully at the GUI Login screen.


D. Beep-on-touch feature does not work in the GUI control panel sound tab (Beep 
   Test button) or if the driver is loaded manually from a non-root user 
   context. The driver has to be loaded from a system startup script or root 
   user account for beep-on-touch to function properly. The beep on touch 
   feature also depends on the pcspkr(PC Speaker) kernel module. Ensure that the 
   pcspkr kernel module is loaded and active in memory using the lsmod command.
   Some distributions blacklist the pcspkr kernel module, which will not allow 
   this kernel module to function. Remove it from the blacklist file and then 
   try loading the module again.  


E. While trying to load the driver manually, if you get an error "Error opening 
   USB_ERROR_LOG_FILE", check the file permissions for the 
   /var/log/elo-mt-usb/EloUsbErrorLog.txt file. The user needs to be the root 
   user or have read and write access to this log file to launch the driver. Try 
   using the sudo command to launch the driver manually, if its a non root user.


F. In a multi video setup, the touchscreen can be mapped to just one 
   videoscreen. First find the name of the video port (example: VGA-1, HDMI-0, 
   DVI-0) that connects to the desired videoscreen, using the xrandr command in
   a terminal window.

     # xrandr

   Next, find the device ID (id=xx) of the Xinput pointer device "Elo 
   MultiTouch(MT) Device Input Module" using the xinput command in a terminal 
   window.

     # xinput  

   Finally, map the touchscreen device ID to the desired video port using the 
   xinput command's --map-to-output option.

     # xinput --map-to-output 22 VGA-1   [Map input device ID 22 to VGA-1 port]

   The input device ID and video port name are stable across system reboots. 
   The above mapping command can be added to a startup script to perform the 
   mapping at every boot after the Elo MTUSB driver have been loaded.


G. In some Linux distributions (example: Ubuntu 12.04) the desktop does not 
   respond to clicks after some time, while the pointer still follows the touch
   input. This is a know bug in Xwindows which has been fixed on newer versions.
   To solve this issue, either upgrade to newer version of Xwindows or download 
   the bug fix, patch and recompile current version of Xserver.  


H. Newer Linux distributions are starting to switch to the new systemd init 
   system startup mechanism. If the addition of the Elo startup script 
   loadEloMultiTouchUSB.sh to rc.local or boot.local scripts does not load the 
   elo driver on reboot, check if systemd init system is active. If systemd 
   init is active then register and enable the elo.service systemd startup 
   script as per instructions in Step II of the Installation section.

I. Display rotation: 
   Can be rotated by using option OS's Setting. 
   Or by commnad line like:
	a. xrandr -o left (right)
	b. Or adding "display_rotate=x" to /boot/config.txt, where x=1,2,3,4.
	




=================================
9. Contacting Elo Touch Solutions
=================================

Website: http://www.elotouch.com


E-mail: customerservice@elotouch.com


Mailing Address:
----------------

  Elo Touch Solutions, Inc.
  670 N. McCarthy Blvd
  Milpitas, CA 95035
  USA

  Phone:   (800) 557-1458
           (408) 597-8000



================================================================================

                       Copyright (c) 2022 Elo Touch Solutions

                               All rights reserved.

================================================================================

