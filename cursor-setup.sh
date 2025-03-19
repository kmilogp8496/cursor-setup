#!/usr/bin/bash

set -e

icon_url="https://miro.medium.com/v2/resize:fit:700/1*YLg8VpqXaTyRHJoStnMuog.png"

# Cursor app image path
cursor_app_image_path="$HOME/cursor"
cursor_icon_path="$cursor_app_image_path/cursor.png"
cursor_alias_path="$HOME/.local/bin/cursor"

# Create the cursor directory
mkdir -p ~/cursor

# Download the icon if necessary
if [ ! -f "$cursor_icon_path" ]; then
  curl -L "$icon_url" -o "$cursor_icon_path"
else
  echo "Cursor icon already exists at $cursor_icon_path"
fi

fetch_url="https://www.cursor.com/api/download?platform=linux-x64&releaseTrack=stable"

# Example download url: https://downloads.cursor.com/production/client/linux/x64/appimage/Cursor-0.46.11-ae378be9dc2f5f1a6a1a220c6e25f9f03c8d4e19.deb.glibc2.25-x86_64.AppImage
# Get the download url
download_url=$(curl -s $fetch_url | jq -r '.downloadUrl')

# Get the filename from the download url
filename=$(basename "$download_url")

# If file exists, exit
if [ -f "$cursor_app_image_path/$filename" ]; then
  echo "Cursor current version of app image already exists: $filename"
  echo "If you want to download a new version, please delete the current version and run the script again."
  echo ""
  echo "rm $cursor_app_image_path/$filename"
  exit 0
fi

# Download the cursor app image
curl -L "$download_url" -o "$cursor_app_image_path/$filename"

# Make the cursor app image executable
chmod +x "$cursor_app_image_path/$filename"

# Create a symbolic link to the cursor app image
ln -fns "$cursor_app_image_path/$filename" "$cursor_alias_path"

# Create a desktop entry for the cursor app image
desktop_entry="$HOME/.local/share/applications/personal-cursor.desktop"

# create the desktop entry if it doesn't exist
if [ ! -f "$desktop_entry" ]; then
  echo "Creating desktop entry at $desktop_entry"

  echo "[Desktop Entry]
  Name=Cursor AI IDE
  Exec=$cursor_alias_path --no-sandbox
  Icon=$cursor_icon_path
  Type=Application
  Categories=Development;
  " >"$desktop_entry"

  # Make the desktop entry executable
  chmod +x "$desktop_entry"
else
  echo "Desktop entry already exists at $desktop_entry"
fi

# Add the desktop entry to the applications menu
xdg-desktop-menu install "$desktop_entry"

# Add alias to zshrc if it doesn't exist
if ! grep -q "alias cursor" ~/.zshrc; then
  echo "Adding alias to zshrc"
  echo "alias cursor='$cursor_alias_path --no-sandbox'" >>~/.zshrc
else
  echo "Alias already exists in zshrc"
fi
