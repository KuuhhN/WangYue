"""Try keyboard to get past splash/loading screens"""
import pyautogui, pygetwindow as gw, time, os, hashlib
os.environ["PYTHONIOENCODING"] = "utf-8"
pyautogui.FAILSAFE = True

def get_win():
    for w in gw.getAllWindows():
        if 'slay the spire' in (w.title or '').lower():
            return w
    return None

def shot(win):
    return pyautogui.screenshot(region=(win.left, win.top, win.width, win.height))

def screen_hash(win):
    img = shot(win)
    w, h = img.size
    data = []
    for y in range(0, h, 50):
        for x in range(0, w, 50):
            data.append(str(img.getpixel((x, y))))
    return hashlib.md5(''.join(data).encode()).hexdigest()[:8]

win = get_win()
if not win:
    print("No game window!")
    exit(1)
win.activate()
time.sleep(1)

base_hash = screen_hash(win)
print(f"Initial hash: {base_hash}")

# Step 1: Try pressing Enter/Space/Escape (common for splash/license screens)
keys_to_try = ['enter', 'space', 'escape', 'any key']
for key in keys_to_try:
    print(f"\n>> Pressing: {key}")
    if key == 'any key':
        pyautogui.press('enter')
        time.sleep(0.2)
        pyautogui.press('space')
        time.sleep(0.2)
        pyautogui.press('escape')
    else:
        pyautogui.press(key)
    time.sleep(1.5)
    new_hash = screen_hash(win)
    if new_hash != base_hash:
        print(f">>> SCREEN CHANGED! {base_hash} -> {new_hash}")
        base_hash = new_hash
        break
    else:
        print(f"  No change (hash={new_hash})")

# Step 2: If splash passed, try clicking center area
if base_hash != screen_hash(win):
    time.sleep(1)
    base_hash = screen_hash(win)

# Click center area now
print("\n>> Clicking center of game...")
pyautogui.click(win.left + win.width//2, win.top + win.height//2)
time.sleep(2)

new_hash = screen_hash(win)
print(f"After center click: {new_hash}")
if new_hash != base_hash:
    print(">>> Click worked! Menu appeared!")
    
    # Scan what we see now
    print("\n--- Current screen scan ---")
    img = shot(win)
    w, h = img.size
    for y in range(0, h, 30):
        row = []
        for x in range(0, w, 30):
            r, g, b = img.getpixel((x, y))[:3]
            if (r+g+b)//3 > 100:
                row.append(f'({x},{y})R{r}G{g}B{b}')
        if row:
            print(f'y={y}: {row[0]}')
    print(f"\nFinal hash: {new_hash}")
else:
    print("Screen same. Game might need mouse movement or Steam interaction")
