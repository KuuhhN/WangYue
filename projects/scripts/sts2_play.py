"""Navigate STS2: click the main PLAY button and select a character"""
import pyautogui, pygetwindow as gw, time, os
os.environ["PYTHONIOENCODING"] = "utf-8"
pyautogui.FAILSAFE = True
pyautogui.PAUSE = 0.4

def get_win():
    for w in gw.getAllWindows():
        if 'slay the spire' in (w.title or '').lower():
            return w
    return None

def click_rel(x, y, win):
    pyautogui.click(win.left + x, win.top + y)
    time.sleep(1)

def shot(win):
    return pyautogui.screenshot(region=(win.left, win.top, win.width, win.height))

def scan(win, label):
    img = shot(win)
    w, h = img.size
    print(f'\n=== {label} ===')
    
    # Find gold
    gold = []
    for y in range(0, h, 2):
        for x in range(0, w, 2):
            r, g, b = img.getpixel((x, y))[:3]
            if r > 200 and g > 160 and b < 100:
                gold.append((x, y))
    if gold:
        # Cluster
        clusters = []
        for gx, gy in gold:
            found = False
            for i, (cx, cy, cnt) in enumerate(clusters):
                if abs(gx-cx) < 30 and abs(gy-cy) < 30:
                    clusters[i] = ((cx*cnt+gx)//(cnt+1), (cy*cnt+gy)//(cnt+1), cnt+1)
                    found = True
                    break
            if not found:
                clusters.append((gx, gy, 1))
        print(f'Gold buttons ({len(clusters)}):')
        for cx, cy, cnt in sorted(clusters, key=lambda c: -c[2])[:8]:
            px = img.getpixel((cx, cy))
            print(f'  ({cx},{cy}) size={cnt} RGB{px[:3]}')
    
    # Find bright white text
    bright = []
    for y in range(0, h, 3):
        for x in range(0, w, 3):
            r, g, b = img.getpixel((x, y))[:3]
            if r > 200 and g > 200 and b > 200:
                bright.append((x, y))
    if bright:
        clusters = []
        for bx, by in bright:
            found = False
            for i, (cx, cy, cnt) in enumerate(clusters):
                if abs(bx-cx) < 25 and abs(by-cy) < 25:
                    clusters[i] = ((cx*cnt+bx)//(cnt+1), (cy*cnt+by)//(cnt+1), cnt+1)
                    found = True
                    break
            if not found:
                clusters.append((bx, by, 1))
        print(f'White text ({len(clusters)}):')
        for cx, cy, cnt in sorted(clusters, key=lambda c: -c[2])[:8]:
            print(f'  ({cx},{cy}) size={cnt}')
    
    return img, clusters if 'gold' in dir() else []

print("=== STS2 - Navigate Menu ===")
win = get_win()
if not win:
    print("Game not found!")
    exit(1)
win.activate()
time.sleep(1)

# Scan main menu
img, _ = scan(win, "MAIN MENU")

# Click the big gold button (PLAY) at ~(928,292)
# That's the one with 57 gold pixels
target = (928, 292)
print(f'\n>> Clicking PLAY at ({target[0]},{target[1]})...')
click_rel(target[0], target[1], win)
time.sleep(2)

# Scan character select
scan(win, "AFTER PLAY CLICK")

# Now try clicking center-bottom area where "play/select" would be
# In STS2 character select, clicking the character portrait selects them, 
# then a play button appears
# Let's try clicking center-left character
print('\n>> Trying to select first character...')
click_rel(600, 500, win)  # left character
time.sleep(2)

scan(win, "AFTER CHARACTER CLICK")
