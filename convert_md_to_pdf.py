#!/usr/bin/env python3
"""
Convert Markdown resume to PDF using wkhtmltopdf
"""

import os
import sys
import tempfile
import subprocess
import markdown

def convert_md_to_html(md_file):
    """Convert Markdown file to HTML"""
    with open(md_file, 'r', encoding='utf-8') as f:
        md_content = f.read()
    
    # Convert Markdown to HTML
    html_content = markdown.markdown(md_content, extensions=['extra'])
    
    # Create full HTML document
    html_template = f"""<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>个人简历</title>
    <style>
        body {{
            font-family: 'Microsoft YaHei', 'Segoe UI', Arial, sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 210mm;
            margin: 0 auto;
            padding: 20px;
            background-color: #fff;
        }}
        h1, h2, h3 {{
            color: #2c3e50;
            border-bottom: 2px solid #3498db;
            padding-bottom: 5px;
        }}
        h1 {{
            text-align: center;
            margin-top: 0;
        }}
        .section {{
            margin-bottom: 25px;
        }}
        ul {{
            padding-left: 20px;
        }}
        li {{
            margin-bottom: 8px;
        }}
        .contact-info {{
            text-align: center;
            margin-bottom: 30px;
        }}
        .contact-info p {{
            margin: 5px 0;
        }}
        .project-item {{
            margin-bottom: 20px;
            padding-left: 15px;
            border-left: 3px solid #3498db;
        }}
        .skills-list {{
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 10px;
        }}
        .skill-category {{
            margin-bottom: 15px;
        }}
        .footer {{
            text-align: center;
            margin-top: 40px;
            font-size: 12px;
            color: #7f8c8d;
            border-top: 1px solid #ecf0f1;
            padding-top: 10px;
        }}
        .photo-container {{
            float: right;
            width: 120px;
            height: 160px;
            margin: 10px 0 20px 20px;
            border: 2px dashed #3498db;
            border-radius: 4px;
            display: flex;
            align-items: center;
            justify-content: center;
            background-color: #f8f9fa;
            text-align: center;
            padding: 10px;
            font-size: 14px;
            color: #7f8c8d;
        }}
        .photo-container span {{
            display: block;
        }}
        .personal-info-container {{
            overflow: hidden;
            position: relative;
        }}
        @media print {{
            body {{
                padding: 0;
            }}
            .no-print {{
                display: none;
            }}
        }}
    </style>
</head>
<body>
    <div class="photo-container">
        <span>照片位置</span>
        <span>35mm × 45mm</span>
        <span>(证件照)</span>
    </div>
    {html_content}
    <div class="footer">
        最后更新: 2026年3月25日 | 使用 wkhtmltopdf 生成
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
        '--margin-top', '15mm',
        '--margin-bottom', '15mm',
        '--margin-left', '15mm',
        '--margin-right', '15mm',
        '--encoding', 'UTF-8',
        '--no-stop-slow-scripts',
        '--enable-local-file-access',
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
        print("用法: python convert_md_to_pdf.py <markdown文件> <pdf输出文件>")
        sys.exit(1)
    
    md_file = sys.argv[1]
    pdf_file = sys.argv[2]
    
    if not os.path.exists(md_file):
        print(f"错误: Markdown文件不存在: {md_file}")
        sys.exit(1)
    
    print(f"转换 {md_file} 为 PDF...")
    
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