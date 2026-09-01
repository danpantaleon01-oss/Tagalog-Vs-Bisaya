@echo off
net session >nul 2>&1
if %errorLevel% == 0 (
    echo [SUCCESS] Administrative privileges confirmed. Proceeding with system installation...
) else (
    echo [ERROR] This installer requires Administrative privileges.
    echo Please right-click this .bat file and select 'Run as administrator'.
    pause
    exit /b
)

cd /d "%~dp0"

echo [BUILD] Compiling into a SINGLE "Tagalog VS Bisaya.exe" launcher...
pip install pyinstaller pygame

:: Compiles everything into ONE file and injects the asset maps into the binary data array
pyinstaller -F --noconsole --icon=icon.ico --add-data "assets;assets" --add-data "music.mp3;." --add-data "scores.json;." --name="Tagalog VS Bisaya" main.py

if not exist "dist\Tagalog VS Bisaya.exe" (
    echo [ERROR] PyInstaller compilation failed!
    pause
    exit /b
)

echo [INSTALL] Moving System Application into Protected Roots...
if exist "C:\Program Files\TagalogVsBisayaGame" rmdir /s /q "C:\Program Files\TagalogVsBisayaGame"
mkdir "C:\Program Files\TagalogVsBisayaGame"
copy /Y "dist\Tagalog VS Bisaya.exe" "C:\Program Files\TagalogVsBisayaGame\"

echo [INSTALL] Registering System Environment Variables...
setx /M PATH "%PATH%;C:\Program Files\TagalogVsBisayaGame"

echo [INSTALL] Creating system-wide Start Menu Shortcut...
set SCRIPT="%TEMP%\%RANDOM%-%RANDOM%-%RANDOM%-%RANDOM%.vbs"
echo Set oWS = WScript.CreateObject("WScript.Shell") >> %SCRIPT%
echo sLinkFile = "%ProgramData%\Microsoft\Windows\Start Menu\Programs\Tagalog VS Bisaya.lnk" >> %SCRIPT%
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> %SCRIPT%
echo oLink.TargetPath = "C:\Program Files\TagalogVsBisayaGame\Tagalog VS Bisaya.exe" >> %SCRIPT%
echo oLink.WorkingDirectory = "C:\Program Files\TagalogVsBisayaGame" >> %SCRIPT%
echo oLink.IconLocation = "C:\Program Files\TagalogVsBisayaGame\Tagalog VS Bisaya.exe, 0" >> %SCRIPT%
echo oLink.Save >> %SCRIPT%
cscript /nologo %SCRIPT%
del %SCRIPT%

echo ===================================================
echo [COMPLETE] System Application Configuration Finished!
echo ===================================================
echo Check your local "dist" folder for the lone "Tagalog VS Bisaya.exe" file.
pause
