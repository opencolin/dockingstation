#!/bin/bash
# Generate 90s Macintosh-style wallpaper and icons using ImageMagick
set -e

ICON_DIR="/home/devuser/.idesktop/icons"
mkdir -p "$ICON_DIR"

# Use DejaVu fonts (available via fonts-dejavu-core, installed as dependency)
FONT_BOLD="DejaVu-Sans-Bold"
FONT_REG="DejaVu-Sans"
FONT_MONO="DejaVu-Sans-Mono"

# ---- Wallpaper: Classic Mac OS teal/purple with subtle noise ----
convert -size 1280x1024 \
  xc:"#666699" \
  -fill "#556688" \
  -draw "rectangle 0,0 1280,1024" \
  -fill "#667799" \
  -draw "rectangle 0,0 1280,512" \
  \( -size 1280x1024 xc: \
     +noise Random \
     -channel G -separate \
     -threshold 97% \
     -negate \
     -fill "#5566AA" -opaque white \
     -fill none -opaque black \
  \) -composite \
  -gravity North \
  -fill "#FFFFFF" -font "$FONT_BOLD" -pointsize 28 \
  -annotate +0+30 "Docking Station" \
  -fill "#CCCCDD" -font "$FONT_REG" -pointsize 14 \
  -annotate +0+65 "Developer Container" \
  /home/devuser/.fluxbox/wallpaper.png

# ---- Generate simple retro-style icons ----

# VS Code icon (blue document)
convert -size 48x48 xc:none \
  -fill "#0078D4" -draw "roundrectangle 4,2 44,42 3,3" \
  -fill "#FFFFFF" -draw "rectangle 12,10 36,36" \
  -fill "#0078D4" -font "$FONT_BOLD" -pointsize 16 \
  -gravity center -annotate +0+2 "VS" \
  "$ICON_DIR/vscode.png"

# File Browser icon (folder)
convert -size 48x48 xc:none \
  -fill "#F0C040" -draw "roundrectangle 2,12 46,44 2,2" \
  -fill "#E0B030" -draw "polygon 2,12 18,12 22,4 46,4 46,12" \
  -fill "#FFFFFF" -font "$FONT_REG" -pointsize 9 \
  -gravity center -annotate +0+6 "Files" \
  "$ICON_DIR/filebrowser.png"

# Terminal icon (black screen with green text)
convert -size 48x48 xc:none \
  -fill "#333333" -draw "roundrectangle 2,2 46,46 4,4" \
  -fill "#222222" -draw "rectangle 6,6 42,38" \
  -fill "#00CC00" -font "$FONT_MONO" -pointsize 10 \
  -gravity center -annotate +0-2 ">_" \
  -fill "#888888" -draw "rectangle 6,40 42,44" \
  "$ICON_DIR/terminal.png"

echo "Theme assets generated successfully."
