#!/usr/bin/env python3
"""
Convert Markdown resume to visually optimized one‑page PDF using wkhtmltopdf
"""

import os
import sys
import tempfile
import subprocess
import markdown

def convert_md_to_html(md_file):
    """Convert Markdown file to HTML with visual optimization"""
    with open(md_file, 'r', encoding='utf-8') as f:
        md_content = f.read()
    
    # Convert Markdown to HTML
    html_content = markdown.markdown(md_content, extensions=['extra'])
    
    # Create full HTML document with visual design
    html_template = f"""<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>吴坤昊 - 个人简历</title>
    <style>
        @page {{
            margin: 12mm 15mm 12mm 15mm;
        }}
        body {{
            font-family: 'Microsoft YaHei', 'Segoe UI', 'PingFang SC', Arial, sans-serif;
            line-height: 1.5;
            color: #333;
            font-size: 11pt;
            margin: 0;
            padding: 0;
            background-color: #fff;
        }}
        
        /* Header & Photo */
        .resume-header {{
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 2px solid #3498db;
        }}
        
        .name-title {{
            flex: 1;
        }}
        
        .name {{
            font-size: 24pt;
            font-weight: bold;
            color: #2c3e50;
            margin: 0 0 5px 0;
            letter-spacing: 1px;
        }}
        
        .subtitle {{
            font-size: 12pt;
            color: #7f8c8d;
            margin: 0;
            font-weight: normal;
        }}
        
        .contact-info {{
            margin-top: 10px;
            font-size: 10.5pt;
        }}
        
        .contact-item {{
            display: inline-block;
            margin-right: 15px;
            margin-bottom: 5px;
        }}
        
        .contact-item strong {{
            color: #2c3e50;
        }}
        
        .photo-container {{
            width: 110px;
            height: 140px;
            border: 2px solid #3498db;
            border-radius: 4px;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
            text-align: center;
            padding: 10px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }}
        
        .photo-label {{
            font-size: 11pt;
            color: #2c3e50;
            font-weight: bold;
            margin-bottom: 5px;
        }}
        
        .photo-size {{
            font-size: 9.5pt;
            color: #7f8c8d;
            margin-bottom: 3px;
        }}
        
        /* Two-column layout */
        .resume-body {{
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-top: 15px;
        }}
        
        .left-column {{
            padding-right: 10px;
        }}
        
        .right-column {{
            padding-left: 10px;
        }}
        
        /* Section styling */
        .section {{
            margin-bottom: 20px;
            padding: 15px;
            background-color: #f8f9fa;
            border-radius: 6px;
            border-left: 4px solid #3498db;
            box-shadow: 0 1px 3px rgba(0,0,0,0.05);
        }}
        
        .section-title {{
            font-size: 14pt;
            font-weight: bold;
            color: #2c3e50;
            margin: 0 0 12px 0;
            padding-bottom: 5px;
            border-bottom: 1px solid #dee2e6;
        }}
        
        .section-title::before {{
            content: "▸ ";
            color: #3498db;
        }}
        
        /* Education & Skills */
        .education-item {{
            margin-bottom: 12px;
        }}
        
        .school {{
            font-weight: bold;
            color: #2c3e50;
            font-size: 11.5pt;
            margin-bottom: 3px;
        }}
        
        .degree {{
            color: #555;
            font-size: 10.5pt;
            margin-bottom: 3px;
        }}
        
        .courses {{
            font-size: 10pt;
            color: #666;
            line-height: 1.4;
            margin-top: 5px;
        }}
        
        .skill-category {{
            margin-bottom: 12px;
        }}
        
        .skill-category-title {{
            font-weight: bold;
            color: #2c3e50;
            font-size: 11pt;
            margin-bottom: 6px;
            padding-left: 5px;
            border-left: 2px solid #3498db;
        }}
        
        .skill-items {{
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            margin-bottom: 8px;
        }}
        
        .skill-item {{
            background-color: #e3f2fd;
            color: #1565c0;
            padding: 4px 10px;
            border-radius: 12px;
            font-size: 10pt;
            border: 1px solid #bbdefb;
        }}
        
        /* Project Experience */
        .project {{
            margin-bottom: 18px;
            padding-bottom: 15px;
            border-bottom: 1px dashed #dee2e6;
        }}
        
        .project:last-child {{
            border-bottom: none;
        }}
        
        .project-title {{
            font-weight: bold;
            color: #2c3e50;
            font-size: 12pt;
            margin-bottom: 5px;
        }}
        
        .project-date {{
            font-size: 10pt;
            color: #7f8c8d;
            margin-bottom: 8px;
            font-style: italic;
        }}
        
        .project-desc {{
            font-size: 10.5pt;
            color: #555;
            line-height: 1.5;
            margin-bottom: 8px;
        }}
        
        .tech-stack {{
            font-size: 10pt;
            color: #3498db;
            margin-bottom: 8px;
        }}
        
        .achievements {{
            padding-left: 15px;
        }}
        
        .achievement {{
            font-size: 10.5pt;
            color: #444;
            margin-bottom: 5px;
            line-height: 1.4;
        }}
        
        .achievement::before {{
            content: "• ";
            color: #3498db;
            font-weight: bold;
        }}
        
        /* Certificates & Summary */
        .certificate {{
            display: inline-block;
            background-color: #e8f5e9;
            color: #2e7d32;
            padding: 5px 12px;
            border-radius: 15px;
            font-size: 10pt;
            margin-right: 8px;
            margin-bottom: 8px;
            border: 1px solid #c8e6c9;
        }}
        
        .summary {{
            font-size: 11pt;
            color: #444;
            line-height: 1.6;
            text-align: justify;
        }}
        
        /* Footer */
        .footer-note {{
            font-size: 9pt;
            color: #7f8c8d;
            text-align: center;
            margin-top: 25px;
            padding-top: 10px;
            border-top: 1px solid #dee2e6;
            font-style: italic;
        }}
        
        @media print {{
            .section {{
                box-shadow: none;
                border: 1px solid #dee2e6;
                border-left: 4px solid #3498db;
            }}
            .photo-container {{
                box-shadow: none;
                border: 2px solid #3498db;
            }}
        }}
    </style>
</head>
<body>
    <div class="resume-header">
        <div class="name-title">
            <h1 class="name">吴坤昊</h1>
            <p class="subtitle">软件工程 · 本科</p>
            <div class="contact-info">
                <div class="contact-item"><strong>电话</strong> 15283276893</div>
                <div class="contact-item"><strong>邮箱</strong> 1801244549@qq.com</div>
                <div class="contact-item"><strong>籍贯</strong> 四川内江</div>
                <div class="contact-item"><strong>所在地</strong> 江苏泰州</div>
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
            <div class="section">
                <h2 class="section-title">教育背景</h2>
                <div class="education-item">
                    <div class="school">常州大学怀德学院</div>
                    <div class="degree">软件工程 · 本科 (2023.09‑2027.06)</div>
                    <div class="courses">
                        <strong>核心课程</strong>: 数据结构 · 算法设计与分析 · 计算机组成原理 · 操作系统原理 · 数据库系统原理 · 软件工程基础
                    </div>
                </div>
            </div>
            
            <div class="section">
                <h2 class="section-title">技能专长</h2>
                
                <div class="skill-category">
                    <div class="skill-category-title">编程语言</div>
                    <div class="skill-items">
                        <span class="skill-item">Python (熟练)</span>
                        <span class="skill-item">JavaScript/Node.js (熟练)</span>
                        <span class="skill-item">Shell/Bash (熟练)</span>
                        <span class="skill-item">HTML/CSS (熟悉)</span>
                    </div>
                </div>
                
                <div class="skill-category">
                    <div class="skill-category-title">框架与工具</div>
                    <div class="skill-items">
                        <span class="skill-item">OpenClaw智能体框架</span>
                        <span class="skill-item">WSL2 Ubuntu</span>
                        <span class="skill-item">Git</span>
                        <span class="skill-item">Feishu API</span>
                        <span class="skill-item">Node.js</span>
                        <span class="skill-item">Markdown</span>
                    </div>
                </div>
                
                <div class="skill-category">
                    <div class="skill-category-title">其他能力</div>
                    <div class="skill-items">
                        <span class="skill-item">AI代理调适</span>
                        <span class="skill-item">服务器环境搭建</span>
                        <span class="skill-item">自动化脚本</span>
                        <span class="skill-item">网络代理调试</span>
                        <span class="skill-item">系统安全审计</span>
                    </div>
                </div>
            </div>
            
            <div class="section">
                <h2 class="section-title">证书与奖项</h2>
                <span class="certificate">普通话二级乙等</span>
                <span class="certificate">英语四级 (CET‑4)</span>
            </div>
        </div>
        
        <div class="right-column">
            <div class="section">
                <h2 class="section-title">项目经验</h2>
                
                <div class="project">
                    <div class="project-title">OpenClaw 智能体本地部署</div>
                    <div class="project-date">2026.03</div>
                    <div class="tech-stack">技术栈: OpenClaw, WSL2 Ubuntu, Node.js, Feishu API, Git, PowerShell</div>
                    <div class="project-desc">
                        在Windows系统上部署OpenClaw智能体框架，配置Feishu通道实现双向通信，集成自动化任务调度与心跳机制。
                    </div>
                    <div class="achievements">
                        <div class="achievement">部署OpenClaw框架，配置Feishu通道实现双向通信</div>
                        <div class="achievement">集成DeepSeek API，建立代理设置确保网络连通</div>
                        <div class="achievement">安装self‑improving‑agent技能，实现持续自我优化</div>
                        <div class="achievement">设计三位一体身份架构（Tech & Academic Butler | Hardcore Strength Coach | Ruthless DND DM）</div>
                        <div class="achievement">建立自动化任务调度（cron jobs）与心跳机制，实现完整技能扩展与记忆管理系统</div>
                    </div>
                </div>
            </div>
            
            <div class="section">
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
        '--margin-top', '12mm',
        '--margin-bottom', '12mm',
        '--margin-left', '15mm',
        '--margin-right', '15mm',
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
        print("用法: python convert_visual_pdf.py <markdown文件> <pdf输出文件>")
        sys.exit(1)
    
    md_file = sys.argv[1]
    pdf_file = sys.argv[2]
    
    if not os.path.exists(md_file):
        print(f"错误: Markdown文件不存在: {md_file}")
        sys.exit(1)
    
    print(f"转换 {md_file} 为视觉优化版PDF...")
    
    # Step 1: Convert Markdown to HTML
    print("1. 创建视觉优化布局...")
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