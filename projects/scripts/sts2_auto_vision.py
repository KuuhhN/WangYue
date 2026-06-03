"""Execute action based on Gemini's vision analysis"""
import os, requests, base64, json, time, pyautogui, pygetwindow as gw

KEY = open(r'C:\Users\KUHN\.openclaw\workspace\projects\scripts\gemini_key.txt').read().strip()
SS_FILE = r'C:\Users\KUHN\.openclaw\workspace\projects\scripts\game_screenshot.png'
OUT_FILE = r'C:\Users\KUHN\.openclaw\workspace\projects\scripts\gemini_output.txt'
PROXY = 'http://127.0.0.1:7890'

def find_game():
    for w in gw.getAllWindows():
        if 'slay the spire' in (w.title or '').lower():
            return w
    return None

def screenshot(win):
    img = pyautogui.screenshot(region=(win.left, win.top, win.width, win.height))
    img_small = img.resize((1024, 576))
    img_small.save(SS_FILE.replace('.png', '_small.png'))
    return img_small

def ask_gemini(prompt_extra=''):
    prompt = f'''You are playing Slay the Spire 2. Describe the current screen. Answer in EXACT format:

STATE: (one word: main_menu / character_select / map / combat / reward / rest_site / shop / game_over / boss_relic)

TEXT: (all visible text, comma separated)

BUTTONS: (all clickable elements with relative positions as x,y or region descriptions)

WHAT TO CLICK: (specific coordinates or element name, ONE action only)

BRIEF: (one line description)
{prompt_extra}'''
    
    with open(SS_FILE.replace('.png', '_small.png'), 'rb') as f:
        img_b64 = base64.b64encode(f.read()).decode()
    
    url = f'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key={KEY}'
    resp = requests.post(url, json={'contents': [{'parts': [
        {'text': prompt},
        {'inline_data': {'mime_type': 'image/png', 'data': img_b64}}
    ]}]}, timeout=30, proxies={'http': PROXY, 'https': PROXY})
    
    text = resp.json()['candidates'][0]['content']['parts'][0]['text']
    with open(OUT_FILE, 'w', encoding='utf-8') as f:
        f.write(text)
    return text

def parse_gemini(text):
    """Extract state and what to click from Gemini response"""
    state = ''
    click = ''
    for line in text.split('\n'):
        if line.startswith('STATE:'):
            state = line.replace('STATE:', '').strip()
        if line.startswith('WHAT TO CLICK:'):
            click = line.replace('WHAT TO CLICK:', '').strip()
    return state, click

def click_button(win, description):
    """Click based on Gemini's description"""
    # Try clicking the center of the game window (fallback)
    cx, cy = win.left + win.width//2, win.top + win.height//2
    pyautogui.click(cx, cy)
    time.sleep(1)

# === MAIN LOOP ===
print("=== STS2 Auto-Player ===")
win = find_game()
if not win:
    print("GAME NOT FOUND!")
    exit(1)
win.activate()
time.sleep(1)

# Step 1: See main menu
print('\n[STEP 1] Analyzing main menu...')
screenshot(win)
result = ask_gemini()
state, click = parse_gemini(result)
print(f'State: {state}')
print(f'Next: {click}')
print(result)

# Step 2: Click "单人模式" 
# Based on Gemini's analysis, click single player button
# The button should be somewhere on screen
print(f'\n[STEP 2] Clicking: {click}')
# Try clicking center of game - likely where the main button is
cx = win.left + win.width // 2
cy = win.top + win.height // 2
pyautogui.click(cx, cy)
time.sleep(2)

# Step 3: See what changed
screenshot(win)
result2 = ask_gemini()
state2, click2 = parse_gemini(result2)
print(f'\n[STEP 3] State: {state2}')
print(f'Next: {click2}')
print(result2)
