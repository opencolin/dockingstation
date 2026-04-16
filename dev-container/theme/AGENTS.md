# AGENTS.md

## OVERVIEW
This directory manages the retro Macintosh desktop interface, including window management and icon layout.

## COMPONENTS
- **Fluxbox**: Lightweight window manager handling window decorations, menus, and shortcuts.
- **iDesk**: Desktop icon daemon that renders shortcuts on the root window.
- **ImageMagick**: Used by `scripts/generate-theme.sh` to procedurally generate the classic Mac wallpaper and icons.

## CONFIGURATION
- `fluxbox/menu`: Right-click application menu definition.
- `fluxbox/keys`: Keyboard shortcuts for window management.
- `idesk/ideskrc`: Global desktop behavior (snap-to-grid, click delays).
- `idesk/icons/*.lnk`: Individual icon definitions mapping tools to their visual representation.

## ASSETS
- `icons/`: Directory for custom icon assets.
- **Wallpaper**: Generated at runtime and set via `feh`.
