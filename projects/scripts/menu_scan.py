"""Scan the game menu for clickable buttons"""
import pyautogui
import pygetwindow as gw
import time
import os
os.environ["PYTHONIOENCODING"] = "utf-8"

# Activate game
for win in gw.getAllWindows():
    if 'slay the spire' in (win.title or '').lower():
        win.activate()
        break
time.sleep(1)

# Screenshot game area
for win in gw.getAllWindows():
    if 'slay the spire' in (win.title or '').lower():
        img = pyautogui.screenshot(region=(win.left, win.top, win.width, win.height))
        gw_w, gw_h = win.width, win.height
        break

w, h = img.size
print(f'Game area: {w}x{h}')

# Scan for non-dark pixels (potential UI elements)
# STS2 has a dark theme, so bright pixels are likely text/buttons
print('\n=== Bright pixel clusters (likely UI/buttons) ===')
bright_spots = []
for y in range(0, h, 5):
    for x in range(0, w, 5):
        r, g, b = img.getpixel((x, y))
        brightness = (r + g + b) / 3
        if brightness > 100:
            bright_spots.append((x, y, r, g, b))

# Group nearby spots
if bright_spots:
    print(f'Total bright pixels: {len(bright_spots)} (sampled every 5px)')
    # Show unique regions
    regions = []
    for sx, sy, sr, sg, sb in bright_spots:
        found = False
        for ri, (rx, ry, rw, rh, cr, cg, cb) in enumerate(regions):
            if abs(sx - rx) < 50 and abs(sy - ry) < 50:
                regions[ri] = ((rx+rx)//2, (ry+ry)//2, max(rw, abs(sx-rx)), max(rh, abs(sy-ry)), cr, cg, cb)
                found = True
                break
        if not found:
            regions.append((sx, sy, 5, 5, sr, sg, sb))
    
    print(f'\nUI element clusters ({len(regions)}):')
    for rx, ry, rw, rh, cr, cg, cb in sorted(regions, key=lambda r: r[1]):
        if rw > 10 or rh > 10:  # only meaningful clusters
            print(f'  ({rx},{ry}) size~{rw}x{rh} color=RGB({cr},{cg},{cb})')
else:
    print('No bright pixels found')

# Also check for blue/colored UI elements
print('\n=== Colored pixel clusters ===')
colored = []
for y in range(0, h, 5):
    for x in range(0, w, 5):
        r, g, b = img.getpixel((x, y))[:3]
        # Check for saturated colors (not gray)
        if max(r,g,b) - min(r,g,b) > 40 and max(r,g,b) > 60:
            colored.append((x, y, r, g, b))

print(f'Colored pixels: {len(colored)}')
for cx, cy, cr, cg, cb in colored[:20]:
    print(f'  ({cx},{cy}): RGB({cr},{cg},{cb})')
