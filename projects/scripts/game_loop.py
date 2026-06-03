"""Slay the Spire 2 - autonomous gameplay loop"""
import pyautogui
import pygetwindow as gw
import time
import os
os.environ["PYTHONIOENCODING"] = "utf-8"

pyautogui.FAILSAFE = True
pyautogui.PAUSE = 0.3

def find_game_window():
    """Find the STS2 window"""
    for win in gw.getAllWindows():
        if 'slay the spire' in (win.title or '').lower():
            return win
    return None

def activate_game():
    """Bring game window to front"""
    win = find_game_window()
    if win:
        win.activate()
        time.sleep(1)
        return win
    return None

def screenshot_game():
    """Take screenshot of game area"""
    win = find_game_window()
    if win and win.visible:
        # Screenshot just the game window
        img = pyautogui.screenshot(region=(win.left, win.top, win.width, win.height))
        return img, win
    # Full screenshot as fallback
    img = pyautogui.screenshot()
    return img, None

def describe_screen(img):
    """Use pixel sampling to describe what's on screen"""
    w, h = img.size
    areas = {}
    
    # Check center area
    cx, cy = w//2, h//2
    areas['center'] = img.getpixel((cx, cy))
    
    # Top area (could be main menu)
    areas['top'] = img.getpixel((cx, 30))
    areas['top_mid'] = img.getpixel((cx, h//4))
    
    # Bottom area (could be buttons)
    areas['bottom'] = img.getpixel((cx, h-30))
    areas['bottom_mid'] = img.getpixel((cx, 3*h//4))
    
    # Left/right edges
    areas['left'] = img.getpixel((30, cy))
    areas['right'] = img.getpixel((w-30, cy))
    
    return areas

def click_game(x, y, win=None):
    """Click at game coordinates (relative to game window)"""
    if win:
        abs_x = win.left + x
        abs_y = win.top + y
    else:
        abs_x, abs_y = x, y
    pyautogui.click(abs_x, abs_y)
    time.sleep(0.5)

def detect_state(areas, img):
    """Use pixel patterns to detect current game state"""
    w, h = img.size
    
    # Check if on main menu (looking for bright text/buttons)
    for y in range(h//3, 2*h//3, 20):
        for x in range(w//4, 3*w//4, 20):
            r, g, b = img.getpixel((x, y))[:3]
            if r > 150 and g > 150 and b > 150:
                return 'menu_with_text'
    
    # Check for combat (card area at bottom)
    bottom_h = int(h * 0.6)
    bright_bottom = 0
    dark_bottom = 0
    for x in range(50, w-50, 10):
        for y in range(bottom_h, h-20, 10):
            px = img.getpixel((x, y))
            if sum(px[:3]) > 300:
                bright_bottom += 1
            elif sum(px[:3]) < 50:
                dark_bottom += 1
    
    if bright_bottom > 20:
        return 'combat_player_hand'
    
    if all(c < 50 for c in areas['center'][:3]) and any(c > 100 for c in areas['bottom'][:3]):
        return 'loading_or_map'
    
    return 'unknown'

# Main loop - first iteration
print("=== STS2 Auto-Play Loop ===")
win = activate_game()
if not win:
    print("Game window not found!")
    exit(1)

print(f"Game window: ({win.left},{win.top}) {win.width}x{win.height}")

# Take initial screenshot
img, _ = screenshot_game()
img.save(r'C:\Users\KUHN\.openclaw\workspace\projects\scripts\game_state_initial.png')

# Analyze
areas = describe_screen(img)
state = detect_state(areas, img)
print(f"Detected state: {state}")
print(f"Center: RGB{areas['center']}")
print(f"Top: RGB{areas['top']} | Bottom: RGB{areas['bottom']}")
print(f"Left: RGB{areas['left']} | Right: RGB{areas['right']}")
