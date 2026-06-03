"""Desktop Control Bridge - 望月桌面操控接口"""
import sys, json, time, os

os.environ["PYTHONIOENCODING"] = "utf-8"

try:
    import pyautogui
    pyautogui.FAILSAFE = True
    pyautogui.PAUSE = 0.1
except Exception as e:
    print(json.dumps({"error": "pyautogui import fail: " + str(e)}))
    sys.exit(1)


def cmd_move(x, y, duration=0.2):
    pyautogui.moveTo(x, y, duration=duration)
    return {"ok": True, "pos": (x, y)}


def cmd_click(x=None, y=None, button="left", clicks=1):
    if x is not None and y is not None:
        pyautogui.click(x, y, clicks=clicks, button=button)
    else:
        pyautogui.click(clicks=clicks, button=button)
    return {"ok": True}


def cmd_double_click(x=None, y=None):
    pyautogui.doubleClick(x, y)
    return {"ok": True}


def cmd_type(text, interval=0.05):
    pyautogui.typewrite(text, interval=interval)
    return {"ok": True, "chars": len(text)}


def cmd_press(keys):
    for k in keys:
        pyautogui.keyDown(k)
    for k in reversed(keys):
        pyautogui.keyUp(k)
    return {"ok": True}


def cmd_hotkey(*keys):
    pyautogui.hotkey(*keys)
    return {"ok": True}


def cmd_scroll(clicks, x=None, y=None):
    pyautogui.scroll(clicks, x, y)
    return {"ok": True, "clicks": clicks}


def cmd_screenshot(path=None):
    img = pyautogui.screenshot()
    if path:
        img.save(path)
        return {"ok": True, "path": path, "size": img.size}
    return {"ok": True, "size": img.size}


def cmd_locate(image_path, confidence=0.9):
    try:
        pos = pyautogui.locateOnScreen(image_path, confidence=confidence)
        if pos:
            return {"ok": True, "found": True, "x": pos.left, "y": pos.top,
                    "w": pos.width, "h": pos.height,
                    "center": (pos.left + pos.width//2, pos.top + pos.height//2)}
        return {"ok": True, "found": False}
    except Exception as e:
        return {"ok": False, "error": str(e)}


def cmd_screen_size():
    w, h = pyautogui.size()
    return {"ok": True, "width": w, "height": h}


def cmd_position():
    x, y = pyautogui.position()
    return {"ok": True, "x": x, "y": y}


def cmd_drag(x, y, duration=0.3):
    pyautogui.drag(x, y, duration=duration)
    return {"ok": True}


COMMANDS = {
    "move": cmd_move,
    "click": cmd_click,
    "doubleclick": cmd_double_click,
    "type": cmd_type,
    "press": cmd_press,
    "hotkey": cmd_hotkey,
    "scroll": cmd_scroll,
    "screenshot": cmd_screenshot,
    "locate": cmd_locate,
    "screensize": cmd_screen_size,
    "position": cmd_position,
    "drag": cmd_drag,
}


def main():
    if len(sys.argv) < 2:
        print(json.dumps({"error": "Usage: desktop.py <command> [args JSON]", "commands": list(COMMANDS.keys())}))
        sys.exit(1)

    action = sys.argv[1]
    if action == "list":
        print(json.dumps({"commands": list(COMMANDS.keys())}))
        return

    if action not in COMMANDS:
        print(json.dumps({"error": "Unknown command: " + action}))
        sys.exit(1)

    kwargs = {}
    if len(sys.argv) > 2:
        try:
            kwargs = json.loads(sys.argv[2])
        except json.JSONDecodeError:
            pass

    result = COMMANDS[action](**kwargs)
    print(json.dumps(result))


if __name__ == "__main__":
    main()
