"""Gemini Vision - 截图 + 画面描述 + OCR 一站式"""
import sys, json, base64, os
os.environ["PYTHONIOENCODING"] = "utf-8"

# Load Gemini API key
KEY_FILE = r'C:\Users\KUHN\.openclaw\workspace\projects\scripts\gemini_key.txt'
API_KEY = open(KEY_FILE).read().strip()

import google.genai as genai
from google.genai import types
from PIL import Image
import io

client = genai.Client(api_key=API_KEY)

def describe_screenshot(image_path=None, image_obj=None, prompt=None):
    """Send image to Gemini and get description"""
    if prompt is None:
        prompt = """Describe this screen in detail for an autonomous game bot:
1. What game/application is this? What screen/state?
2. What text elements can you see? List ALL text visible.
3. What buttons or interactive elements exist? Give their approximate positions (left, top, right, bottom bounds).
4. What is the player supposed to do next?
Be specific and precise with positions."""
    
    if image_obj:
        img = image_obj
    elif image_path:
        img = Image.open(image_path)
    
    # Resize if too large
    max_size = 1280
    if max(img.size) > max_size:
        ratio = max_size / max(img.size)
        img = img.resize((int(img.size[0]*ratio), int(img.size[1]*ratio)))
    
    response = client.models.generate_content(
        model="gemini-2.5-flash",
        contents=[prompt, img]
    )
    
    return response.text

def detect_game_state(description):
    """Use description to detect game state"""
    desc_lower = description.lower()
    
    if 'main menu' in desc_lower or 'play' in desc_lower:
        return 'main_menu'
    elif 'character select' in desc_lower or 'choose' in desc_lower:
        return 'character_select'
    elif 'map' in desc_lower:
        return 'map'
    elif 'combat' in desc_lower or 'enemy' in desc_lower or 'hp' in desc_lower:
        return 'combat'
    elif 'reward' in desc_lower or 'card' in desc_lower:
        return 'reward'
    elif 'rest' in desc_lower or 'campfire' in desc_lower:
        return 'rest_site'
    elif 'shop' in desc_lower or 'merchant' in desc_lower:
        return 'shop'
    elif 'game over' in desc_lower or 'defeated' in desc_lower:
        return 'game_over'
    elif 'loading' in desc_lower:
        return 'loading'
    else:
        return 'unknown'

def describe_brief(image_path, custom_prompt=None):
    """Quick description for game state"""
    text = describe_screenshot(image_path=image_path, prompt=custom_prompt)
    state = detect_game_state(text)
    return {
        "description": text,
        "state": state
    }

if __name__ == "__main__":
    # Test
    if len(sys.argv) > 1:
        path = sys.argv[1]
    else:
        path = r'C:\Users\KUHN\.openclaw\workspace\projects\scripts\sts2_v3.png'
    
    import time
    t0 = time.time()
    result = describe_brief(path)
    elapsed = time.time() - t0
    print(json.dumps({
        "elapsed_seconds": round(elapsed, 1),
        "detected_state": result["state"],
        "description": result["description"]
    }, ensure_ascii=False, indent=2))
