#!/usr/bin/env python3
"""
Convert Markdown resume to PDF based on image reference design
Ultra-compact single page with optimized skill blocks
"""

import os
import sys
import tempfile
import subprocess
import markdown

def convert_md_to_html(md_file):
    """Convert Markdown file to HTML with image-based design"""
    with open(md_file, 'r', encoding='utf-8') as f:
        md_content = f.read()
    
    # Convert Markdown to HTML
    html_content = markdown.markdown(md_content, extensions=['extra'])
    
    # Create full HTML document with image-based design
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
            line-height: 1.38;
            color: #333;
            font-size: 10pt;
            margin: 0;
            padding: 0;
            background-color: #fff;
        }}
        
        /* Compact Header */
        .resume-header {{
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 14px;
            padding-bottom: 10px;
            border-bottom: 2px solid #2c3e50;
        }}
        
        .personal-info {{
            flex: 1;
        }}
        
        .name {{
            font-size: 18pt;
            font-weight: bold;
            color: #2c3e50;
            margin: 0 0 8px 0;
        }}
        
        .contact-compact {{
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 4px 12px;
            font-size: 9.8pt;
            margin-top: 6px;
        }}
        
        .contact-item {{
            margin: 2px 0;
        }}
        
        .contact-item strong {{
            color: #2c3e50;
            margin-right: 5px;
            font-weight: 600;
        }}
        
        .photo-container {{
            width: 100px;
            height: 130px;
            border: 2px solid #2c3e50;
            border-radius: 4px;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            background: #f8f9fa;
            text-align: center;
            padding: 8px;
            flex-shrink: 0;
        }}
        
        .photo-label {{
            font-size: 10.5pt;
            color: #2c3e50;
            font-weight: bold;
            margin-bottom: 4px;
        }}
        
        .photo-size {{
            font-size: 9pt;
            color: #7f8c8d;
            margin-bottom: 2px;
        }}
        
        /* Two-column layout */
        .resume-body {{
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 14px;
            margin-top: 10px;
        }}
        
        .left-column {{
            padding-right: 7px;
        }}
        
        .right-column {{
            padding-left: 7px;
        }}
        
        /* Section styling */
        .section {{
            margin-bottom: 15px;
            padding: 12px;
            background-color: #ffffff;
            border-radius: 5px;
            border: 1px solid #e9ecef;
            box-shadow: 0 1px 3px rgba(0,0,0,0.05);
        }}
        
        .section-title {{
            font-size: 12pt;
            font-weight: bold;
            color: #2c3e50;
            margin: 0 0 12px 0;
            padding-bottom: 5px;
            border-bottom: 2px solid #3498db;
            position: relative;
        }}
        
        .section-title::before {{
            content: "";
            position: absolute;
            left: 0;
            bottom: -2px;
            width: 40px;
            height: 2px;
            background-color: #e74c3c;
        }}
        
        /* Education */
        .education-item {{
            margin-bottom: 10px;
        }}
        
        .school {{
            font-weight: bold;
            color: #2c3e50;
            font-size: 10.8pt;
            margin-bottom: 4px;
        }}
        
        .degree {{
            color: #555;
            font-size: 10pt;
            margin-bottom: 6px;
        }}
        
        .courses {{
            font-size: 9.5pt;
            color: #666;
            line-height: 1.4;
            margin-top: 6px;
            padding-left: 10px;
            border-left: 2px solid #ecf0f1;
        }}
        
        /* SKILLS SECTION - Based on image reference */
        .skill-category {{
            margin-bottom: 12px;
        }}
        
        .skill-category-title {{
            font-weight: bold;
            color: #2c3e50;
            font-size: 10.5pt;
            margin-bottom: 8px;
            padding-left: 5px;
            position: relative;
        }}
        
        .skill-category-title::before {{
            content: "▸";
            position: absolute;
            left: -5px;
            color: #3498db;
        }}
        
        /* Skill Blocks - Image-based design */
        .skill-blocks-container {{
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(140px, 1fr));
            gap: 8px;
            margin-bottom: 8px;
        }}
        
        .skill-block {{
            background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
            border: 1px solid #dee2e6;
            border-radius: 6px;
            padding: 8px 10px;
            display: flex;
            flex-direction: column;
            align-items: center;
            text-align: center;
            transition: all 0.2s ease;
            min-height: 45px;
            justify-content: center;
        }}
        
        .skill-block:hover {{
            transform: translateY(-1px);
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }}
        
        .skill-name {{
            font-weight: 600;
            color: #2c3e50;
            font-size: 10pt;
            margin-bottom: 3px;
        }}
        
        .skill-level {{
            font-size: 8.5pt;
            color: #7f8c8d;
            margin-top: 2px;
        }}
        
        /* Category-specific colors */
        .skill-block.programming {{
            border-left: 3px solid #3498db;
            background: linear-gradient(135deg, #e3f2fd 0%, #f0f7ff 100%);
        }}
        
        .skill-block.framework {{
            border-left: 3px solid #2ecc71;
            background: linear-gradient(135deg, #e8f5e9 0%, #f0fdf0 100%);
        }}
        
        .skill-block.other {{
            border-left: 3px solid #9b59b6;
            background: linear-gradient(135deg, #f3e5f5 0%, #f9f0ff 100%);
        }}
        
        /* Project Experience */
        .project {{
            margin-bottom: 14px;
            padding-bottom: 12px;
            border-bottom: 1px solid #ecf0f1;
        }}
        
        .project:last-child {{
            border-bottom: none;
        }}
        
        .project-title {{
            font-weight: bold;
            color: #2c3e50;
            font-size: 11pt;
            margin-bottom: 5px;
        }}
        
        .project-meta {{
            font-size: 9.5pt;
            color: #7f8c8d;
            margin-bottom: 7px;
            font-style: italic;
        }}
        
        .tech-stack {{
            font-size: 9.5pt;
            color: #3498db;
            margin-bottom: 8px;
            padding: 4px 8px;
            background-color: #f8f9fa;
            border-radius: 4px;
            display: inline-block;
        }}
        
        .achievements {{
            padding-left: 12px;
        }}
        
        .achievement {{
            font-size: 10pt;
            color: #444;
            margin-bottom: 5px;
            line-height: 1.4;
            position: relative;
            padding-left: 8px;
        }}
        
        .achievement::before {{
            content: "•";
            position: absolute;
            left: 0;
            color: #3498db;
            font-weight: bold;
        }}
        
        /* Certificates */
        .certificates {{
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            margin-top: 8px;
        }}
        
        .certificate {{
            background: linear-gradient(135deg, #fff3e0 0%, #ffecb3 100%);
            color: #f57c00;
            padding: 5px 12px;
            border-radius: 15px;
            font-size: 9.5pt;
            border: 1px solid #ffcc80;
            font-weight: 500;
        }}
        
        /* Summary */
        .summary {{
            font-size: 10.2pt;
            color: #444;
            line-height: 1.5;
            text-align: justify;
            padding: 8px;
            background-color: #f8f9fa;
            border-radius: 4px;
            border-left: 3px solid #2c3e50;
        }}
        
        /* Footer */
        .footer-note {{
            font-size: 8.5pt;
            color: #7f8c8d;
            text-align: center;
            margin-top: 15px;
            padding-top: 8px;
            border-top: 1px solid #dee2e6;
            font-style: italic;
        }}
        
        /* Single-page enforcement */
        .page-break-avoid {{
            page-break-inside: avoid;
            break-inside: avoid;
        }}
        
        @media print {{
            .section {{
                box-shadow: none;
                border: 1px solid #e9ecef;
            }}
            .photo-container {{
                box-shadow: none;
            }}
            .skill-block:hover {{
                transform: none;
                box-shadow: none;
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
                        数据结构 · 算法设计与分析 · 计算机组成原理 · 操作系统原理 · 数据库系统原理 · 软件工程基础
                    </div>
                </div>
            </div>
            
            <div class="section page-break-avoid">
                <h2 class="section-title">技能专长</h2>
                
                <div class="skill-category">
                    <div class="skill-category-title">编程语言</div>
                    <div class="skill-blocks-container">
                        <div class="skill-block programming">
                            <div class="skill-name">Python</div>
                            <div class="skill-level">熟练</div>
                        </div>
                        <div class="skill-block programming">
                            <div class="skill-name">JavaScript/Node.js</div>
                            <div class="skill-level">熟练</div>
                        </div>
                        <div class="skill-block programming">
                            <div class="skill-name">Shell/Bash</div>
                            <div class="skill-level">熟练</div>
                        </div>
                        <div class="skill-block programming">
                            <div class="skill-name">HTML/CSS</div>
                            <div class="skill-level">熟悉</div>
                        </div>
                    </div>
                </div>
                
                <div class="skill-category">
                    <div class="skill-category-title">框架与工具</div>
                    <div class="skill-blocks-container">
                        <div class="skill-block framework">
                            <div class="skill-name">OpenClaw智能体框架</div>
                        </div>
                        <div class="skill-block framework">
                            <div class="skill-name">WSL2 Ubuntu</div>
                        </div>
                        <div class="skill-block framework">
                            <div class="skill-name">Git</div>
                        </div>
                        <div class="skill-block framework">
                            <div class="skill-name">Feishu API</div>
                        </div>
                        <div class="skill-block framework">
                            <div class="skill-name">Node.js</div>
                        </div>
                        <div class="skill-block framework">
                            <div class="skill-name">Markdown</div>
                        </div>
                    </div>
                </div>
                
                <div class="skill-category">
                    <div class="skill-category-title">其他能力</div>
                    <div class="skill-blocks-container">
                        <div class="skill-block other">
                            <div class="skill-name">AI代理调适</div>
                        </div>
                        <div class="skill-block other">
                            <div class="skill-name">服务器环境搭建</div>
                        </div>
                        <div class="skill-block other">
                            <div class="skill-name">自动化脚本</div>
                        </div>
                        <div class="skill-block other">
                            <div class="skill-name">网络代理调试</div>
                        </div>
                        <div class="skill-block other">
                            <div class="skill-name">系统安全审计</div>
                        </div>
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
                        <div class="achievement">设计三位一体身份架构（Tech & Academic Butler | Hardcore Strength Coach | Ruthless DND DM）</div>
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
        print("用法: python convert_from_image_pdf.py <markdown文件> <pdf输出文件>")
        sys.exit(1)
    
    md_file = sys.argv[1]
    pdf_file = sys.argv[2]
    
    if not os.path.exists(md_file):
        print(f"错误: Markdown文件不存在: {md_file}")
        sys.exit(1)
    
    print(f"转换 {md_file} 为图片参考版PDF...")
    
    # Step 1: Convert Markdown to HTML
    print("1. 创建图片参考布局...")
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