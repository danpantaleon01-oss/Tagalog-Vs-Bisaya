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

echo [BUILD] Compiling main.py into a clean standalone package...
pip install pyinstaller pygame
pyinstaller --noconsole --icon=icon.ico main.py

if not exist "dist\main\main.exe" (
    echo [ERROR] PyInstaller compilation failed. Ensure main.py and icon.ico are in this directory.
    pause
    exit /b
)

echo [BUILD] Structuring game files...
if exist "dist\TagalogVsBisayaGame" rmdir /s /q "dist\TagalogVsBisayaGame"
rename "dist\main" "TagalogVsBisayaGame"

xcopy /E /I /Y "assets" "dist\TagalogVsBisayaGame\assets"
copy /Y "music.mp3" "dist\TagalogVsBisayaGame\"
copy /Y "scores.json" "dist\TagalogVsBisayaGame\"

echo [INSTALL] Moving package into Protected System Root...
if exist "C:\Program Files\TagalogVsBisayaGame" rmdir /s /q "C:\Program Files\TagalogVsBisayaGame"
xcopy /E /I /Y "dist\TagalogVsBisayaGame" "C:\Program Files\TagalogVsBisayaGame"

echo [INSTALL] Injecting executable folder into Global System Path...
setx /M PATH "%PATH%;C:\Program Files\TagalogVsBisayaGame"

echo [INSTALL] Registering shortcut within the Shared Start Menu...
set SCRIPT="%TEMP%\%RANDOM%-%RANDOM%-%RANDOM%-%RANDOM%.vbs"
echo Set oWS = WScript.CreateObject("WScript.Shell") >> %SCRIPT%
echo sLinkFile = "%ProgramData%\Microsoft\Windows\Start Menu\Programs\Tagalog VS Bisaya.lnk" >> %SCRIPT%
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> %SCRIPT%
echo oLink.TargetPath = "C:\Program Files\TagalogVsBisayaGame\main.exe" >> %SCRIPT%
echo oLink.WorkingDirectory = "C:\Program Files\TagalogVsBisayaGame" >> %SCRIPT%
echo oLink.IconLocation = "C:\Program Files\TagalogVsBisayaGame\main.exe, 0" >> %SCRIPT%
echo oLink.Save >> %SCRIPT%
cscript /nologo %SCRIPT%
del %SCRIPT%

echo ===================================================
echo [COMPLETE] System Application Configuration Finished!
echo ===================================================
echo You can now open 'Run' (Win+R) and launch the game directly using: main
echo The game is also pinned system-wide across all user Start Menus.
pause
