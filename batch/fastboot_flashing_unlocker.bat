@echo off

:: USB Debugging and OEM Unlocking in Deveoper Options must be enabled
:: Enable Developer Options by tapping on Build Number 7 times in About Phone
:: WARNING: Unlocking bootloader will erase all data on the device
:: NOTE: Not all devices support (easy) bootloader unlocking e.g., Samsung

:: NB: fastboot and fastbootd are not the same thing

set use_dot_slash=yes
set /p action="Enter 'unlock' to unlock or 'lock' to lock: "

if /i "%use_dot_slash%"=="yes" (
    set prefix=./
) else (
    set prefix=
)

%prefix%adb reboot bootloader
:: fastboot devices
%prefix%fastboot flashing get_unlock_ability

if /i "%action%"=="unlock" (
    %prefix%fastboot flashing unlock
    %prefix%fastboot flashing unlock_critical
) else if /i "%action%"=="lock" (
    %prefix%fastboot flashing lock
    %prefix%fastboot flashing lock_critical
) else (
    echo Invalid action. Please enter 'unlock' or 'lock'.
    exit /b 1
)

%prefix%fastboot oem unlock
%prefix%fastboot reboot
