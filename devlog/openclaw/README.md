# OpenClaw Deployment Chronicle

> A timeline of building and debugging a personal AI agent on Windows.

## 2026-03 — First Deployment

Initial attempt to run OpenClaw on Windows 11. Basic setup completed, but significant stability issues remained.

## 2026-05-13 — Gateway Upgrade Crisis

Upgraded OpenClaw from v2026.3.2 to v2026.5.7. Hit **5 cascading failures**:

| Problem | Root Cause | Solution |
|---------|-----------|----------|
| Zombie Node processes blocking port | Previous manual launch left orphan processes | `taskkill /F /IM node.exe` |
| Node.js version mismatch | PATH pointing to old Node v22.13.0 | Physically removed old dir, reinstalled v24 |
| CLI command broken | Global npm symlinks broke | `npm install -g openclaw` |
| Panel isolation auto-destruction | Panel renamed executable to `.bak` | Re-ran global install |
| API connection timeout | Proxy interference with DeepSeek | Cleared proxy; DeepSeek must connect directly |

## 2026-05-15 — Network Stack Debugging

Diagnosed and fixed a triple-layer network bottleneck:
- **DNS**: 11.4s resolution → switched to Alibaba + Cloudflare (16ms)
- **Proxy**: Clash TUN mode routing traffic overseas → switched to system-proxy-only
- **Runtime**: uppercase `NO_PROXY` silently ignored by Node.js undici → lowercase fix

**Result**: API latency 65s → 6ms.

## 2026-05-17 — Startup Crash Diagnosis

Three independent failure modes blocking Gateway startup:
- Cross-origin WebSocket rejection
- Antivirus I/O blocking (93s startup penalty)
- Corrupted session files causing 148s Event Loop stall

**Result**: Startup 93s → 26s. Zero data loss.

## 2026-05-19 — Model Architecture Migration

- Old: V4 Flash (daily) + R1 sub-agent (deep thinking)
- Discovered V4 Flash natively supports thinking mode
- Migrated to single-model architecture
- R1 deprecated 2026-07-24 — migration was done proactively

## 2026-05-21 — Systems Automation

Deployed 5 cron tasks and session cache auto-cleanup.

## 2026-05-29 — Full System Restoration

Fixed all cron jobs (targeting current session), cleaned disk (+2.8GB reclaimed), archived large trajectory files (20MB → 8.6MB).
