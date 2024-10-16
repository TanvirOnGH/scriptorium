@echo off
setlocal

:: ADB Fastboot and USB driver installer tool for Windows (Always installs the latest version)
:: Based on: <https://github.com/fawazahmed0/Latest-adb-fastboot-installer-for-windows>
:: Note: If fastboot mode is not detected after installation, connect your phone in fastboot mode and run the installer tool again.

:: Request admin privileges if not already running as admin
net session >nul 2>&1
if NOT %errorLevel% == 0 (
    powershell -executionpolicy bypass start -verb runas '%0' am_admin & exit /b
)

:: Function to download files
:download_file
    PowerShell -executionpolicy bypass -Command "(New-Object Net.WebClient).DownloadFile('%1', '%2')"
    if %errorLevel% neq 0 (
        echo Failed to download %1
        exit /b 1
    )
    goto :eof

:: Function to extract zip files
:extract_zip
    PowerShell -executionpolicy bypass -Command "& {$shell_app=new-object -com shell.application; $zip_file = $shell_app.namespace((Get-Location).Path + '\%1'); $destination = $shell_app.namespace('%2'); $destination.Copyhere($zip_file.items());}"
    if %errorLevel% neq 0 (
        echo Failed to extract %1
        exit /b 1
    )
    goto :eof

:: Function to set environment path
:set_env_path
    SET Key="HKCU\Environment"
    FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY %Key% /v PATH`) DO Set CurrPath=%%B
    echo ;%CurrPath%; | find /C /I ";%PROGRAMFILES%\platform-tools;" > temp.txt
    set /p VV=<temp.txt
    if "%VV%" EQU "0" (
        SETX PATH "%PROGRAMFILES%\platform-tools;%CurrPath%" > nul 2>&1
    )
    goto :eof

:: Main script starts here

echo Please connect your phone in USB Debugging Mode with MTP or File Transfer.
echo This step is optional but highly recommended for proper USB driver installation.

:: Adding a timeout of 6 seconds
PowerShell -executionpolicy bypass -Command "Start-Sleep -s 6" > nul 2>&1

echo.
echo Starting Installation...

:: Navigate back to the script directory
cd %~dp0

:: Creating a temporary directory
echo Creating temporary folder...
rmdir /Q /S temporarydir > nul 2>&1
mkdir temporarydir
pushd temporarydir

:: Downloading the latest platform tools and USB drivers
echo Downloading the latest ADB and Fastboot tools...
call :download_file "https://dl.google.com/android/repository/platform-tools-latest-windows.zip" "adbinstallerpackage.zip"

echo Downloading the latest USB drivers...
call :download_file "https://dl.google.com/android/repository/latest_usb_driver_windows.zip" "google_usb_driver.zip"
call :download_file "https://cdn.jsdelivr.net/gh/fawazahmed0/Latest-adb-fastboot-installer-for-windows@master/files/google64inf" "google64inf"
call :download_file "https://cdn.jsdelivr.net/gh/fawazahmed0/Latest-adb-fastboot-installer-for-windows@master/files/google86inf" "google86inf"
call :download_file "https://cdn.jsdelivr.net/gh/fawazahmed0/Latest-adb-fastboot-installer-for-windows@master/files/Stringsvals" "Stringsvals"
call :download_file "https://cdn.jsdelivr.net/gh/fawazahmed0/Latest-adb-fastboot-installer-for-windows@master/files/kmdf" "kmdf"
call :download_file "https://cdn.jsdelivr.net/gh/fawazahmed0/Latest-adb-fastboot-installer-for-windows@master/files/Latest ADB Launcherbat" "Latest ADB Launcher.bat"

:: Fetching devcon.exe and PowerShell script
call :download_file "https://cdn.jsdelivr.net/gh/fawazahmed0/Latest-adb-fastboot-installer-for-windows@master/files/fetch_hwidps1" "fetch_hwid.ps1"
call :download_file "https://cdn.jsdelivr.net/gh/fawazahmed0/Latest-adb-fastboot-installer-for-windows@master/files/devconexe" "devcon.exe"

:: Uninstalling/removing the older version of platform tools, if they exist, and killing instances of adb if they are running
echo Uninstalling older version of platform tools...
adb kill-server > nul 2>&1
rmdir /Q /S "%PROGRAMFILES%\platform-tools" > nul 2>&1

:: Extracting the .zip file to the installation location
echo Installing the files...
call :extract_zip "adbinstallerpackage.zip" "%PROGRAMFILES%"
echo Installing USB drivers...
call :extract_zip "google_usb_driver.zip" "%cd%"

:: Calling PowerShell script to fetch the unknown USB driver HWIDs and inserting them into the inf file
powershell -executionpolicy bypass .\fetch_hwid.ps1

:: Combining multiple inf files to support all devices
powershell -executionpolicy bypass -Command "gc Stringsvals | Add-Content usb_driver\android_winusb.inf"
powershell -executionpolicy bypass -Command "(gc usb_driver\android_winusb.inf | Out-String) -replace '\[Google.NTamd64\]', (gc google64inf | Out-String) | Out-File usb_driver\android_winusb.inf"
powershell -executionpolicy bypass -Command "(gc usb_driver\android_winusb.inf | Out-String) -replace '\[Google.NTx86\]', (gc google86inf | Out-String) | Out-File usb_driver\android_winusb.inf"
powershell -executionpolicy bypass -Command "(gc usb_driver\android_winusb.inf | Out-String) -replace '\[Strings\]', (gc kmdf | Out-String) | Out-File usb_driver\android_winusb.inf"

:: Fetching unsigned driver installer tool
echo Downloading unsigned driver installer tool...
call :download_file "https://cdn.jsdelivr.net/gh/fawazahmed0/windows-unsigned-driver-installer@master/unsigned_driver_installerbat" "usb_driver\unsigned_driver_installer.bat"

:: Running unsigned_driver_installer tool
pushd usb_driver
echo.
echo Running unsigned driver installer...
echo | call unsigned_driver_installer.bat
popd

:: Installing fastboot drivers
"%PROGRAMFILES%\platform-tools\adb.exe" reboot bootloader > nul 2> temp.txt
set rbtval=%errorLevel%
type temp.txt | findstr /i /C:"unauthorized" 1> NUL

if %errorLevel% == 0 (
    echo.
    echo Beginning Fastboot drivers installation...
    echo.
    echo Please press OK on the confirmation dialog shown on your phone to allow USB debugging authorization.
    echo Then press Enter to continue.
    PowerShell -executionpolicy bypass -Command "Start-Sleep -s 3" > nul 2>&1
    pause > NUL
    "%PROGRAMFILES%\platform-tools\adb.exe" reboot bootloader > nul 2>&1
)

if NOT "%rbtval%" == "0" set rbtval=%errorLevel%

if "%rbtval%" == "0" (
    echo.
    echo Installing fastboot drivers. The device will reboot to fastboot mode.

    echo Waiting for fastboot mode to load...
    PowerShell -executionpolicy bypass -Command "Start-Sleep -s 8" > nul 2>&1

    powershell -executionpolicy bypass .\fetch_hwid.ps1

    pushd usb_driver
    echo.
    echo Running unsigned driver installer...
    echo | call unsigned_driver_installer.bat
    popd

    "%PROGRAMFILES%\platform-tools\fastboot.exe" devices > temp.txt
    set /p fbdev=<temp.txt
    if defined fbdev ( "%PROGRAMFILES%\platform-tools\fastboot.exe" reboot > nul 2>&1 )
)

:: Killing adb server
"%PROGRAMFILES%\platform-tools\adb.exe" kill-server > nul 2>&1

:: Setting the PATH environment variable
echo.
echo Setting the environment PATH...
call :set_env_path

:: Creating 'Latest ADB Launcher' on the Desktop
echo Creating 'Latest ADB Launcher' on the Desktop...
For /F "delims=" %%G In ('PowerShell -executionpolicy bypass -Command "[environment]::GetFolderPath('Desktop')"') Do Set "DESKTOP=%%G"
copy /y "Latest ADB Launcher.bat" %DESKTOP% > nul 2>&1

:: Deleting the temporary directory
echo Deleting the temporary folder...
popd
rmdir /Q /S temporarydir > nul 2>&1

endlocal
