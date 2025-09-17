#!/usr/bin/env python3
"""
Simple script to crop 10% from each side of 1024.png
"""

from PIL import Image

def crop_icon(file_path, target_size):
    # Open the image
    img = Image.open(file_path)
    width, height = img.size

    print(f"Processing {file_path.split('/')[-1]} - Original size: {width}x{height}")

    # Calculate 15% crop from each side
    crop_amount = int(width * 0.15)  # 15% of width

    # Crop coordinates: left, top, right, bottom
    left = crop_amount
    top = crop_amount
    right = width - crop_amount
    bottom = height - crop_amount

    # Crop the image
    cropped = img.crop((left, top, right, bottom))

    # Resize back to target size to maintain required dimensions
    resized = cropped.resize((target_size, target_size), Image.Resampling.LANCZOS)

    # Save the result
    resized.save(file_path, "PNG")
    print(f"  ✓ Updated successfully")

def crop_all_icons():
    icon_dir = "ios/Runner/Assets.xcassets/AppIcon.appiconset"

    # List of icon files with their sizes
    icon_files = [
        ("29.png", 29), ("40.png", 40), ("57.png", 57), ("58.png", 58),
        ("60.png", 60), ("80.png", 80), ("87.png", 87), ("114.png", 114),
        ("120.png", 120), ("152.png", 152), ("167.png", 167),
        ("180.png", 180), ("1024.png", 1024)
    ]

    print("Cropping 15% from all app icons...")
    print("=" * 40)

    for filename, size in icon_files:
        file_path = f"{icon_dir}/{filename}"
        crop_icon(file_path, size)

    print(f"\n✓ All {len(icon_files)} icons updated successfully!")

if __name__ == "__main__":
    crop_all_icons()