#!/bin/bash
# Fix .bashrc - remove old broken PATH line, add clean config

# Remove the corrupted line
sed -i '/^export PATH=\\\\C:/d' ~/.bashrc
sed -i '/^export PATH=\C:/d' ~/.bashrc

# Append clean config
cat >> ~/.bashrc << 'EOF'

# Claude Code + DeepSeek
export PATH=$HOME/.npm-global/bin:$PATH
export ANTHROPIC_BASE_URL=https://api.deepseek.com/anthropic
export ANTHROPIC_MODEL=deepseek-v4-pro
export ANTHROPIC_DEFAULT_OPUS_MODEL=deepseek-v4-pro
export ANTHROPIC_DEFAULT_SONNET_MODEL=deepseek-v4-pro
export ANTHROPIC_DEFAULT_HAIKU_MODEL=deepseek-v4-flash
export CLAUDE_CODE_SUBAGENT_MODEL=deepseek-v4-flash
export CLAUDE_CODE_EFFORT_LEVEL=max
EOF

echo "=== Updated .bashrc tail ==="
tail -12 ~/.bashrc

echo "=== Verify claude binary ==="
export PATH=$HOME/.npm-global/bin:$PATH
claude --version
