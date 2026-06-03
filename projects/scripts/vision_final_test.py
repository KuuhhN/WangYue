"""Vision test - using system python (main env), no proxy"""
import os
for var in ['http_proxy','https_proxy','HTTP_PROXY','HTTPS_PROXY','no_proxy']:
    os.environ.pop(var, None)

from PIL import Image
import google.genai as genai
import pyautogui

KEY_FILE = r'C:\Users\KUHN\.openclaw\workspace\projects\scripts\gemini_key.txt'
OUT_FILE = r'C:\Users\KUHN\.openclaw\workspace\projects\scripts\vision_result.txt'

key = open(KEY_FILE).read().strip()
client = genai.Client(api_key=key)

# Take fresh screenshot
img = pyautogui.screenshot()
# Crop game area (assuming STS2 is at 309,99)
img_crop = img.crop((309, 99, 309+1942, 99+1136))
img_small = img_crop.resize((800, 468))

print(f'Screenshot: {img_crop.size} -> {img_small.size}')

resp = client.models.generate_content(
    model='gemini-2.5-flash',
    contents=['Describe this game screen. What game is this? What screen/state? List ALL visible text and UI elements. ASCII only.', img_small]
)

with open(OUT_FILE, 'w', encoding='utf-8') as f:
    f.write(resp.text)
print(f'SUCCESS: {len(resp.text)} chars')
print('Snippet:', resp.text[:300])
