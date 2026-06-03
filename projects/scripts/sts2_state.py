"""Activate STS2, screenshot, and describe with Gemini"""
import os, sys
for var in ['http_proxy','https_proxy','HTTP_PROXY','HTTPS_PROXY']:
    os.environ.pop(var, None)

import pygetwindow as gw
import pyautogui
import time
import google.genai as genai
from PIL import Image

KEY = open(r'C:\Users\KUHN\.openclaw\workspace\projects\scripts\gemini_key.txt').read().strip()
OUT = r'C:\Users\KUHN\.openclaw\workspace\projects\scripts\game_state_current.txt'

client = genai.Client(api_key=KEY)

# Find and activate game
for w in gw.getAllWindows():
    if 'slay the spire' in (w.title or '').lower():
        print(f'Found: ({w.left},{w.top}) {w.width}x{w.height}')
        w.activate()
        time.sleep(1)
        
        # Screenshot the game area
        img = pyautogui.screenshot(region=(w.left, w.top, w.width, w.height))
        img_small = img.resize((1024, 576))
        print(f'Screenshot: {img.size} -> {img_small.size}')
        
        # Describe with Gemini
        resp = client.models.generate_content(
            model='gemini-2.5-flash',
            contents=['You are playing Slay the Spire 2. Describe the current screen in detail. What state is the game in? Main menu? Character select? Map? Combat? List ALL visible text and buttons with their approximate positions. Say what the player should click next.', img_small]
        )
        
        with open(OUT, 'w', encoding='utf-8') as f:
            f.write(resp.text)
        print(f'Vision result: {len(resp.text)} chars')
        print('=== GEMINI SAYS ===')
        print(resp.text[:500])
        print('...(truncated)')
        break
else:
    print('GAME WINDOW NOT FOUND!')
