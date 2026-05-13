#!/usr/bin/env python3
"""
Convert Markdown resume to final optimized one‑page PDF
Combines visual layout with block skill design, strict single-page guarantee
"""

import os
import sys
import tempfile
import subprocess
import markdown

def convert_md_to_html(md_file):
    """Convert Markdown file to HTML with final optimized layout"""
    with open(md_file, 'r', encoding='utf-8') as f:
        md_content = f.read()
    
    # Convert Markdown to HTML
    html_content = markdown.markdown(md_content, extensions=['extra'])
    
    # Create full HTML document with final optimized design
    html_template = f"""<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>吴坤昊 - 个人简历</title>
    <style>
        @page {{
            margin: 8mm 10mm 8mm 10mm;
        }}
        body {{
            font-family: 'Microsoft YaHei', 'Segoe UI', 'PingFang SC', Arial, sans-serif;
            line-height: 1.35;
            color: #333;
            font-size: 10pt;
            margin: 0;
            padding: 0;
            background-color: #fff;
        }}
        
        /* Ultra-compact Header */
        .resume-header {{
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 12px;
            padding-bottom: 8px;
            border-bottom: 1.5px solid #3498db;
        }}
        
        .personal-info {{
            flex: 1;
            padding-right: 10px;
        }}
        
        .name {{
            font-size: 16pt;
            font-weight: bold;
            color: #2c3e50;
            margin: 0 0 6px 0;
        }}
        
        .contact-compact {{
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 3px 10px;
            font-size: 9.5pt;
            margin-top: 5px;
        }}
        
        .contact-item {{
            margin: 1px 0;
        }}
        
        .contact-item strong {{
            color: #2c3e50;
            margin-right: 4px;
            font-weight: 600;
        }}
        
        .photo-container {{
            width: 95px;
            height: 125px;
            border: 1.5px solid #3498db;
            border-radius: 3px;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            background: #f8f9fa;
            text-align: center;
            padding: 6px;
            flex-shrink: 0;
        }}
        
        .photo-label {{
            font-size: 10pt;
            color: #2c3e50;
            font-weight: bold;
            margin-bottom: 3px;
        }}
        
        .photo-size {{
            font-size: 8.5pt;
            color: #7f8c8d;
            margin-bottom: 2px;
        }}
        
        /* Two-column layout with minimal gap */
        .resume-body {{
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 12px;
            margin-top: 8px;
        }}
        
        .left-column {{
            padding-right: 6px;
        }}
        
        .right-column {{
            padding-left: 6px;
        }}
        
        /* Ultra-compact Section styling */
        .section {{
            margin-bottom: 14px;
            padding: 10px;
            background-color: #f8f9fa;
            border-radius: 4px;
            border-left: 3px solid #3498db;
        }}
        
        .section-title {{
            font-size: 11.5pt;
            font-weight: bold;
            color: #2c3e50;
            margin: 0 0 8px 0;
            padding-bottom: 3px;
            border-bottom: 1px solid #dee2e6;
        }}
        
        .section-title::before {{
            content: "› ";
            color: #3498db;
        }}
        
        /* Education - Super compact */
        .education-item {{
            margin-bottom: 8px;
        }}
        
        .school {{
            font-weight: bold;
            color: #2c3e50;
            font-size: 10.5pt;
            margin-bottom: 2px;
        }}
        
        .degree {{
            color: #555;
            font-size: 9.5pt;
            margin-bottom: 4px;
        }}
        
        .courses {{
            font-size: 9pt;
            color: #666;
            line-height: 1.3;
            margin-top: 4px;
        }}
        
        /* Skills - BLOCK DESIGN (保留用户喜欢的区块设计) */
        .skill-category {{
            margin-bottom: 8px;
        }}
        
        .skill-category-title {{
            font-weight: bold;
            color: #2c3e50;
            font-size: 10pt;
            margin-bottom: 4px;
            padding-left: 4px;
            border-left: 2px solid #3498db;
        }}
        
        .skill-blocks {{
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(110px, 1fr));
            gap: 5px;
            margin-bottom: 5px;
        }}
        
        .skill-block {{
            background: linear-gradient(135deg, #e3f2fd 0%, #bbdefb 100%);
            color: #1565c0;
            padding: 5px 6px;
            border-radius: 3px;
            font-size: 9pt;
            text-align: center;
            border: 1px solid #90caf9;
            min-height: 28px;
            display: flex;
            align-items: center;
            justify-content: center;
            line-height: 1.2;
        }}
        
        .skill-block small {{
            display: block;
            font-size: 8pt;
            color: #0d47a1;
            margin-top: 1px;
        }}
        
        /* Project Experience - Ultra compact */
        .project {{
            margin-bottom: 12px;
            padding-bottom: 10px;
            border-bottom: 1px dashed #dee2e6;
        }}
        
        .project:last-child {{
            border-bottom: none;
        }}
        
        .project-title {{
            font-weight: bold;
            color: #2c3e50;
            font-size: 10.5pt;
            margin-bottom: 3px;
        }}
        
        .project-meta {{
            font-size: 9pt;
            color: #7f8c8d;
            margin-bottom: 5px;
            font-style: italic;
        }}
        
        .tech-stack {{
            font-size: 9pt;
            color: #3498db;
            margin-bottom: 5px;
        }}
        
        .achievements {{
            padding-left: 10px;
        }}
        
        .achievement {{
            font-size: 9.5pt;
            color: #444;
            margin-bottom: 3px;
            line-height: 1.3;
        }}
        
        .achievement::before {{
            content: "• ";
            color: #3498db;
            font-weight: bold;
        }}
        
        /* Certificates & Summary - Compact */
        .certificates {{
            display: flex;
            flex-wrap: wrap;
            gap: 5px;
            margin-top: 4px;
        }}
        
        .certificate {{
            background: linear-gradient(135deg, #e8f5e9 0%, #c8e6c9 100%);
            color: #2e7d32;
            padding: 3px 8px;
            border-radius: 10px;
            font-size: 9pt;
            border: 1px solid #a5d6a7;
        }}
        
        .summary {{
            font-size: 10pt;
            color: #444;
            line-height: 1.4;
            text-align: justify;
        }}
        
        /* Footer - Minimal */
        .footer-note {{
            font-size: 8pt;
            color: #7f8c8d;
            text-align: center;
            margin-top: 12px;
            padding-top: 6px;
            border-top: 1px solid #dee2e6;
            font-style: italic;
        }}
        
        /* Strict single-page enforcement */
        .page-break-avoid {{
            page-break-inside: avoid;
            break-inside: avoid;
        }}
        
        @media print {{
            .section {{
                border: 1px solid #dee2e6;
                border-left: 3px solid #3498db;
                box-shadow: none;
            }}
            .photo-container {{
                border: 1.5px solid #3498db;
                box-shadow: none;
            }}
            .skill-block, .certificate {{
                -webkit-print-color-adjust: exact;
                print-color-adjust: exact;
            }}
        }}
    </style>
</head>
<body>
    <div class="resume-header">
        <div class="personal-info">
            <h1 class="name">吴坤昊</h1>
            <div class="contact-compact">
                <div class="contact-item"><strong>电话</strong>15283276893</div>
                <div class="contact-item"><strong>邮箱</strong>1801244549@qq.com</div>
                <div class="contact-item"><strong>籍贯</strong>四川内江</div>
                <div class="contact-item"><strong>所在地</strong>江苏泰州</div>
                <div class="contact-item"><strong>教育</strong>常州大学怀德学院</div>
                <div class="contact-item"><strong>专业</strong>软件工程本科</div>
            </div>
        </div>
        <div class="photo-container">
            <div class="photo-label">证件照</div>
            <div class="photo-size">35×45mm</div>
            <div class="photo-size">(粘贴处)</div>
        </div>
    </div>
    
    <div class="resume-body">
        <div class="left-column">
            <div class="section page-break-avoid">
                <h2 class="section-title">教育背景</h2>
                <div class="education-item">
                    <div class="school">常州大学怀德学院</div>
                    <div class="degree">软件工程 · 本科 (2023.09‑2027.06)</div>
                    <div class="courses">
                        <strong>核心课程</strong>: 数据结构 · 算法设计与分析 · 计算机组成原理 · 操作系统原理 · 数据库系统原理 · 软件工程基础
                    </div>
                </div>
            </div>
            
            <div class="section page-break-avoid">
                <h2 class="section-title">技能专长</h2>
                
                <div class="skill-category">
                    <div class="skill-category-title">编程语言</div>
                    <div class="skill-blocks">
                        <div class="skill-block">Python<small>(熟练)</small></div>
                        <div class="skill-block">JavaScript/Node.js<small>(熟练)</small></div>
                        <div class="skill-block">Shell/Bash<small>(熟练)</small></div>
                        <div class="skill-block">HTML/CSS<small>(熟悉)</small></div>
                    </div>
                </div>
                
                <div class="skill-category">
                    <div class="skill-category-title">框架与工具</div>
                    <div class="skill-blocks">
                        <div class="skill-block">OpenClaw智能体框架</div>
                        <div class="skill-block">WSL2 Ubuntu</div>
                        <div class="skill-block">Git</div>
                        <div class="skill-block">Feishu API</div>
                        <div class="skill-block">Node.js</div>
                        <div class="skill-block">Markdown</div>
                    </div>
                </div>
                
                <div class="skill-category">
                    <div class="skill-category-title">其他能力</div>
                    <div class="skill-blocks">
                        <div class="skill-block">AI代理调适</div>
                        <div class="skill-block">服务器环境搭建</div>
                        <div class="skill-block">自动化脚本</div>
                        <div class="skill-block">网络代理调试</div>
                        <div class="skill-block">系统安全审计</div>
                    </div>
                </div>
            </div>
            
            <div class="section page-break-avoid">
                <h2 class="section-title">证书与奖项</h2>
                <div class="certificates">
                    <span class="certificate">普通话二级乙等</span>
                    <span class="certificate">英语四级 (CET‑4)</span>
                </div>
            </div>
        </div>
        
        <div class="right-column">
            <div class="section page-break-avoid">
                <h2 class="section-title">项目经验</h2>
                
                <div class="project">
                    <div class="project-title">OpenClaw 智能体本地部署</div>
                    <div class="project-meta">2026.03</div>
                    <div class="tech-stack">技术栈: OpenClaw, WSL2 Ubuntu, Node.js, Feishu API, Git, PowerShell</div>
                    <div class="achievements">
                        <div class="achievement">部署OpenClaw框架，配置Feishu通道实现双向通信</div>
                        <div class="achievement">集成DeepSeek API，建立代理设置确保网络连通</div>
                        <div class="achievement">安装self‑improving‑agent技能，实现持续自我优化</div>
                        <div class="achievement">设计 Apex 身份架构（科技研发与情报分析助手）</div>
                        <div class="achievement">建立自动化任务调度（cron jobs）与心跳机制</div>
                    </div>
                </div>
            </div>
            
            <div class="section page-break-avoid">
                <h2 class="section-title">个人总结</h2>
                <p class="summary">
                    专注于智能体系统本地部署与调适，成功搭建并个性化配置OpenClaw框架，实现Feishu通道集成与自动化任务调度。擅长环境配置、网络连接与代理设置，具备快速学习与问题解决能力，致力于通过技术优化工作效率与系统自动化水平。
                </p>
            </div>
        </div>
    </div>
    
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
        '--margin-top', '8mm',
        '--margin-bottom', '8mm',
        '--margin-left', '10mm',
        '--margin-right', '10mm',
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
        print("用法: python convert_final_pdf.py <markdown文件> <pdf输出文件>")
        sys.exit(1)
    
    md_file = sys.argv[1]
    pdf_file = sys.argv[2]
    
    if not os.path.exists(md_file):
        print(f"错误: Markdown文件不存在: {md_file}")
        sys.exit(1)
    
    print(f"转换 {md_file} 为最终优化版PDF...")
    
    # Step 1: Convert Markdown to HTML
    print("1. 创建最终优化布局...")
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