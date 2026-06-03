"""Try Gemini vision through proxy"""
import os
# Try WITHOUT proxy first (set explicit empty values)
os.environ.pop('http_proxy', None)
os.environ.pop('https_proxy', None)
os.environ.pop('HTTP_PROXY', None)
os.environ.pop('HTTPS_PROXY', None)
os.environ['no_proxy'] = '*'

import time, google.genai as genai
from PIL import Image

KEY = open(r'C:\Users\KUHN\.openclaw\workspace\projects\scripts\gemini_key.txt').read().strip()
OUT = r'C:\Users\KUHN\.openclaw\workspace\projects\scripts\gemini_output.txt'

print('Connecting to Gemini...')
t0 = time.time()
client = genai.Client(api_key=KEY)
print(f'Client init: {time.time()-t0:.1f}s')

img = Image.open(r'C:\Users\KUHN\.openclaw\workspace\projects\scripts\game_screenshot_small.png')

print('Sending image for analysis...')
t1 = time.time()
try:
    resp = client.models.generate_content(
        model='gemini-2.5-flash',
        contents=['Describe this Slay the Spire 2 screen. Format: STATE, TEXT, BUTTONS, WHAT TO CLICK, DESCRIPTION.', img],
        config={'timeout': 60000}
    )
    elapsed = time.time() - t1
    print(f'Response: {elapsed:.1f}s')
    
    with open(OUT, 'w', encoding='utf-8') as f:
        f.write(resp.text)
    print(f'Saved ({len(resp.text)} chars)')
    print('---')
    print(resp.text)
except Exception as e:
    print(f'Direct failed: {e}')
    
    # Retry through proxy
    print('\nTrying through proxy...')
    os.environ['http_proxy'] = 'http://127.0.0.1:7890'
    os.environ['https_proxy'] = 'http://127.0.0.1:7890'
    del os.environ['no_proxy']
    
    client2 = genai.Client(api_key=KEY)
    try:
        resp2 = client2.models.generate_content(
            model='gemini-2.5-flash',
            contents=['Describe this Slay the Spire 2 screen.', img],
        )
        with open(OUT, 'w', encoding='utf-8') as f:
            f.write(resp2.text)
        print(f'Proxy success! Saved ({len(resp2.text)} chars)')
        print(resp2.text)
    except Exception as e2:
        print(f'Proxy also failed: {e2}')
        with open(OUT, 'w', encoding='utf-8') as f:
            f.write(f'Both connections failed.\nDirect: {e}\nProxy: {e2}')
