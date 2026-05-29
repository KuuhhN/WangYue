# WangYue — OpenClaw AI Agent: Local Deployment & Systems Engineering

> **A production-grade personal AI agent deployed on Windows 11, engineered through real debugging of 5-layer stack issues.**

## About This Project

This repository documents the complete lifecycle of deploying, configuring, and operating **WangYue (望月)**, an OpenClaw-based AI agent running locally on Windows. The agent serves as a tech R&D assistant with deep thinking (DeepSeek V4 Flash), web search (Gemini API), autonomous scheduling (cron), and long-term memory.

**Stack**: OpenClaw v2026.5.7 · DeepSeek V4 Flash · Gemini API · Node.js v24 · Windows 11 · Feishu/WebChat

---

## Key Engineering Achievements

### 1. Triple-Layer Network Optimization (`60s → 6ms`)

Diagnosed and resolved a cascading network bottleneck affecting API connectivity:

| Layer | Problem | Fix | Impact |
|-------|---------|-----|--------|
| DNS | Default resolver took 11.4s per request | Switched to Alibaba (223.5.5.5) + Cloudflare (1.1.1.1) | **11.4s → 16ms** |
| Proxy | Clash TUN mode routed DeepSeek traffic overseas | Switched to system-proxy-only | Eliminated routing detour |
| Runtime | Node.js `undici` ignored uppercase `NO_PROXY` env | Changed to lowercase `no_proxy` | Silent 60s timeout resolved |

**Result**: model-resolution/auth latency from **30–65s down to 0–6ms**.

### 2. Multi-Layer Startup Crash Diagnosis

Resolved three independent failure modes blocking Gateway startup:

- **Network layer**: WebSocket handshake failed — `tauri.localhost` missing from allowedOrigins policy
- **System layer**: Antivirus (Huorong) real-time scanning caused **93s I/O blocking** at startup → added to trust zone (93s → 26s)
- **Compute layer**: Sessions JSONL file corruption caused **148s Event Loop stall** during deserialization → isolated and rebuilt sessions directory, **zero data loss**

### 3. Model Architecture Migration

Proactively migrated from a two-tier routing design (V4 Flash + R1 sub-agent) to a single-model architecture when DeepSeek V4 Flash was discovered to natively support `thinking` mode with `reasoning_effort`, eliminating an entire redundant agent layer ahead of the R1 deprecation deadline (2026-07-24).

### 4. Systems Automation

Designed and deployed 5 autonomous cron jobs:
- AI news digest (daily 12:00)
- Git auto-backup (daily 12:00)
- System health self-check (daily 20:00)
- Memory distillation (daily 03:00)
- Session cache auto-cleanup (weekly)

---

## Architecture

```
User Layer (Feishu / WebChat)
    ↓ HTTPS
OpenClaw Gateway
    ↓
WangYue Agent
    ├── DeepSeek V4 Flash (thinking-mode) ← Direct connect (no proxy)
    ├── Gemini API (web_search) ← Via system proxy
    ├── Skills: Self-Improving / Summary / Code Scanner / CLI Harness
    └── Git / GitHub (auto-backup)
        ↓
Infrastructure: Windows 11 · Node.js v24 · Clash Proxy · Huorong (trusted)
```

---

## Repository Structure

```
├── AGENTS.md       # Agent behavior & operational protocols
├── SOUL.md         # Core identity & decision logic
├── IDENTITY.md     # System specification
├── HEARTBEAT.md    # Cron scheduling & autonomous protocol
├── MEMORY.md       # Distilled engineering chronicle
├── TOOLS.md        # Tool configurations
├── memory/         # Operational logs with troubleshooting records
│   ├── 2026-05-13.md              # Identity restructuring + upgrade crisis
│   ├── 2026-05-15-troubleshooting.md  # DNS + Proxy + Runtime debugging
│   ├── 2026-05-17.md              # Startup crash triple-layer fix
│   └── ...
└── scripts/        # Automation scripts (session cleanup, backup)
```

---

## Lessons Learned

1. **Always verify model capabilities before designing architecture** — DeepSeek V4 Flash absorbed thinking mode natively, making the independent R1 layer unnecessary
2. **Three-layer debugging methodology**: Network → System → Compute. Isolate each layer before making changes.
3. **Session cache is disposable** — `workspace/*` (identity, memory, config) is permanent; `sessions/*` can be safely rebuilt
4. **Windows + Node.js needs antivirus trust zones** for acceptable startup I/O performance
5. **Environment variables are case-sensitive** in Node.js `undici` — `no_proxy` ≠ `NO_PROXY`

---

## Tech Stack

| Layer | Choice |
|-------|--------|
| AI Model | DeepSeek V4 Flash |
| Agent Framework | OpenClaw v2026.5.7 |
| Search | Gemini API (Google Grounding) |
| Runtime | Node.js v24.15.0 |
| OS | Windows 11 24H2 (x64) |
| Proxy | Clash (system-proxy mode only) |
| Automation | Git + cron (5 tasks) |
| Channel | Feishu / WebChat |

---

*Built by [KuuhhN](https://github.com/KuuhhN)*
