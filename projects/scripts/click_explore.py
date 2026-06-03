"""Systematic click exploration - try each bright area until screen changes"""
import pyautogui, pygetwindow as gw, time, os, hashlib
os.environ["PYTHONIOENCODING"] = "utf-8"
pyautogui.FAILSAFE = True
pyautogui.PAUSE = 0.3

def get_win():
    for w in gw.getAllWindows():
        if 'slay the spire' in (w.title or '').lower():
            return w
    return None

def shot(win):
    return pyautogui.screenshot(region=(win.left, win.top, win.width, win.height))

def screen_hash(win):
    """Simple hash to detect screen changes"""
    img = shot(win)
    w, h = img.size
    # Sample pixels at grid points
    data = []
    for y in range(0, h, 50):
        for x in range(0, w, 50):
            data.append(str(img.getpixel((x, y))))
    return hashlib.md5(''.join(data).encode()).hexdigest()[:8]

def click_rel(x, y, win):
    pyautogui.click(win.left + x, win.top + y)
    time.sleep(1.5)

win = get_win()
if not win:
    print("No game window!")
    exit(1)
win.activate()
time.sleep(1)

# Get initial hash
base_hash = screen_hash(win)
print(f"Initial screen hash: {base_hash}")

# Clicks to try (relative to game window) - major UI areas
# These are educated guesses based on pixel analysis
click_points = [
    # Center menu areas (trying a grid)
    (win.width//2, 290, "Center-290"),
    (win.width//2, 320, "Center-320"),
    (win.width//2, 360, "Center-360"),
    (win.width//2, 400, "Center-400"),
    (win.width//2, 450, "Center-450"),
    (win.width//2, win.height//2, "Center-mid"),
    # Gold button edge areas
    (864, 294, "Gold-left"),
    (970, 294, "Gold-right"),
    (912, 300, "Gold-bottom"),
    # Bottom right (often has "play/confirm")
    (win.width-200, win.height-200, "Bottom-right"),
    (win.width-300, win.height-150, "Bottom-right2"),
    # Text areas
    (750, 380, "Text-upper"),
    (950, 380, "Text-upper2"),
    (740, 540, "Text-mid"),
    (825, 540, "Text-mid2"),
    (960, 540, "Text-mid3"),
]

for x, y, label in click_points:
    print(f"\nTrying: {label} ({x},{y})...")
    click_rel(x, y, win)
    new_hash = screen_hash(win)
    if new_hash != base_hash:
        print(f">>> SCREEN CHANGED! Hash: {base_hash} -> {new_hash}")
        print(f">>> Found clickable area: {label}")
        break
    else:
        print(f"  No change (hash={new_hash})")
    time.sleep(0.5)
else:
    print("\nNone of the click points changed the screen.")
    print("Game might need Steam interaction or is in a special state.")
