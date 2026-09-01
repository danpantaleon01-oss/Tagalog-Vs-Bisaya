@echo off
REM Check if Python 3.13 is installed, if not, install it using winget
py -3.13 --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [System] Python 3.13 was not found. Installing Python 3.13 automatically...
    winget install --id Python.Python.3.13 --exact --silent --accept-source-agreements --accept-package-agreements
    
    REM Refresh path for the current session
    for /f "tokens=2*" %%A in ('reg query "HKLM\System\CurrentControlSet\Control\Session Manager\Environment" /v Path') do set "SYS_PATH=%%B"
    for /f "tokens=2*" %%A in ('reg query "HKCU\Environment" /v Path') do set "USER_PATH=%%B"
    set "PATH=%SYS_PATH%;%USER_PATH%"
)

REM Uses Python 3.13 because pygame has no prebuilt wheel for 3.14 yet.
py -3.13 -m pip install -r requirements.txt
py -3.13 -m pip install pyinstaller

REM Clean up old build artifacts to ensure a fresh build
if exist build rmdir /s /q build
if exist dist rmdir /s /q dist
if exist "Tagalog VS Bisaya.spec" del /f /q "Tagalog VS Bisaya.spec"
if exist SnakeGame.spec del /f /q SnakeGame.spec

py -3.13 -m PyInstaller --noconfirm --onefile --windowed --icon=icon.ico --add-data "assets;assets" --name "Tagalog VS Bisaya" main.py
echo.
echo Build complete. Your EXE is in the dist folder:
echo dist\"Tagalog VS Bisaya.exe"
pause
