#!/bin/bash

# === Config ===
APP_DIR="/opt/cursor-ai"
APP_FILE="$APP_DIR/AppRun"
APPIMAGE_FILE="$APP_DIR/Cursor.AppImage"
VERSION_FILE="$HOME/.cursor-version"
DESKTOP_FILE="$HOME/.local/share/applications/cursor.desktop"
DOWNLOAD_URL="https://downloads.cursor.com/production/7801a556824585b7f2721900066bc87c4a09b743/linux/x64/Cursor-0.48.8-x86_64.AppImage"
LATEST_VERSION="0.48.8"

# === Step 1: Get current version
if [[ -f "$VERSION_FILE" ]]; then
    CURRENT_VERSION=$(cat "$VERSION_FILE")
else
    CURRENT_VERSION="none"
fi

echo "Current installed version (recorded): $CURRENT_VERSION"
echo "Latest available version: $LATEST_VERSION"

if [[ "$CURRENT_VERSION" == "$LATEST_VERSION" ]]; then
    echo "✅ Cursor is already up to date."
    exit 0
fi

# === Step 2: Download new AppImage to temp
TMP_FILE="/tmp/Cursor-$LATEST_VERSION.AppImage"
curl -L "$DOWNLOAD_URL" -o "$TMP_FILE"
chmod +x "$TMP_FILE"

# === Step 3: Replace AppImage
echo "🚀 Replacing old AppImage in $APP_DIR"
sudo rm -f "$APPIMAGE_FILE"
sudo mv "$TMP_FILE" "$APPIMAGE_FILE"
sudo chmod +x "$APPIMAGE_FILE"

# === Step 4: Update AppRun symlink
if [[ -f "$APP_FILE" || -L "$APP_FILE" ]]; then
    sudo rm -f "$APP_FILE"
fi
sudo ln -s "$APPIMAGE_FILE" "$APP_FILE"

# === Step 5: Save version info
echo "$LATEST_VERSION" > "$VERSION_FILE"
echo "📌 Version $LATEST_VERSION recorded in $VERSION_FILE"

# === Step 6: Create .desktop entry for Rofi/system launcher
mkdir -p "$(dirname "$DESKTOP_FILE")"

cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Name=Cursor AI
Comment=AI-powered code editor
Exec=$APP_FILE --no-sandbox
Icon=$APP_DIR/usr/share/icons/hicolor/512x512/apps/cursor.png
Type=Application
Categories=Development;IDE;
Terminal=false
StartupWMClass=Cursor
EOF

update-desktop-database ~/.local/share/applications &>/dev/null || true
echo "🖥️  .desktop entry written to $DESKTOP_FILE"

echo "✅ Cursor has been updated and added to your launcher menu."
