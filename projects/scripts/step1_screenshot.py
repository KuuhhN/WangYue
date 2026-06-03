"""Step 1: Activate game + take screenshot"""
import os
for var in ['http_proxy','https_proxy','HTTP_PROXY','HTTPS_PROXY']:
    os.environ.pop(var, None)
import pygetwindow as gw, pyautogui, time

for w in gw.getAllWindows():
    if 'slay the spire' in (w.title or '').lower():
        w.activate()
        time.sleep(1)
        img = pyautogui.screenshot(region=(w.left, w.top, w.width, w.height))
        img.save(r'C:\Users\KUHN\.openclaw\workspace\projects\scripts\game_screenshot.png')
        # Also save small version for Gemini
        img_small = img.resize((1024, 576))
        img_small.save(r'C:\Users\KUHN\.openclaw\workspace\projects\scripts\game_screenshot_small.png')
        print(f'OK: ({w.left},{w.top}) {w.width}x{w.height}')
        print(f'Saved: {img.size} -> small: {img_small.size}')
        break
else:
    print('ERROR: No game window')
