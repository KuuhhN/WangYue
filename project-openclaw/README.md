# WangYue — OpenClaw AI Agent: Local Deployment & Systems Engineering

> **A production-grade personal AI agent deployed on Windows 11, engineered through real debugging of 5-layer stack issues.**

## Stack

OpenClaw v2026.5.7 · DeepSeek V4 Flash · Gemini API · Node.js v24 · Windows 11 · Feishu/WebChat

## Key Engineering Achievements

### 1. Triple-Layer Network Optimization (`65s → 6ms`)

| Layer | Problem | Fix | Impact |
|-------|---------|-----|--------|
| DNS | Default resolver took 11.4s per request | Switched to Alibaba (223.5.5.5) + Cloudflare (1.1.1.1) | **11.4s → 16ms** |
| Proxy | Clash TUN mode routed DeepSeek traffic overseas | Switched to system-proxy-only | Eliminated routing detour |
| Runtime | Node.js `undici` ignored uppercase `NO_PROXY` | Changed to lowercase `no_proxy` | Silent 60s timeout resolved |

### 2. Multi-Layer Startup Crash Diagnosis

- **Network**: WebSocket handshake failed — `tauri.localhost` missing from allowedOrigins policy
- **System**: Antivirus (Huorong) real-time scanning caused **93s I/O blocking** → trust zone fix (93s → 26s)
- **Compute**: Sessions JSONL file corruption caused **148s Event Loop stall** → isolated sessions, rebuilt fresh, **zero data loss**

### 3. Model Architecture Migration

Proactively migrated from two-tier routing (V4 Flash + R1 sub-agent) to single-model architecture when V4 Flash was found to natively support `thinking` mode — ahead of R1's deprecation deadline (2026-07-24).

### 4. Systems Automation

5 autonomous cron jobs: AI news digest, Git auto-backup, system health check, memory distillation, session cache cleanup.

## Architecture

```
User (Feishu / WebChat) → OpenClaw Gateway → Agent Core
  ├── DeepSeek V4 Flash (thinking-mode, direct connect)
  ├── Gemini API (web_search, via system proxy)
  ├── Skills: Self-Improving / Summary / Code Scanner
  └── Git auto-backup
```

## Lessons Learned

1. **Always verify model capabilities** — V4 Flash absorbed thinking mode natively, making a separate R1 layer unnecessary
2. **DeepSeek API must connect directly** — any proxy interferes with stability
3. **Session cache is disposable** — `workspace/` is permanent; `sessions/` can be safely rebuilt
4. **Windows + Node.js needs antivirus trust zones** for acceptable startup I/O
5. **Three-layer debugging methodology**: Network → System → Compute
