"""Test Gemini Vision - with proxy disabled"""
import os
# Clear ALL proxy vars
for var in ['http_proxy', 'https_proxy', 'HTTP_PROXY', 'HTTPS_PROXY']:
    os.environ.pop(var, None)
os.environ['no_proxy'] = '*'

from PIL import Image
import google.genai as genai
import pyautogui

KEY_FILE = r'C:\Users\KUHN\.openclaw\workspace\projects\scripts\gemini_key.txt'
OUT_FILE = r'C:\Users\KUHN\.openclaw\workspace\projects\scripts\vision_result.txt'

key = open(KEY_FILE).read().strip()
client = genai.Client(api_key=key)

# Smaller screenshot
img = pyautogui.screenshot(region=(309, 99, 1942, 1136))
img_small = img.resize((800, 468))  # much smaller

print(f'Image size: {img_small.size}')
print('Sending to Gemini...')

resp = client.models.generate_content(
    model='gemini-2.5-flash',
    contents=['Describe this game screen. What game? What state? What text? ASCII only, no emoji.', img_small]
)

with open(OUT_FILE, 'w', encoding='utf-8') as f:
    f.write(resp.text)
print(f'Done! Result: {len(resp.text)} chars')
print('First 200:', resp.text[:200])
