import pygetwindow as gw
import psutil

# Check processes
for proc in psutil.process_iter(['pid', 'name']):
    name = proc.info['name'].lower() if proc.info['name'] else ''
    if 'slay' in name or 'spire' in name:
        print(f'PROC: {proc.info["name"]} (pid={proc.info["pid"]})')

# Check ALL windows
all_wins = gw.getAllWindows()
print(f'Total windows: {len(all_wins)}')
for w in all_wins:
    t = (w.title or '').lower()
    if t and ('slay' in t or 'spire' in t or 'sts2' in t or 'unity' in t):
        print(f'MATCH: {w.title[:80]} | v={w.visible} | ({w.left},{w.top}) {w.width}x{w.height}')

# Also print a few window titles that are visible and have content
print('\n--- Top 10 visible windows ---')
count = 0
for w in all_wins:
    if w.visible and w.title.strip():
        print(f'  {w.title[:60]}')
        count += 1
        if count >= 10:
            break
