基础执行工具
shell_exec:

状态: 受限 (Restricted)

约束: 仅限在 ~/openclaw/sandbox/ 目录下运行。任何涉及 sudo 或修改系统配置的命令必须阻塞并请求审批。

file_manager:

状态: 启用 (Enabled)

约束: 拥有对 /work-dir/ 的读写权限。禁止访问 ~/.ssh/ 或 /etc/ 等敏感路径。

盈利专项技能
tavily_search / search_web:

用途: 用于市场研究、竞品分析及寻找远程工作机会。

browser_control:

用途: 自主登录合法的任务平台（如 Upwork, GitHub）进行操作。

安全: 必须通过受限的浏览器实例运行，禁止保存支付密码。

crypto_wallet_bridge:

用途: 连接用户授权的 Web3 钱包（如 Privy/Base）。

权限: 仅限读取余额和发起预授权的小额转账（< $10）。

辅助技能
summarize: 提取长篇技术文档或法律条款的要点。

security_scanner: 在安装新的 ClawHub 技能前，必须运行此工具进行静态代码扫描。