#!/usr/bin/env python3
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
        print("Warning: xiucheng script not found")
        return
    
    try:
        # 执行分析
        cmd = [sys.executable, script_path, "--stats"]
        result = subprocess.run(cmd, capture_output=True, text=True)
        print("xiucheng-self-improving-agent status:")
        print(result.stdout)
        if result.stderr:
            print("Warning:", result.stderr)
    except Exception as e:
        print(f"Error running xiucheng analysis: {e}")

def run_cn_check_memory(command):
    """运行 CN 版本记忆检查"""
    script_path = os.path.join(
        os.path.expanduser("~/.openclaw/workspace/skills/self-improving-agent-cn"),
        "check_memory.py"
    )
    
    if not os.path.exists(script_path):
        print("Warning: check_memory.py not found")
        return
    
    try:
        cmd = [sys.executable, script_path, "--command", command]
        result = subprocess.run(cmd, capture_output=True, text=True)
        print("Memory check result:")
        print(result.stdout)
        if result.stderr:
            print("Warning:", result.stderr)
    except Exception as e:
        print(f"Error checking memory: {e}")

def run_cn_log_error(command, error_msg, fix=None):
    """运行 CN 版本错误记录"""
    script_path = os.path.join(
        os.path.expanduser("~/.openclaw/workspace/skills/self-improving-agent-cn"),
        "log_error.py"
    )
    
    if not os.path.exists(script_path):
        print("Warning: log_error.py not found")
        return
    
    try:
        cmd = [sys.executable, script_path, "--command", command, "--error", error_msg]
        if fix:
            cmd.extend(["--fix", fix])
        result = subprocess.run(cmd, capture_output=True, text=True)
        print("Error log result:")
        print(result.stdout)
        if result.stderr:
            print("Warning:", result.stderr)
    except Exception as e:
        print(f"Error logging error: {e}")

def generate_weekly_report():
    """生成周报（调用 xiucheng 版本）"""
    script_path = os.path.join(
        os.path.expanduser("~/.openclaw/workspace/skills/xiucheng-self-improving-agent"),
        "self_improving.py"
    )
    
    if not os.path.exists(script_path):
        print("Warning: self_improving.py not found")
        return
    
    try:
        cmd = [sys.executable, script_path, "--report"]
        result = subprocess.run(cmd, capture_output=True, text=True)
        print("Weekly report:")
        print(result.stdout)
        if result.stderr:
            print("Warning:", result.stderr)
    except Exception as e:
        print(f"Error generating weekly report: {e}")

def main():
    import argparse
    parser = argparse.ArgumentParser(description="Integrated Self-Improving System")
    parser.add_argument("--action", choices=["analyze", "log_error", "weekly_report", "check_memory"], 
                       default="analyze", help="Action to perform")
    parser.add_argument("--command", help="Command (for memory check or error logging)")
    parser.add_argument("--error", help="Error message (for error logging)")
    parser.add_argument("--fix", help="Fix suggestion (for error logging)")
    
    args = parser.parse_args()
    
    if args.action == "analyze":
        print("Running conversation analysis...")
        run_xiucheng_analysis()
    elif args.action == "check_memory" and args.command:
        print("Checking related memories...")
        run_cn_check_memory(args.command)
    elif args.action == "log_error" and args.command and args.error:
        print("Logging error...")
        run_cn_log_error(args.command, args.error, args.fix)
    elif args.action == "weekly_report":
        print("Generating weekly report...")
        generate_weekly_report()
    else:
        print("Please provide necessary parameters")
        parser.print_help()

if __name__ == "__main__":
    main()
