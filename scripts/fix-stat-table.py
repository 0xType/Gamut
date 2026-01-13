#!/usr/bin/env python
"""
Fix STAT table by adding Axis Value Records for all weight instances.
"""
from fontTools import ttLib
from fontTools.ttLib.tables import otTables
import sys

def fix_stat_table(font_path):
    font = ttLib.TTFont(font_path)

    # Get existing STAT table
    stat_table = font["STAT"].table

    # Define all weight instances with their name IDs from the font
    # These name IDs should match the ones in the fvar table
    weights = [
        (100, 257),   # Thin
        (200, 258),   # ExtraLight
        (300, 259),   # Light
        (400, 2),     # Regular (Elidable)
        (500, 260),   # Medium
        (600, 261),   # SemiBold
        (700, 262),   # Bold
        (800, 263),   # ExtraBold
        (900, 264),   # Black
    ]

    # Create AxisValueArray if it doesn't exist
    if not hasattr(stat_table, 'AxisValueArray') or stat_table.AxisValueArray is None:
        stat_table.AxisValueArray = otTables.AxisValueArray()
        stat_table.AxisValueArray.AxisValue = []

    # Add axis value records (Format 1: single axis)
    for i, (value, name_id) in enumerate(weights):
        axis_value = otTables.AxisValue()
        axis_value.Format = 1
        axis_value.AxisIndex = 0  # Weight axis is the first (and only) axis
        axis_value.ValueNameID = name_id
        axis_value.Value = value

        # Set flags for Regular (Elidable)
        if value == 400:
            axis_value.Flags = 0x0002  # ELIDABLE_AXIS_VALUE_NAME
        else:
            axis_value.Flags = 0

        stat_table.AxisValueArray.AxisValue.append(axis_value)

    # Update AxisValueCount
    stat_table.AxisValueCount = len(stat_table.AxisValueArray.AxisValue)

    # Save font
    font.save(font_path)
    print(f"✓ STAT table updated with {stat_table.AxisValueCount} axis values: {font_path}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python fix-stat-table.py <font.ttf>")
        sys.exit(1)

    fix_stat_table(sys.argv[1])
