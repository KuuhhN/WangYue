# 🔄 Self-Improvement Log

记录代理的改进点和学习内容。

---
## [2026-03-26 13:08] initialization
- 自我改进系统初始化完成，开始记录改进点。
## [2026-05-13 12:00] fix
- 修复 self_improving.py 硬编码路径 "/root/.openclaw/workspace" 问题，改用 `Path.home()` 动态获取路径，适配 Windows 环境运行
## [2026-05-17 20:00] operational-policy
- 大修：超大 sessions/*.jsonl 文件导致 Node.js Event Loop 阻塞 148s+，Agent 进入假死状态
- 修复方案：`agents/main/sessions/` 目录可安全废弃并重建，建议每月清理或重命名备份
- 额外发现：火绒安全软件对 .openclaw 目录的实时扫描导致冷启动从 26s 膨胀至 93s，需加入白名单
- 核心教训：sessions 文件是临时缓存，MEMORY.md 和 memory/*.md 才是持久记忆载体
