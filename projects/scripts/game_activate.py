"""Try to find and activate the game window"""
import pygetwindow as gw
import time
import pyautogui

# List ALL windows with any content
all_wins = gw.getAllWindows()
print(f'Total windows: {len(all_wins)}')
for w in all_wins:
    t = w.title.strip()
    if t:
        print(f'  [{w.left},{w.top} {w.width}x{w.height}] v={w.visible} | "{t[:80]}"')

# Try to find window by process or exe name
for w in all_wins:
    t = w.title.lower()
    if 'slay' in t or 'spire' in t:
        print(f'\nFound game window! Activating...')
        w.activate()
        time.sleep(1)
        print(f'After activate: v={w.visible} | ({w.left},{w.top})')
        break
else:
    print('\nNo game window found by title. Trying Steam...')
    for w in all_wins:
        if 'steam' in w.title.lower() and w.visible:
            print(f'Steam window found: "{w.title}"')
            break
