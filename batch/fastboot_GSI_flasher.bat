@echo off

:: WARNING: This script will erase all data on the device

:: Helper links
:: https://source.android.com/docs/core/architecture/bootloader/locking_unlocking
:: https://droidwin.com/arm64-a64-bgn-bvn-bgs-vndklite-which-gsi-to-download/
:: https://droidwin.com/download-and-install-android-14-gsi-rom/
:: https://droidwin.com/how-to-install-lineageos-21-android-14-gsi-on-any-android/

:: IMPORTANT: Download the stock firmware for your device and extract the vbmeta.img file

:: Note: fastboot and fastbootd are not the same thing

set use_dot_slash=yes
set vbmeta_img=vbmeta.img
set /p system_img="Enter the system image filename (e.g., system.img): "

if /i "%use_dot_slash%"=="yes" (
    set prefix=./
) else (
    set prefix=
)

%prefix%adb reboot bootloader
:: fastboot devices
%prefix%fastboot --disable-verification flash vbmeta %vbmeta_img%
%prefix%fastboot reboot fastboot
%prefix%fastboot erase system
%prefix%fastboot delete-logical-partition product_a
%prefix%fastboot flash system %system_img%
%prefix%fastboot -w
%prefix%fastboot reboot
