# Tools Directory

This directory contains utility scripts for the Caravella project.

## Scripts

### generate_notification_icons.py

Generates PNG notification icons for all expense group types at all required Android densities.

**Purpose**: Creates type-specific notification icons (travel, personal, family, other) from Material Design SVG paths.

**Requirements**:
```bash
pip3 install cairosvg Pillow
```

**Usage**:
```bash
python3 tools/generate_notification_icons.py
```

**Output**: Creates 24 PNG files (4 types × 6 densities) in `android/app/src/main/res/drawable-*/`

**When to run**:
- When adding new icon types
- When updating icon designs
- After updating Material Design icon sources

See `docs/DYNAMIC_NOTIFICATION_ICONS.md` for more information about notification icons.
