# 望月 — OpenClaw AI Agent 本地部署实战

> **在 Windows 上从零部署 OpenClaw AI 智能体，踩过的坑和修好的 bug 全记录。**

## 技术栈

OpenClaw v2026.5.7 · DeepSeek V4 Flash · Gemini API · Node.js v24 · Windows 11 · 飞书 / WebChat

## 核心排障案例

### 1. 三层网络优化（`65 秒 → 6 毫秒`）

| 层级 | 问题 | 修复 | 效果 |
|------|------|------|------|
| DNS | 默认解析耗时 11.4 秒 | 改用阿里云 (223.5.5.5) + Cloudflare (1.1.1.1) | **11.4s → 16ms** |
| 代理 | Clash TUN 模式将 DeepSeek 流量绕道海外 | 改用系统代理模式 | 消除路由绕行 |
| 运行时 | Node.js undici 忽略大写 `NO_PROXY` | 改为小写 `no_proxy` | 静默超时 60s 解决 |

### 2. Gateway 启动崩溃三层排查

- **网络层**：WebSocket 握手失败 — `tauri.localhost` 不在 allowedOrigins 白名单
- **系统层**：火绒杀毒实时扫描导致启动 I/O 阻塞 **93 秒** → 加入信任区后 **26 秒**
- **算力层**：Session 轨迹文件损坏导致 Event Loop 卡死 **148 秒** → 隔离 sessions 目录，零数据丢失重建

### 3. 模型架构迁移

从双模型路由（V4 Flash 日常 + R1 深度思考）合并为单模型架构。发现 V4 Flash 原生支持 thinking 模式后主动迁移，赶在 R1 废弃期限（2026-07-24）之前完成。

### 4. 自动化运维

部署了 5 个定时任务：AI 新闻日报、Git 自动备份、系统健康检查、记忆蒸馏、Session 缓存清理。

## 架构图

```
用户（飞书 / WebChat）→ OpenClaw Gateway → Agent 核心
  ├── DeepSeek V4 Flash（思维链模式，直连）
  ├── Gemini API（网络搜索，走系统代理）
  ├── 技能模块：自我改进 / 对话总结 / 代码扫描
  └── Git 自动备份
```

## 排障方法总结

1. **确认模型能力再设计架构** — V4 Flash 原生支持思维链，不需要额外 R1 层
2. **DeepSeek API 必须直连** — 任何代理都会影响稳定性
3. **Session 缓存可丢弃** — `workspace/` 是永久数据，`sessions/` 可安全重建
4. **Windows + Node.js 需要杀毒信任区** — 否则启动 I/O 会拖慢数倍
5. **三层排查方法论**：先网络层 → 再系统层 → 最后算力层
