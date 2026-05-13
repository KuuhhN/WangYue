#!/usr/bin/env python3
"""
check_memory.py - 扫描工作空间中的代码问题

功能:
1. 扫描所有Python文件，检查语法错误
2. 检查未使用的导入
3. 检查常见的编码问题
4. 生成报告

使用:
python check_memory.py [目录路径]
默认扫描当前工作空间目录
"""

import ast
import os
import sys
from pathlib import Path
import traceback

def find_python_files(root_dir):
    """递归查找所有Python文件"""
    python_files = []
    for dirpath, dirnames, filenames in os.walk(root_dir):
        # 跳过一些目录
        if '.git' in dirpath or '__pycache__' in dirpath or '.clawhub' in dirpath:
            continue
        for filename in filenames:
            if filename.endswith('.py'):
                python_files.append(Path(dirpath) / filename)
    return python_files

def check_syntax(filepath):
    """检查Python文件语法"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        ast.parse(content)
        return None  # 无错误
    except SyntaxError as e:
        return f"语法错误: {e.msg} (第{e.lineno}行)"

def check_unused_imports(filepath):
    """检查未使用的导入（基础版本）"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        tree = ast.parse(content)
        
        imports = set()
        used_names = set()
        
        # 收集所有导入的名称
        for node in ast.walk(tree):
            if isinstance(node, ast.Import):
                for alias in node.names:
                    imports.add(alias.name)
            elif isinstance(node, ast.ImportFrom):
                for alias in node.names:
                    full_name = f"{node.module}.{alias.name}" if node.module else alias.name
                    imports.add(full_name)
            
            # 收集使用的名称（变量、函数调用等）
            if isinstance(node, ast.Name):
                used_names.add(node.id)
        
        # 简单检查：如果导入的模块名没有出现在使用中，可能未使用
        # 注意：这是粗略检查，可能误报
        unused = []
        for imp in imports:
            # 提取基础模块名（去除子模块）
            base_name = imp.split('.')[0]
            if base_name not in used_names:
                unused.append(imp)
        
        return unused if unused else None
    except:
        return None  # 解析失败，跳过

def check_common_issues(filepath):
    """检查其他常见问题"""
    issues = []
    
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            lines = f.readlines()
        
        # 检查文件大小
        if len(lines) > 500:
            issues.append("文件过长（超过500行），考虑拆分")
        
        # 检查是否有TODO/FIXME注释
        for i, line in enumerate(lines, 1):
            line_lower = line.lower()
            if 'todo:' in line_lower or 'fixme:' in line_lower:
                issues.append(f"第{i}行: 发现待办注释: {line.strip()[:50]}")
        
        # 检查过长的行
        for i, line in enumerate(lines, 1):
            if len(line.rstrip()) > 120:
                issues.append(f"第{i}行: 行过长（{len(line.rstrip())}字符）")
        
        return issues if issues else None
    except:
        return None

def main():
    if len(sys.argv) > 1:
        root_dir = sys.argv[1]
    else:
        root_dir = os.path.dirname(os.path.abspath(__file__))
    
    print(f"🔍 正在扫描目录: {root_dir}")
    python_files = find_python_files(root_dir)
    
    if not python_files:
        print("未找到Python文件")
        return
    
    print(f"找到 {len(python_files)} 个Python文件")
    
    all_issues = []
    
    for filepath in python_files:
        relative_path = filepath.relative_to(root_dir) if filepath.is_relative_to(root_dir) else filepath
        
        file_issues = []
        
        # 语法检查
        syntax_error = check_syntax(filepath)
        if syntax_error:
            file_issues.append(f"  语法: {syntax_error}")
        
        # 未使用的导入
        unused_imports = check_unused_imports(filepath)
        if unused_imports:
            file_issues.append(f"  未使用导入: {', '.join(unused_imports[:3])}" + 
                              ("..." if len(unused_imports) > 3 else ""))
        
        # 常见问题
        common_issues = check_common_issues(filepath)
        if common_issues:
            for issue in common_issues[:2]:  # 只显示前两个问题
                file_issues.append(f"  问题: {issue}")
        
        if file_issues:
            all_issues.append((relative_path, file_issues))
    
    # 生成报告
    if all_issues:
        print("\n⚠️ 发现问题:")
        for filepath, issues in all_issues:
            print(f"\n{filepath}:")
            for issue in issues:
                print(f"  {issue}")
        
        # 保存报告到文件
        report_file = Path(root_dir) / "code_scan_report.txt"
        with open(report_file, 'w', encoding='utf-8') as f:
            f.write("代码扫描报告\n")
            f.write("=" * 50 + "\n\n")
            for filepath, issues in all_issues:
                f.write(f"{filepath}:\n")
                for issue in issues:
                    f.write(f"  {issue}\n")
                f.write("\n")
        
        print(f"\n📄 详细报告已保存到: {report_file}")
        return len(all_issues)
    else:
        print("\n✅ 未发现明显问题")
        return 0

if __name__ == "__main__":
    try:
        exit_code = main()
        sys.exit(exit_code)
    except Exception as e:
        print(f"❌ 脚本执行出错: {e}")
        traceback.print_exc()
        sys.exit(1)