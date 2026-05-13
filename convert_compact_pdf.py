#!/usr/bin/env python3
"""
Convert Markdown resume to compact one‑page PDF using wkhtmltopdf
"""

import os
import sys
import tempfile
import subprocess
import markdown

def convert_md_to_html(md_file):
    """Convert Markdown file to HTML with compact layout"""
    with open(md_file, 'r', encoding='utf-8') as f:
        md_content = f.read()
    
    # Convert Markdown to HTML
    html_content = markdown.markdown(md_content, extensions=['extra'])
    
    # Create full HTML document with compact styling
    html_template = f"""<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>吴坤昊 - 个人简历 (紧凑版)</title>
    <style>
        @page {{
            margin: 10mm 12mm 10mm 12mm;
        }}
        body {{
            font-family: 'Microsoft YaHei', 'Segoe UI', Arial, sans-serif;
            line-height: 1.4;
            color: #222;
            font-size: 11pt;
            margin: 0;
            padding: 0;
            background-color: #fff;
        }}
        h1 {{
            font-size: 18pt;
            color: #2c3e50;
            text-align: center;
            margin: 0 0 8px 0;
            padding-bottom: 4px;
            border-bottom: 1.5px solid #3498db;
        }}
        h2 {{
            font-size: 13pt;
            color: #2c3e50;
            margin: 16px 0 8px 0;
            padding-bottom: 3px;
            border-bottom: 1px solid #3498db;
        }}
        h3 {{
            font-size: 11.5pt;
            color: #2c3e50;
            margin: 12px 0 6px 0;
        }}
        p, li {{
            margin: 4px 0;
        }}
        ul, ol {{
            padding-left: 20px;
            margin: 6px 0;
        }}
        blockquote {{
            margin: 10px 0;
            padding: 8px 12px;
            background-color: #f8f9fa;
            border-left: 3px solid #3498db;
            font-size: 10.5pt;
            color: #555;
        }}
        .photo-container {{
            float: right;
            width: 100px;
            height: 130px;
            margin: 5px 0 15px 15px;
            border: 1.5px dashed #3498db;
            border-radius: 3px;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            background-color: #f8f9fa;
            text-align: center;
            padding: 8px;
            font-size: 10.5pt;
            color: #666;
        }}
        .photo-container span {{
            display: block;
            line-height: 1.2;
        }}
        .compact-section {{
            margin-bottom: 14px;
        }}
        .inline-list {{
            display: inline;
            padding: 0;
        }}
        .inline-list li {{
            display: inline;
            margin-right: 10px;
        }}
        .inline-list li:after {{
            content: " · ";
        }}
        .inline-list li:last-child:after {{
            content: "";
        }}
        .skills-grid {{
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
            gap: 8px;
            margin: 8px 0;
        }}
        .skill-category {{
            margin-bottom: 8px;
        }}
        .footer-note {{
            font-size: 9pt;
            color: #7f8c8d;
            text-align: center;
            margin-top: 20px;
            padding-top: 8px;
            border-top: 1px solid #ecf0f1;
        }}
        .ai-hint {{
            font-style: italic;
            color: #555;
            font-size: 10pt;
            margin: 2px 0;
        }}
        .highlight {{
            background-color: #f1f8ff;
            padding: 2px 4px;
            border-radius: 2px;
        }}
        @media print {{
            .photo-container {{
                border-style: solid;
                border-width: 1px;
            }}
        }}
    </style>
</head>
<body>
    <div class="photo-container">
        <span>照片位置</span>
        <span>35×45mm</span>
        <span>(证件照)</span>
    </div>
    {html_content}
    <div class="footer-note">
        本简历由OpenClaw智能体自主生成 · 形势与政策作业 · 2026年3月25日
    </div>
</body>
</html>"""
    
    # Create temporary HTML file
    with tempfile.NamedTemporaryFile(mode='w', suffix='.html', delete=False, encoding='utf-8') as f:
        f.write(html_template)
        return f.name

def convert_html_to_pdf(html_file, pdf_file):
    """Convert HTML file to PDF using wkhtmltopdf"""
    wkhtmltopdf_path = os.path.join(os.environ['TEMP'], 'wkhtmltox', 'bin', 'wkhtmltopdf.exe')
    
    if not os.path.exists(wkhtmltopdf_path):
        print(f"错误: wkhtmltopdf 未找到: {wkhtmltopdf_path}")
        return False
    
    cmd = [
        wkhtmltopdf_path,
        '--page-size', 'A4',
        '--margin-top', '10mm',
        '--margin-bottom', '10mm',
        '--margin-left', '12mm',
        '--margin-right', '12mm',
        '--encoding', 'UTF-8',
        '--no-stop-slow-scripts',
        '--enable-local-file-access',
        '--disable-smart-shrinking',
        html_file,
        pdf_file
    ]
    
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
        if result.returncode != 0:
            print(f"wkhtmltopdf 错误: {result.stderr}")
            return False
        return True
    except subprocess.TimeoutExpired:
        print("转换超时")
        return False
    except Exception as e:
        print(f"转换异常: {e}")
        return False

def main():
    if len(sys.argv) != 3:
        print("用法: python convert_compact_pdf.py <markdown文件> <pdf输出文件>")
        sys.exit(1)
    
    md_file = sys.argv[1]
    pdf_file = sys.argv[2]
    
    if not os.path.exists(md_file):
        print(f"错误: Markdown文件不存在: {md_file}")
        sys.exit(1)
    
    print(f"转换 {md_file} 为紧凑版PDF...")
    
    # Step 1: Convert Markdown to HTML
    print("1. 将Markdown转换为HTML...")
    html_file = convert_md_to_html(md_file)
    print(f"   临时HTML文件: {html_file}")
    
    # Step 2: Convert HTML to PDF
    print("2. 将HTML转换为PDF...")
    if convert_html_to_pdf(html_file, pdf_file):
        print(f"[OK] PDF生成成功: {pdf_file}")
        
        # Clean up temporary HTML file
        try:
            os.unlink(html_file)
        except:
            pass
    else:
        print("[ERROR] PDF生成失败")
        sys.exit(1)

if __name__ == "__main__":
    main()