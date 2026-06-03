"""Check game state by pixel analysis and try to interact"""
import pyautogui
import time
import os

os.environ["PYTHONIOENCODING"] = "utf-8"

# Screenshot
img = pyautogui.screenshot()
w, h = img.size
print(f'Screen: {w}x{h}')

# Sample grid pattern to detect game content
# Check center area for game-like pixel patterns
samples = {}
for y in range(0, h, 100):
    for x in range(0, w, 200):
        px = img.getpixel((x, y))
        key = f'({x},{y})'
        samples[key] = px

# Show some relevant samples
for key in sorted(samples.keys()):
    px = samples[key]
    r, g, b = px[:3]
    # Highlight dark, bright, or colorful pixels
    if r > 200 and g > 200:
        print(f'{key}: RGB({r},{g},{b}) <-- BRIGHT')
    elif r < 30 and g < 30 and b < 30:
        pass  # skip solid black
    elif abs(r-g) > 30 or abs(g-b) > 30 or abs(r-b) > 30:
        print(f'{key}: RGB({r},{g},{b}) <-- COLORED')
    elif r > 100 or g > 100:
        print(f'{key}: RGB({r},{g},{b})')

# Check if game might be at specific locations
# Sample fullscreen vs windowed regions
print('\n--- Fullscreen check ---')
center_line = [img.getpixel((x, h//2)) for x in range(0, w, 50)]
dark_count = sum(1 for p in center_line if all(c < 40 for c in p[:3]))
bright_count = sum(1 for p in center_line if all(c > 200 for c in p[:3]))
print(f'Center line: {dark_count} dark / {bright_count} bright pixels')
