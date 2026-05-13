#!/usr/bin/env python3
"""
Debug approach - show document structure first
"""
import os

DESKTOP = os.path.expandvars(r'%USERPROFILE%\Desktop')
DOC_PATH = os.path.join(DESKTOP, '分布式.doc')
OUT_PATH = os.path.join(DESKTOP, '分布式系统原理与应用-软件231-2310770132-刘凯.docx')

with open(os.path.join(DESKTOP, '111.txt'), 'r', encoding='utf-8') as f:
    body_text = f.read()

word = win32com.client.Dispatch('Word.Application')
word.Visible = False
word.DisplayAlerts = False

try:
    doc = word.Documents.Open(DOC_PATH)
    
    # Debug: show first 1000 chars of content
    full_range = doc.Range(0, doc.Range().End)
    text = full_range.Text
    print(f"Total length: {len(text)}")
    print("=== TEXT START ===")
    print(text[:800])
    print("=== TEXT END ===")
    
    # Try different approaches to find marker
    find_r = doc.Range()
    found = find_r.Find.Execute('项目概况')
    print(f"\nFind '项目概况': found={found}, Start={find_r.Start if found else 'N/A'}")
    
    if not found:
        find_r2 = doc.Range()
        found2 = find_r2.Find.Execute('��Ŀ�ſ�')  # Original encoding might be GBK
        print(f"Find GBK-encoded: found={found2}, Start={find_r2.Start if found2 else 'N/A'}")
    
    doc.Close()
except Exception as e:
    print(f"ERROR: {e}")
finally:
    word.Quit()
