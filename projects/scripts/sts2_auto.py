"""Slay the Spire 2 - Autonomous navigation"""
import pyautogui
import pygetwindow as gw
import time
import os
os.environ["PYTHONIOENCODING"] = "utf-8"
pyautogui.FAILSAFE = True
pyautogui.PAUSE = 0.5

def get_game_win():
    for w in gw.getAllWindows():
        if 'slay the spire' in (w.title or '').lower():
            return w
    return None

def activate():
    w = get_game_win()
    if w:
        w.activate()
        time.sleep(0.5)
        return w
    return None

def click_rel(x, y, win):
    pyautogui.click(win.left + x, win.top + y)
    time.sleep(0.5)

def screenshot_rel(win):
    return pyautogui.screenshot(region=(win.left, win.top, win.width, win.height))

def find_gold_buttons(img):
    """Find golden/yellow colored buttons (menu buttons in STS2)"""
    w, h = img.size
    golds = []
    for y in range(0, h, 3):
        for x in range(0, w, 3):
            r, g, b = img.getpixel((x, y))[:3]
            # Gold: high R+G, low B, saturated
            if r > 200 and g > 150 and b < 100:
                golds.append((x, y))
    # Cluster
    if not golds:
        return []
    clusters = []
    for gx, gy in golds:
        found = False
        for i, (cx, cy, cnt) in enumerate(clusters):
            if abs(gx - cx) < 40 and abs(gy - cy) < 40:
                clusters[i] = ((cx*cnt + gx)//(cnt+1), (cy*cnt + gy)//(cnt+1), cnt+1)
                found = True
                break
        if not found:
            clusters.append((gx, gy, 1))
    return clusters

def find_bright_text(img, threshold=180):
    """Find bright text areas"""
    w, h = img.size
    brights = []
    for y in range(0, h, 4):
        for x in range(0, w, 4):
            r, g, b = img.getpixel((x, y))[:3]
            if (r+g+b)//3 > threshold:
                brights.append((x, y))
    clusters = []
    for bx, by in brights:
        found = False
        for i, (cx, cy, cnt) in enumerate(clusters):
            if abs(bx - cx) < 30 and abs(by - cy) < 30:
                clusters[i] = ((cx*cnt + bx)//(cnt+1), (cy*cnt + by)//(cnt+1), cnt+1)
                found = True
                break
        if not found:
            clusters.append((bx, by, 1))
    return sorted(clusters, key=lambda c: c[2], reverse=True)

# ==== MAIN ====
print("=== STS2 Autonomous Navigator ===")
win = activate()
if not win:
    print("GAME NOT FOUND")
    exit(1)

print(f"Window: ({win.left},{win.top}) {win.width}x{win.height}")

# Step 1: Scan current state
img = screenshot_rel(win)
gold = find_gold_buttons(img)
bright = find_bright_text(img)

print(f"\nGold buttons: {len(gold)}")
for gx, gy, gc in gold[:5]:
    print(f"  Gold at rel=({gx},{gy}) count={gc}")

print(f"\nBright text clusters (top 15):")
for bx, by, bc in bright[:15]:
    print(f"  Bright at rel=({bx},{by}) count={bc}")

# Step 2: Click gold button (play/continue)
if gold:
    gx, gy, _ = gold[0]
    print(f"\n>> Clicking gold button at ({gx},{gy})")
    click_rel(gx, gy, win)
    time.sleep(2)
    
    # Check what changed
    img2 = screenshot_rel(win)
    gold2 = find_gold_buttons(img2)
    bright2 = find_bright_text(img2)
    
    print(f"\nAfter click - Gold: {len(gold2)}, Bright clusters: {len(bright2)}")
    for bx, by, bc in bright2[:10]:
        print(f"  Bright at ({bx},{by}) count={bc}")

print("\nDone with navigation step")
