#!/usr/bin/env python3
"""
Generate notification icons for all expense group types at all required densities.

This script creates PNG notification icons from SVG path data for each ExpenseGroupType.
Icons are created in multiple densities as required by Android.
"""

import os
import sys
from pathlib import Path

try:
    import cairosvg
    from PIL import Image
    import io
except ImportError as e:
    print(f"Error: Required library not found: {e}")
    print("Please install: pip3 install cairosvg Pillow")
    sys.exit(1)

# Icon definitions with Material Design SVG paths
ICONS = {
    'ic_notification_travel': {
        'name': 'Travel (flight_takeoff)',
        'path': 'M2.5,19h19v2h-19zM22.07,9.64c-0.21,-0.8 -1.04,-1.28 -1.84,-1.06L14.92,10l-6.9,-6.43 -1.93,0.51 4.14,7.17 -4.97,1.33 -1.97,-1.54 -1.45,0.39 2.59,4.49c0,0 7.12,-1.9 16.57,-4.43 0.81,-0.23 1.28,-1.05 1.07,-1.85z'
    },
    'ic_notification_personal': {
        'name': 'Personal (person)',
        'path': 'M12,12c2.21,0 4,-1.79 4,-4s-1.79,-4 -4,-4 -4,1.79 -4,4 1.79,4 4,4zM12,14c-2.67,0 -8,1.34 -8,4v2h16v-2c0,-2.66 -5.33,-4 -8,-4z'
    },
    'ic_notification_family': {
        'name': 'Family (family_restroom)',
        'path': 'M16,4c0,-1.11 0.89,-2 2,-2s2,0.89 2,2 -0.89,2 -2,2 -2,-0.89 -2,-2zM20,22v-6h2.5l-2.54,-7.63C19.68,7.55 18.92,7 18.06,7h-0.12c-0.86,0 -1.63,0.55 -1.9,1.37l-0.86,2.58C16.26,11.55 17,12.68 17,14v8h3zM12.5,11.5c0.83,0 1.5,-0.67 1.5,-1.5s-0.67,-1.5 -1.5,-1.5S11,9.17 11,10s0.67,1.5 1.5,1.5zM5.5,6c1.11,0 2,-0.89 2,-2s-0.89,-2 -2,-2 -2,0.89 -2,2 0.89,2 2,2zM7.5,22v-7H9V9c0,-1.1 -0.9,-2 -2,-2H4C2.9,7 2,7.9 2,9v6h1.5v7h4zM14,22v-4h1v-4c0,-0.82 -0.68,-1.5 -1.5,-1.5h-2c-0.82,0 -1.5,0.68 -1.5,1.5v4h1v4h3z'
    },
    'ic_notification_other': {
        'name': 'Other (widgets_outlined)',
        'path': 'M16.66,4.52l2.83,2.83 -2.83,2.83 -2.83,-2.83 2.83,-2.83M9,5v4H5V5h4m10,10v4h-4v-4h4M9,15v4H5v-4h4m7.66,-13.31L11,7.34 16.66,13l5.66,-5.66 -5.66,-5.65zM11,3H3v8h8V3zm10,10h-8v8h8v-8zm-10,0H3v8h8v-8z'
    }
}

# Density configurations: folder suffix -> size in pixels
# Note: ldpi (18px) is omitted as it's deprecated and rarely used on modern devices
DENSITIES = {
    'mdpi': 24,
    'hdpi': 36,
    'xhdpi': 48,
    'xxhdpi': 72,
    'xxxhdpi': 96
}

def create_svg(path_data, size=24):
    """Create SVG content from path data
    
    The viewBox remains '0 0 24 24' regardless of output size to maintain
    the coordinate system of the Material Design icon paths.
    """
    return f'''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="{size}" height="{size}" viewBox="0 0 24 24">
    <path fill="#FFFFFF" d="{path_data}"/>
</svg>'''

def generate_icon_png(svg_content, output_path, size):
    """Generate PNG from SVG content at specified size"""
    try:
        # Convert SVG to PNG using cairosvg
        png_data = cairosvg.svg2png(
            bytestring=svg_content.encode('utf-8'),
            output_width=size,
            output_height=size,
            background_color='transparent'
        )
        
        # Open with PIL to ensure proper format
        img = Image.open(io.BytesIO(png_data))
        
        # Ensure it's RGBA with transparency
        if img.mode != 'RGBA':
            img = img.convert('RGBA')
        
        # Save as PNG
        img.save(output_path, 'PNG', optimize=True)
        print(f"✓ Created: {output_path} ({size}x{size}px)")
        return True
    except Exception as e:
        print(f"✗ Error creating {output_path}: {e}")
        return False

def main():
    # Get the project root directory
    script_dir = Path(__file__).parent
    project_root = script_dir.parent
    
    # Base directory for Android resources
    base_res_dir = project_root / 'android' / 'app' / 'src' / 'main' / 'res'
    
    if not base_res_dir.exists():
        print(f"Error: Android resource directory not found: {base_res_dir}")
        sys.exit(1)
    
    print("🎨 Generating notification icons for all expense group types...\n")
    
    total_created = 0
    total_failed = 0
    
    for icon_name, icon_data in ICONS.items():
        print(f"\n📱 Generating {icon_name} - {icon_data['name']}")
        svg_content = create_svg(icon_data['path'])
        
        # Create for each density
        for density, size in DENSITIES.items():
            folder = base_res_dir / f'drawable-{density}'
            folder.mkdir(parents=True, exist_ok=True)
            
            output_file = folder / f'{icon_name}.png'
            if generate_icon_png(svg_content, output_file, size):
                total_created += 1
            else:
                total_failed += 1
        
        # Also create fallback in base drawable folder (24x24)
        fallback_folder = base_res_dir / 'drawable'
        fallback_folder.mkdir(parents=True, exist_ok=True)
        fallback_file = fallback_folder / f'{icon_name}.png'
        if generate_icon_png(svg_content, fallback_file, 24):
            total_created += 1
        else:
            total_failed += 1
    
    print(f"\n{'='*60}")
    print(f"✅ Icon generation complete!")
    print(f"   Created: {total_created} files")
    if total_failed > 0:
        print(f"   Failed:  {total_failed} files")
    print(f"{'='*60}\n")
    
    print("📋 Next steps:")
    print("1. Verify the icons look correct (white on transparent)")
    print("2. Optionally copy to flavor-specific directories (dev, staging, prod)")
    print("3. Test notifications with different expense group types")
    print("4. Check Android logs for any 'invalid_icon' errors\n")

if __name__ == '__main__':
    main()
