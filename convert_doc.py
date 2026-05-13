#!/usr/bin/env python3
"""
Simple: open .doc, save as .docx, keep first page, add body content.
"""
import os

DESKTOP = os.path.expandvars(r'%USERPROFILE%\Desktop')
DOC_PATH = os.path.join(DESKTOP, '分布式.doc')
TMP_PATH = os.path.join(DESKTOP, '~temp_conv.docx')
OUT_PATH = os.path.join(DESKTOP, '分布式系统原理与应用-软件231-2310770132-刘凯.docx')

with open(os.path.join(DESKTOP, '111.txt'), 'r', encoding='utf-8') as f:
    body_text = f.read()

try:
    word = win32com.client.Dispatch('Word.Application')
    word.Visible = False
    word.DisplayAlerts = False
    
    # Open original .doc
    doc = word.Documents.Open(DOC_PATH)
    print("Opened .doc")
    
    # Convert to .docx first
    doc.SaveAs2(TMP_PATH, FileFormat=16)  # wdFormatXMLDocument
    doc.Close()
    print("Saved as .docx")
    
    # Re-open the .docx
    doc = word.Documents.Open(TMP_PATH)
    print("Re-opened .docx")
    
    # Try finding "项目概况" or "一、项目概况"
    # Using Replace approach: find the pattern and select to end
    print(f"Document range end: {doc.Range().End}")
    
    # Get full text for debugging
    full_text = doc.Range().Text
    print(f"Full text length: {len(full_text)}")
    
    # Find position of "项目概况"
    idx = full_text.find('项目概况')
    if idx == -1:
        idx = full_text.find('项目背景')
    if idx == -1:
        idx = full_text.find('一、')
    
    print(f"Found marker at text index: {idx}")
    
    if idx > 0:
        # We need to find this position in Word's character units
        # Use a binary search approach: find in a smaller range
        # Go to end and move backwards to find the right spot
        
        word.Selection.GoTo(-1, 6, 0)  # wdGoToPage, wdGoToLast
        doc_end = word.Selection.Start
        
        # Now search backwards for the marker
        find_range = doc.Range(0, doc_end)
        found = find_range.Find.Execute('项目概况', Forward=True)
        found2 = find_range.Find.Execute('项目背景', Forward=False)
        
        print(f"Find '项目概况' forward: {found if 'found' in dir() else 'checking'}")
    
    doc.Close()
    print("Done")
    
except Exception as e:
    print(f"ERROR: {e}")
    import traceback
    traceback.print_exc()
finally:
    try:
        word.Quit()
    except:
        pass
