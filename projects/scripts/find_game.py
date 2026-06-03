"""Find STS2 game window"""
import pygetwindow as gw
import sys

for w in gw.getAllWindows():
    t = (w.title or '').lower()
    if 'slay' in t or 'spire' in t:
        print(f'GAME: "{w.title}" | ({w.left},{w.top}) {w.width}x{w.height} v={w.visible}')
        sys.exit(0)

for w in gw.getAllWindows():
    t = (w.title or '').lower()
    if 'steam' in t and w.visible:
        print(f'STEAM: ({w.left},{w.top}) {w.width}x{w.height}')

print('NO GAME WINDOW FOUND')
