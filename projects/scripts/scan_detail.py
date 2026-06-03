"""Map out where UI elements are by systematically scanning"""
import pyautogui, pygetwindow as gw, time, os
os.environ["PYTHONIOENCODING"] = "utf-8"
pyautogui.FAILSAFE = True
pyautogui.PAUSE = 0.1

def get_win():
    for w in gw.getAllWindows():
        if 'slay the spire' in (w.title or '').lower():
            return w
    return None

def shot(win):
    return pyautogui.screenshot(region=(win.left, win.top, win.width, win.height))

def scan_detail(win):
    img = shot(win)
    w, h = img.size
    print(f'Window: {w}x{h}')
    
    # Full scan for ANY non-dark pixel (brightness > 60)
    print('\n--- Non-dark pixels heatmap ---')
    lines = []
    for y in range(0, h, 20):
        row_brights = []
        for x in range(0, w, 10):
            r, g, b = img.getpixel((x, y))[:3]
            bright = (r+g+b)//3
            if bright > 60:
                row_brights.append((x, bright))
        if row_brights:
            # Show the brightest spot in each row
            best = max(row_brights, key=lambda v: v[1])
            lines.append((y, best[0], best[1]))
    
    # Show density map
    for y, x, b in lines[:30]:
        bar = '#' * (b // 10)
        print(f'y={y:4d}: x={x:4d} b={b:3d} {bar}')
    
    # Also check for the Steam overlay/green button which we clicked before
    print('\n--- Top-left corner detail (0-100 x 0-100) ---')
    for y in range(0, 100, 10):
        row = []
        for x in range(0, 100, 5):
            r, g, b = img.getpixel((x, y))[:3]
            if r > 200 and g > 200 and b < 100:
                row.append(f'[{x},{y}]')
        if row:
            print(f'y={y}: {", ".join(row[:3])}')

win = get_win()
win.activate()
time.sleep(1)
scan_detail(win)
