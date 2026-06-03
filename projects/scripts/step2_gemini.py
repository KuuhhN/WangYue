"""Step 2: Gemini vision analysis of the screenshot"""
import os, sys, time
for var in ['http_proxy','https_proxy','HTTP_PROXY','HTTPS_PROXY']:
    os.environ.pop(var, None)

import google.genai as genai
from PIL import Image

KEY = open(r'C:\Users\KUHN\.openclaw\workspace\projects\scripts\gemini_key.txt').read().strip()

t0 = time.time()
client = genai.Client(api_key=KEY)
print(f'Client init: {time.time()-t0:.1f}s')

img = Image.open(r'C:\Users\KUHN\.openclaw\workspace\projects\scripts\game_screenshot_small.png')
print(f'Image loaded: {img.size}')

t1 = time.time()
resp = client.models.generate_content(
    model='gemini-2.5-flash',
    contents=['''You are playing Slay the Spire 2. Describe the current screen. Answer in this format:

STATE: (main_menu / character_select / map / combat / reward / rest_site / shop / game_over / other)

TEXT VISIBLE: (list all text)

BUTTONS: (list all clickable buttons with positions)

WHAT TO CLICK NEXT: (one specific instruction)

SCREEN DESCRIPTION: (brief description)

Only use ASCII characters.''', img]
)
elapsed = time.time() - t1
print(f'Gemini response: {elapsed:.1f}s')

with open(r'C:\Users\KUHN\.openclaw\workspace\projects\scripts\gemini_output.txt', 'w', encoding='utf-8') as f:
    f.write(resp.text)
print(f'Saved ({len(resp.text)} chars)')
print(resp.text)
