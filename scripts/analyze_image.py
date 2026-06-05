import base64, json, urllib.request, os

# Read image
with open(r'C:\Users\KUHN\.openclaw\media\inbound\11af5054-1f3a-453b-96dd-2d8cd0a3dca5.jpg', 'rb') as f:
    b64 = base64.b64encode(f.read()).decode()

print(f"Image size: {len(b64)} bytes base64")

# Gemini API direct
api_key = os.environ.get('GEMINI_API_KEY', '')
url = f"https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent?key={api_key}"

body = json.dumps({
    "contents": [{
        "parts": [
            {"text": "描述这张图片的内容，用中文回答，尽可能详细。"},
            {"inline_data": {"mime_type": "image/jpeg", "data": b64}}
        ]
    }]
}).encode()

req = urllib.request.Request(url, data=body, headers={'Content-Type': 'application/json'})
print("Sending to Gemini 2.5 Flash...")

try:
    resp = urllib.request.urlopen(req, timeout=30)
    data = json.loads(resp.read())
    print(data['candidates'][0]['content']['parts'][0]['text'])
except urllib.request.HTTPError as e:
    print(f"HTTP {e.code}: {e.read().decode()[:500]}")
except Exception as e:
    print(f"Error: {e}")
