#!/bin/bash

echo "This script will backup all .dart files from lib folder to lib/backups folder"
echo ""

# Ensure the backup folder exists
mkdir -p "lib/backups"

echo "Backing up files..."

# Copy all .dart files from the lib folder to the backups folder
for file in lib/*.dart; do
  echo "Backing up: $file"
  cp "$file" "lib/backups/$(basename $file)"
done

# Copy widgets, utils, and other subfolders if they exist
if [ -d "lib/widgets" ]; then
  echo "Backing up widgets folder..."
  mkdir -p "lib/backups/widgets"
  cp lib/widgets/*.dart lib/backups/widgets/ 2>/dev/null
fi

if [ -d "lib/utils" ]; then
  echo "Backing up utils folder..."
  mkdir -p "lib/backups/utils"
  cp lib/utils/*.dart lib/backups/utils/ 2>/dev/null
fi

if [ -d "lib/models" ]; then
  echo "Backing up models folder..."
  mkdir -p "lib/backups/models"
  cp lib/models/*.dart lib/backups/models/ 2>/dev/null
fi

if [ -d "lib/screens" ]; then
  echo "Backing up screens folder..."
  mkdir -p "lib/backups/screens"
  cp lib/screens/*.dart lib/backups/screens/ 2>/dev/null
fi

echo ""
echo "Backup complete. Files are stored in lib/backups folder."
echo ""