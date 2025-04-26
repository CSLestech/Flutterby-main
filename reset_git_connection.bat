@echo off
echo Fixing Visual Studio Code Git connection issue...

REM Kill any running VS Code processes
taskkill /f /im "code.exe" >nul 2>&1
taskkill /f /im "Code.exe" >nul 2>&1

REM Clear any temporary VS Code files that might be causing Git connection issues
echo Clearing VS Code temporary files...
if exist "%APPDATA%\Code\logs\*.log" del /q "%APPDATA%\Code\logs\*.log" >nul 2>&1
if exist "%APPDATA%\Code\Cache\*" del /q "%APPDATA%\Code\Cache\*" >nul 2>&1

REM Verify Git is working
echo Testing Git installation...
git --version
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Git is not working properly. Please ensure Git is correctly installed.
    goto end
) else (
    echo Git is working correctly!
)

echo.
echo VS Code Git connection fix complete!
echo Please restart Visual Studio Code and try your Git operations again.
echo.

:end
pause