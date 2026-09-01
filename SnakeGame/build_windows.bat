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

echo [BUILD] Compiling game package into "Tagalog VS Bisaya"...
pip install pyinstaller pygame
pyinstaller --noconsole --icon=icon.ico --name="Tagalog VS Bisaya" main.py

if not exist "dist\Tagalog VS Bisaya\Tagalog VS Bisaya.exe" (
    echo [ERROR] PyInstaller compilation failed. Ensure main.py and icon.ico are in this directory.
    pause
    exit /b
)

echo [BUILD] Synchronizing game assets...
xcopy /E /I /Y "assets" "dist\Tagalog VS Bisaya\assets"
copy /Y "music.mp3" "dist\Tagalog VS Bisaya\"
copy /Y "scores.json" "dist\Tagalog VS Bisaya\"

echo [INSTALL] Provisioning package into Protected System Root...
if exist "C:\Program Files\TagalogVsBisayaGame" rmdir /s /q "C:\Program Files\TagalogVsBisayaGame"
xcopy /E /I /Y "dist\Tagalog VS Bisaya" "C:\Program Files\TagalogVsBisayaGame"

echo [INSTALL] Injecting executable folder into Global System Path...
setx /M PATH "%PATH%;C:\Program Files\TagalogVsBisayaGame"

echo [INSTALL] Registering shortcut within the Shared Start Menu...
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
echo Launcher Name: Tagalog VS Bisaya.exe
echo Check the "dist/Tagalog VS Bisaya" folder for your local package.
pause

