#!/usr/bin/env python3
"""Debug the boundary between cover and body content"""
import os

DESKTOP = os.path.expandvars(r'%USERPROFILE%\Desktop')
DOC_PATH = os.path.join(DESKTOP, '分布式.doc')

word = win32com.client.Dispatch('Word.Application')
word.Visible = False
word.DisplayAlerts = False

doc = word.Documents.Open(DOC_PATH)
full_text = doc.Range().Text
print(f"Total length: {len(full_text)}")
print(f"Full text (first 500 chars):")
print(repr(full_text[:500]))
print()

# Find "项目概况" 
print("Searching for markers...")
for m in ['项目概况', '一、项目概况', '项目背景']:
    fr = doc.Range(0, doc.Range().End)
    found = fr.Find.Execute(m, Forward=True)
    if found:
        print(f"'{m}' found at position {fr.Start}")
        # Show context: 20 chars before and 20 chars after
        ctx_start = max(0, fr.Start - 20)
        ctx_end = min(len(full_text), fr.End + 40)
        ctx = doc.Range(ctx_start, ctx_end).Text
        print(f"  Context: [{repr(ctx)}]")
    else:
        print(f"'{m}' NOT found")

# Also search for "一、" separately
fr = doc.Range(0, doc.Range().End)
found = fr.Find.Execute('一、', Forward=True)
if found:
    print(f"\n'一、' found at position {fr.Start}")
    ctx = doc.Range(max(0, fr.Start - 5), min(len(full_text), fr.End + 20)).Text
    print(f"  Context: [{repr(ctx)}]")

doc.Close()
word.Quit()
