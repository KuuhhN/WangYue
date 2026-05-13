#!/usr/bin/env python3
"""
自我改进系统集成脚本
同时配置并运行 xiucheng-self-improving-agent 和 self-improving-agent-cn
"""

import os
import sys
import json
from datetime import datetime
from pathlib import Path

# 添加技能目录到路径
workspace_dir = Path(os.path.expanduser("~/.openclaw/workspace"))
skills_dir = workspace_dir / "skills"
sys.path.insert(0, str(skills_dir / "xiucheng-self-improving-agent"))
sys.path.insert(0, str(skills_dir / "self-improving-agent-cn"))

def setup_directories():
    """设置必要的目录结构"""
    # 创建记忆目录
    memory_dir = Path(os.path.expanduser("~/.openclaw/memory/self-improving"))
    memory_dir.mkdir(parents=True, exist_ok=True)
    
    # 创建日志文件
    improvement_log = workspace_dir / "improvement_log.md"
    if not improvement_log.exists():
        with open(improvement_log, "w", encoding="utf-8") as f:
            f.write("# 🌀 自我改进日志\n\n")
            f.write(f"创建时间: {datetime.now().strftime('%Y-%m-%d %H:%M')}\n")
            f.write(f"集成: xiucheng-self-improving-agent + self-improving-agent-cn\n\n")
            f.write("## 使用说明\n")
            f.write("- 此文件记录对话质量分析和改进建议\n")
            f.write("- 每周自动生成报告\n")
            f.write("- 与错误记录系统互补\n")
    
    # 创建记忆索引
    index_file = memory_dir / "index.json"
    if not index_file.exists():
        with open(index_file, "w", encoding="utf-8") as f:
            json.dump({
                "setup_time": datetime.now().isoformat(),
                "integrated_skills": [
                    "xiucheng-self-improving-agent",
                    "self-improving-agent-cn"
                ],
                "memory_files": {
                    "errors": "errors.jsonl",
                    "corrections": "corrections.jsonl",
                    "best_practices": "best_practices.jsonl",
                    "knowledge_gaps": "knowledge_gaps.jsonl"
                }
            }, f, indent=2, ensure_ascii=False)
    
    print("✅ 目录结构已设置完成")

def import_xiucheng_module():
    """导入 xiucheng 版本的模块"""
    try:
        # 动态导入
        module_path = skills_dir / "xiucheng-self-improving-agent" / "self_improving.py"
        if module_path.exists():
            # 由于是脚本，可能需要直接执行而不是导入
            # 这里创建包装器
            print("✅ xiucheng-self-improving-agent 模块可用")
            return True
        else:
            print("⚠️ xiucheng 模块文件未找到")
            return False
    except Exception as e:
        print(f"⚠️ 导入 xiucheng 模块时出错: {e}")
        return False

def import_cn_scripts():
    """导入 CN 版本的脚本"""
    script_files = ["check_memory.py", "log_error.py", "log_correction.py", "log_best_practice.py"]
    available = []
    
    for script in script_files:
        script_path = skills_dir / "self-improving-agent-cn" / script
        if script_path.exists():
            available.append(script)
    
    if available:
        print(f"✅ self-improving-agent-cn 脚本可用: {', '.join(available)}")
        return True
    else:
        print("⚠️ self-improving-agent-cn 脚本未找到")
        return False

def create_integration_script():
    """创建集成执行脚本"""
    script_content = '''#!/usr/bin/env python3
"""
集成自我改进系统 - 主执行脚本
运行方式: python self_improving_run.py --action [analyze|log_error|weekly_report|check_memory]
"""

import os
import sys
import subprocess
from datetime import datetime

def run_xiucheng_analysis(conversation=None):
    """运行 xiucheng 对话分析"""
    script_path = os.path.join(
        os.path.expanduser("~/.openclaw/workspace/skills/xiucheng-self-improving-agent"),
        "self_improving.py"
    )
    
    if not os.path.exists(script_path):
        print("⚠️ xiucheng 脚本未找到")
        return
    
    try:
        # 执行分析
        cmd = [sys.executable, script_path, "--stats"]
        result = subprocess.run(cmd, capture_output=True, text=True)
        print("📊 xiucheng-self-improving-agent 状态:")
        print(result.stdout)
        if result.stderr:
            print("⚠️ 警告:", result.stderr)
    except Exception as e:
        print(f"❌ 执行 xiucheng 分析时出错: {e}")

def run_cn_check_memory(command):
    """运行 CN 版本记忆检查"""
    script_path = os.path.join(
        os.path.expanduser("~/.openclaw/workspace/skills/self-improving-agent-cn"),
        "check_memory.py"
    )
    
    if not os.path.exists(script_path):
        print("⚠️ check_memory.py 未找到")
        return
    
    try:
        cmd = [sys.executable, script_path, "--command", command]
        result = subprocess.run(cmd, capture_output=True, text=True)
        print("🧠 记忆检查结果:")
        print(result.stdout)
        if result.stderr:
            print("⚠️ 警告:", result.stderr)
    except Exception as e:
        print(f"❌ 执行记忆检查时出错: {e}")

def run_cn_log_error(command, error_msg, fix=None):
    """运行 CN 版本错误记录"""
    script_path = os.path.join(
        os.path.expanduser("~/.openclaw/workspace/skills/self-improving-agent-cn"),
        "log_error.py"
    )
    
    if not os.path.exists(script_path):
        print("⚠️ log_error.py 未找到")
        return
    
    try:
        cmd = [sys.executable, script_path, "--command", command, "--error", error_msg]
        if fix:
            cmd.extend(["--fix", fix])
        result = subprocess.run(cmd, capture_output=True, text=True)
        print("📝 错误记录结果:")
        print(result.stdout)
        if result.stderr:
            print("⚠️ 警告:", result.stderr)
    except Exception as e:
        print(f"❌ 记录错误时出错: {e}")

def generate_weekly_report():
    """生成周报（调用 xiucheng 版本）"""
    script_path = os.path.join(
        os.path.expanduser("~/.openclaw/workspace/skills/xiucheng-self-improving-agent"),
        "self_improving.py"
    )
    
    if not os.path.exists(script_path):
        print("⚠️ self_improving.py 未找到")
        return
    
    try:
        cmd = [sys.executable, script_path, "--report"]
        result = subprocess.run(cmd, capture_output=True, text=True)
        print("📈 周报生成结果:")
        print(result.stdout)
        if result.stderr:
            print("⚠️ 警告:", result.stderr)
    except Exception as e:
        print(f"❌ 生成周报时出错: {e}")

def main():
    import argparse
    parser = argparse.ArgumentParser(description="集成自我改进系统")
    parser.add_argument("--action", choices=["analyze", "log_error", "weekly_report", "check_memory"], 
                       default="analyze", help="执行动作")
    parser.add_argument("--command", help="命令（用于检查记忆或记录错误）")
    parser.add_argument("--error", help="错误信息（用于记录错误）")
    parser.add_argument("--fix", help="修复建议（用于记录错误）")
    
    args = parser.parse_args()
    
    if args.action == "analyze":
        print("🔍 运行对话分析...")
        run_xiucheng_analysis()
    elif args.action == "check_memory" and args.command:
        print("🧠 检查相关记忆...")
        run_cn_check_memory(args.command)
    elif args.action == "log_error" and args.command and args.error:
        print("📝 记录错误...")
        run_cn_log_error(args.command, args.error, args.fix)
    elif args.action == "weekly_report":
        print("📈 生成周报...")
        generate_weekly_report()
    else:
        print("请提供必要的参数")
        parser.print_help()

if __name__ == "__main__":
    main()
'''
    
    script_path = workspace_dir / "self_improving_run.py"
    with open(script_path, "w", encoding="utf-8") as f:
        f.write(script_content)
    
    # 设置执行权限
    if sys.platform != "win32":
        os.chmod(script_path, 0o755)
    
    print(f"✅ 集成执行脚本已创建: {script_path}")

def update_heartbeat_file():
    """更新 HEARTBEAT.md 集成自我改进检查"""
    heartbeat_path = workspace_dir / "HEARTBEAT.md"
    
    if not heartbeat_path.exists():
        print("⚠️ HEARTBEAT.md 未找到，跳过更新")
        return
    
    with open(heartbeat_path, "r", encoding="utf-8") as f:
        content = f.read()
    
    # 添加自我改进检查部分
    improvement_section = '''
## 自我改进系统检查 (每日 12:00 和 20:00)
- **对话质量分析**：检查近期对话质量，识别改进机会
- **错误记忆回顾**：回顾最近记录的错误，避免重复
- **最佳实践强化**：巩固已记录的最佳实践
- **周报生成**：每周日生成改进报告

执行命令：
```bash
python ~/.openclaw/workspace/self_improving_run.py --action analyze
python ~/.openclaw/workspace/self_improving_run.py --action weekly_report  # 仅周日
```

集成配置完成时间：{timestamp}
'''.format(timestamp=datetime.now().strftime("%Y-%m-%d %H:%M"))
    
    if "自我改进系统检查" not in content:
        # 在合适位置添加
        if "周期性任务" in content:
            # 在周期性任务部分后添加
            parts = content.split("周期性任务")
            if len(parts) > 1:
                new_content = parts[0] + "周期性任务" + parts[1] + improvement_section
                with open(heartbeat_path, "w", encoding="utf-8") as f:
                    f.write(new_content)
                print("✅ HEARTBEAT.md 已更新")
            else:
                print("⚠️ HEARTBEAT.md 格式异常，未更新")
        else:
            # 添加到文件末尾
            with open(heartbeat_path, "a", encoding="utf-8") as f:
                f.write("\n" + improvement_section)
            print("✅ HEARTBEAT.md 已更新（添加到末尾）")
    else:
        print("ℹ️ HEARTBEAT.md 中已包含自我改进检查，跳过更新")

def create_cron_jobs():
    """创建定时任务配置"""
    cron_config = '''# 自我改进系统定时任务配置

## 每日分析任务（12:00 和 20:00）
# 对话质量分析
0 12,20 * * * cd ~/.openclaw/workspace && python self_improving_run.py --action analyze

## 周报任务（每周日 09:00）
0 9 * * 0 cd ~/.openclaw/workspace && python self_improving_run.py --action weekly_report

## 记忆清理任务（每月1号 03:00）
# 清理超过90天的记录
0 3 1 * * find ~/.openclaw/memory/self-improving -name "*.jsonl" -mtime +90 -delete

要启用这些任务，执行：
openclaw cron add --schedule '{"kind": "cron", "expr": "0 12,20 * * *", "tz": "Asia/Shanghai"}' --payload '{"kind": "agentTurn", "message": "运行自我改进分析: python ~/.openclaw/workspace/self_improving_run.py --action analyze"}' --sessionTarget isolated
'''
    
    config_path = workspace_dir / "self_improving_cron.txt"
    with open(config_path, "w", encoding="utf-8") as f:
        f.write(cron_config)
    
    print(f"✅ 定时任务配置已创建: {config_path}")

def main():
    print("🔄 开始配置自我改进系统集成...")
    print("=" * 50)
    
    # 1. 设置目录结构
    print("1. 设置目录结构...")
    setup_directories()
    
    # 2. 检查模块可用性
    print("\n2. 检查技能模块可用性...")
    xiucheng_ok = import_xiucheng_module()
    cn_ok = import_cn_scripts()
    
    if not (xiucheng_ok or cn_ok):
        print("❌ 没有可用的技能模块，请检查安装")
        return
    
    # 3. 创建集成脚本
    print("\n3. 创建集成执行脚本...")
    create_integration_script()
    
    # 4. 更新心跳文件
    print("\n4. 更新 HEARTBEAT.md...")
    update_heartbeat_file()
    
    # 5. 创建定时任务配置
    print("\n5. 创建定时任务配置...")
    create_cron_jobs()
    
    print("\n" + "=" * 50)
    print("🎉 自我改进系统集成配置完成！")
    print("\n📋 已配置内容:")
    print("  - 记忆目录: ~/.openclaw/memory/self-improving/")
    print("  - 集成脚本: ~/.openclaw/workspace/self_improving_run.py")
    print("  - 心跳集成: HEARTBEAT.md 已更新")
    print("  - 定时任务: self_improving_cron.txt")
    print("\n🚀 使用方法:")
    print("  # 运行对话分析")
    print("  python self_improving_run.py --action analyze")
    print("\n  # 检查命令相关记忆")
    print("  python self_improving_run.py --action check_memory --command 'npm install'")
    print("\n  # 记录错误")
    print("  python self_improving_run.py --action log_error --command 'npm install' --error 'permission denied'")
    print("\n  # 生成周报")
    print("  python self_improving_run.py --action weekly_report")
    print("\n💡 建议将自我改进检查添加到每日心跳任务中")

if __name__ == "__main__":
    main()
