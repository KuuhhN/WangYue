# 🛠️ OpenClaw 故障排查与性能优化日志 [2026-05-15]

**排障人**: 吴坤昊
**时长**: 整个下午
**系统**: OpenClaw v2026.5.7 | Windows + Clash | Node.js v24

---

## 1. 故障现象

- **网关高延迟**: model-resolution 与 auth 耗时常态化 30s–65s
- **系统假死**: event_loop_delay 最高达 **65162ms**，面板响应极其缓慢
- **启动异常**: startup model warmup timed out + 端口 18789 占用报错

## 2. 根因分析（三重问题叠加）

| # | 问题 | 影响 |
|---|------|------|
| ① | **DNS 阻塞** — 本地默认 DNS 解析 `api.deepseek.com` 耗时高达 **11.4s** | 半瘫痪状态 |
| ② | **代理劫持** — Clash TUN 模式强制接管所有流量，DeepSeek 请求被转发海外节点 | 链路回环与超时 |
| ③ | **环境变量大小写敏感** — Node.js undici 引擎不识别大写 `NO_PROXY`，直连规则失效 | 代理绕路 |

## 3. 解决方案

### 网络层
- ✅ 物理网卡 DNS 改为：**阿里云公共 DNS (223.5.5.5) + 1.1.1.1**
- ✅ 关闭 Clash TUN 模式，仅保留**系统代理**模式

### 配置层 (openclaw.json)
- ✅ `env.vars` 中新增小写变量：`"no_proxy": "localhost,127.0.0.1,.deepseek.com"`
- ✅ 通配符 `.deepseek.com` 确保全系列子域名直连

### 运维层
- ✅ `taskkill /F /IM node.exe` 强杀僵尸进程，释放端口 18789

## 4. 最终效果

| 指标 | 优化前 | 优化后 |
|------|--------|--------|
| DNS 解析 | 11.4s | **16–20ms** |
| model-resolution | 30–65s | **0ms** |
| auth 认证 | 同左 | **6ms** |
| 业务体感 | 卡死/超时 | **秒回** |
| Gemini 搜索 | — | 经 http_proxy 正常分流 |

## 5. 技术价值

> **关键词**: DNS 调优 · Clash 代理分流 · Node.js undici 大小写兼容 · 系统代理 vs TUN 模式 · event_loop_delay 诊断 · 僵尸进程清理

这些是**真实的线上系统排障经验**，涉及网络栈、代理路由、运行时兼容性三层交叉排查——不是玩具项目能遇到的。
