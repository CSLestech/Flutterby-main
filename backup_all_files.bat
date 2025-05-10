@echo off
echo This script will backup all .dart files from lib folder to lib/backups folder
echo.

REM Ensure the backup folder exists
mkdir "lib\backups" 2>nul

echo Backing up files...

REM Copy all .dart files from the lib folder to the backups folder
for %%f in (lib\*.dart) do (
  echo Backing up: %%f
  copy "%%f" "lib\backups\%%~nxf" /Y
)

REM Copy widgets, utils, and other subfolders if they exist
if exist lib\widgets (
  echo Backing up widgets folder...
  mkdir "lib\backups\widgets" 2>nul
  copy "lib\widgets\*.dart" "lib\backups\widgets\" /Y
)

if exist lib\utils (
  echo Backing up utils folder...
  mkdir "lib\backups\utils" 2>nul
  copy "lib\utils\*.dart" "lib\backups\utils\" /Y
)

if exist lib\models (
  echo Backing up models folder...
  mkdir "lib\backups\models" 2>nul
  copy "lib\models\*.dart" "lib\backups\models\" /Y
)

if exist lib\screens (
  echo Backing up screens folder...
  mkdir "lib\backups\screens" 2>nul
  copy "lib\screens\*.dart" "lib\backups\screens\" /Y
)

echo.
echo Backup complete. Files are stored in lib/backups folder.
echo.

pause