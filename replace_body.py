#!/usr/bin/env python3
"""
Open .doc, convert to .docx, preserve cover page EXACTLY,
replace body content with 111.txt. FIX: avoid duplicate section headers.
"""
import os, sys
import win32com.client

DESKTOP = os.path.expandvars(r'%USERPROFILE%\Desktop')
DOC_PATH = os.path.join(DESKTOP, '分布式.doc')
TMP_PATH = os.path.join(DESKTOP, '~temp_conv.docx')
OUT_PATH = os.path.join(DESKTOP, '分布式系统原理与应用-软件231-2310770132-刘凯.docx')

# Read body content and strip leading newlines/whitespace
with open(os.path.join(DESKTOP, '111.txt'), 'r', encoding='utf-8') as f:
    body_text = f.read().strip()

for p in [TMP_PATH, OUT_PATH]:
    if os.path.exists(p):
        os.remove(p)

try:
    word = win32com.client.Dispatch('Word.Application')
    word.Visible = False
    word.DisplayAlerts = False
    
    # Step 1: Open .doc and convert to .docx
    doc = word.Documents.Open(DOC_PATH)
    doc.SaveAs2(TMP_PATH, FileFormat=16)
    doc.Close()
    
    # Step 2: Open .docx
    doc = word.Documents.Open(TMP_PATH)
    full_len = doc.Range().End
    full_text = doc.Range().Text
    
    # Find the body content start marker in original document
    # The doc already has "一、项目概况" - use "一、" as the boundary marker
    markers = ['一、', '项目概况', '项目背景']
    marker_found = None
    marker_pos = None
    
    for m in markers:
        fr = doc.Range(0, full_len)
        if fr.Find.Execute(m, Forward=True):
            marker_found = m
            marker_pos = fr.Start
            print(f"Found '{m}' at position {marker_pos}")
            break
    
    if marker_pos is None or marker_pos <= 0:
        print("ERROR: marker not found!")
        doc.Close()
        word.Quit()
        sys.exit(1)
    
    # Delete everything from marker to end (this removes the original "一、项目概况" entirely)
    doc.Range(marker_pos, full_len).Select()
    word.Selection.Delete()
    
    # Insert the clean body text from 111.txt (starts with "一、项目概况")
    word.Selection.TypeText(body_text)
    
    word.Selection.TypeText(body_text)
    
    doc.SaveAs2(OUT_PATH, FileFormat=16)
    doc.Close()
    print(f"SAVED: {OUT_PATH}")

except Exception as e:
    print(f"ERROR: {e}")
    import traceback
    traceback.print_exc()
finally:
    try:
        word.Quit()
    except:
        pass
