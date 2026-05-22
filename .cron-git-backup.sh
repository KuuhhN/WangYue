#!/bin/bash
cd /mnt/c/Users/KUHN/.openclaw/workspace
git add -A
git commit --allow-empty -m "auto: backup $(date +%Y-%m-%dT%H:%M)"
git push 2>&1 || true