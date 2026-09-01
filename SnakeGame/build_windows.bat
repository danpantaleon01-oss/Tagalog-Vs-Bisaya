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

echo [CHECK] Verifying Python 3.13 environment...
python --version 2>nul | findstr "3.13" >nul
if %errorLevel% neq 0 (
    echo [NOTICE] Python 3.13 not found natively. Attempting fallback verification...
    py -3.13 --version >nul 2>&1
    if %errorLevel% neq 0 (
        echo [ERROR] Python 3.13 is missing from the host environment.
        echo Please ensure Python 3.13 is installed on this device before proceeding.
        pause
        exit /b
    )
)

echo [BUILD] Compiling into a SINGLE "Tagalog VS Bisaya.exe" launcher...
pip install pyinstaller pygame
pyinstaller -F --noconsole --icon=icon.ico --add-data "assets;assets" --add-data "music.mp3;." --add-data "scores.json;." --name="Tagalog VS Bisaya" main.py

if not exist "dist\Tagalog VS Bisaya.exe" (
    echo [ERROR] PyInstaller compilation failed! The launcher file was not created.
    pause
    exit /b
)

echo [INSTALL] Registering System Application Root...
if exist "C:\Program Files\TagalogVsBisayaGame" rmdir /s /q "C:\Program Files\TagalogVsBisayaGame"
mkdir "C:\Program Files\TagalogVsBisayaGame"
copy /Y "dist\Tagalog VS Bisaya.exe" "C:\Program Files\TagalogVsBisayaGame\"

echo [INSTALL] Injecting environment variable markers...
setx /M PATH "%PATH%;C:\Program Files\TagalogVsBisayaGame"

echo [INSTALL] Deploying permanent system-wide shortcut link...
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
echo Check your local project folder under "dist" for your standalone launcher:
echo - dist\Tagalog VS Bisaya.exe
pause
