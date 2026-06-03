import pyautogui, pygetwindow as gw

# Screenshot
img = pyautogui.screenshot()
w, h = img.size
print(f'SCREEN: {w}x{h}')

# Key areas
points = [(100,100), (w//2,50), (w//2, h//2), (w//2, h-50),
           (400,300), (400,400), (400,500), (600,1300),
           (200,200), (1200,1400), (1000,1400),
           (200,1300), (w//4, h//2), (3*w//4, h//2)]
for x,y in points:
    px = img.getpixel((x,y))
    print(f'  ({x},{y}): RGB{px[:3]}')

# Window list
print('\nWINDOWS:')
for win in gw.getAllWindows():
    t = win.title.strip()
    if t:
        print(f'  [{win.left},{win.top}] v={win.visible} | {t[:60]}')
