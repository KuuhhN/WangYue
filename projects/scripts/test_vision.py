"""Test Gemini Vision - save result to file"""
import os, sys
os.environ['no_proxy'] = 'localhost,127.0.0.1,.deepseek.com'

from PIL import Image
import google.genai as genai
import pyautogui

KEY_FILE = r'C:\Users\KUHN\.openclaw\workspace\projects\scripts\gemini_key.txt'
OUT_FILE = r'C:\Users\KUHN\.openclaw\workspace\projects\scripts\vision_result.txt'
SS_FILE = r'C:\Users\KUHN\.openclaw\workspace\projects\scripts\vision_test.png'

key = open(KEY_FILE).read().strip()
client = genai.Client(api_key=key)

# Fresh screenshot
img = pyautogui.screenshot(region=(309, 99, 1942, 1136))
img.save(SS_FILE)

# Resize
max_size = 1024
ratio = max_size / max(img.size)
img_small = img.resize((int(img.size[0]*ratio), int(img.size[1]*ratio)))

resp = client.models.generate_content(
    model='gemini-2.5-flash',
    contents=['Describe this game screen DETAILED. Game name, current state/menu, ALL text visible, ALL buttons with positions relative to 1942x1136 game window. Use ASCII only.', img_small]
)

with open(OUT_FILE, 'w', encoding='utf-8') as f:
    f.write(f'Image size: {img.size}\n')
    f.write(f'Analyzed at: {img_small.size}\n')
    f.write('='*60 + '\n')
    f.write(resp.text)

print(f'Result saved ({len(resp.text)} chars)')
