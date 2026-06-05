#!/usr/bin/env python3
"""
vault_tool.py — ThirdSpace vault 读写工具
用法: python vault_tool.py <command> [args]
"""
import os, sys, argparse, glob, re
from datetime import datetime
from pathlib import Path

VAULT_ROOT = r"D:\KUHN\thirdspace-vault"
CWD = ["日","一","二","三","四","五","六"]

def rp(p):
    return Path(p) if Path(p).is_absolute() else Path(VAULT_ROOT) / p

def cmd_search(args):
    kw = args.keyword.lower(); base = Path(VAULT_ROOT)
    if args.workspace: base = base / args.workspace
    hits = []
    for f in base.rglob("*.md"):
        if f.name == ".gitkeep": continue
        if kw in f.stem.lower():
            hits.append(("name", f, "")); continue
        try:
            text = f.read_text("utf-8", errors="ignore")
            for i, ln in enumerate(text.split("\n")):
                if kw in ln.lower():
                    hits.append(("line", f, f"L{i+1}: {ln.strip()[:120]}")); break
        except: pass
    if not hits: print("未找到匹配"); return
    print(f"找到 {len(hits)} 个:\n")
    seen = set()
    for _, p, ctx in hits:
        if p in seen: continue
        seen.add(p)
        print(f"  {p.relative_to(VAULT_ROOT)}")
        if ctx: print(f"    -> {ctx[:100]}")

def cmd_read(args):
    p = rp(args.path)
    if not p.exists(): print(f"ERR: {p} 不存在"); return
    if p.is_dir():
        for f in sorted(p.iterdir()):
            if f.name.startswith("."): continue
            t = f.stat().st_mtime
            s = f.stat().st_size / 1024 if f.is_file() else 0
            tag = "D" if f.is_dir() else "F"
            print(f"  [{tag}] {f.name:30s} {s:6.1f}KB" if f.is_file() else f"  [{tag}] {f.name}/")
        return
    print(p.read_text("utf-8", errors="ignore"))

def cmd_write(args):
    p = rp(args.path)
    if args.stdin:
        content = sys.stdin.read()
    else: content = sys.stdin.read()
    if not content.startswith("---"):
        ws = ""
        parts = str(p.relative_to(VAULT_ROOT)).split(os.sep)
        if len(parts) > 1: ws = parts[0]
        now = datetime.now().strftime("%Y-%m-%dT%H:%M:%S+08:00")
        fm = f"---\ncreated: {now}\nmodified: {now}\nworkspace: {ws}\ntype: {args.type}\ntopic: {args.topic or ''}\n---\n\n"
        content = fm + content
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(content, "utf-8")
    print(f"OK: 已写入 {p.relative_to(VAULT_ROOT)}")

def cmd_list(args):
    base = Path(VAULT_ROOT)
    if args.workspace: base = base / args.workspace
    if not base.exists(): print(f"ERR: {base} 不存在"); return
    total = 0
    for f in sorted(base.iterdir()):
        if f.name.startswith("."): continue
        if f.is_file() and f.suffix == ".md":
            kb = f.stat().st_size / 1024; total += 1
            print(f"  [F] {f.name:30s} {kb:5.1f}KB")
        elif f.is_dir():
            cnt = len(list(f.rglob("*.md"))); total += cnt
            print(f"  [D] {f.name:30s} {cnt:3d} files")
    if not total: print("  (空)")
    else: print(f"\n总计 {total} 个文件")

def cmd_today(args):
    now = datetime.now()
    d = now.strftime("%Y%m%d"); w = CWD[now.weekday()]
    p = Path(VAULT_ROOT) / f"02-日记/工作日志/{d}_工作日志_周{w}.md"
    if p.exists(): print(p.read_text("utf-8")); return
    now_s = now.strftime("%Y-%m-%dT%H:%M:%S+08:00")
    fm = f"---\ncreated: {now_s}\nmodified: {now_s}\nworkspace: 02-日记\ntype: worklog\ntopic: daily\n---\n\n## \u4eca\u65e5\u91cd\u70b9\n- \n\n## \u4eca\u65e5Todo\n- [ ] \n\n## \u91cd\u70b9\u8bb0\u5f55\n### {now.strftime('%H:%M')} \u2014\n"
    p.parent.mkdir(parents=True, exist_ok=True); p.write_text(fm, "utf-8")
    print(f"OK: \u5df2\u521b\u5efa {p.relative_to(VAULT_ROOT)}")

if __name__ == "__main__":
    ap = argparse.ArgumentParser(prog="vault")
    sp = ap.add_subparsers(dest="c")
    for name, kw, ws_opt in [
        ("search", "keyword", True),
        ("list", None, True),
        ("today-worklog", None, False),
    ]:
        p = sp.add_parser(name)
        if kw: p.add_argument(kw)
        if ws_opt: p.add_argument("workspace", nargs="?")
    pr = sp.add_parser("read"); pr.add_argument("path")
    pw = sp.add_parser("write"); pw.add_argument("path")
    pw.add_argument("--type", default="note"); pw.add_argument("--topic", default="")
    pw.add_argument("--stdin", action="store_true")
    a = ap.parse_args()
    if not a.c: ap.print_help(); sys.exit(1)
    {
        "search": cmd_search, "read": cmd_read, "write": cmd_write,
        "list": cmd_list, "today-worklog": cmd_today,
    }[a.c](a)
