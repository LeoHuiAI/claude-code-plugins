#!/usr/bin/env bash
#
# 一键安装：给 Claude Code 加上「确认待处理」和「任务完成」声音提醒。
# 适用于 macOS / Linux（含 WSL、Git Bash）。Windows 原生请看 README 手动配置。
#
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
HOOKS_DIR="$CLAUDE_DIR/hooks"
SETTINGS="$CLAUDE_DIR/settings.json"
SCRIPT_DEST="$HOOKS_DIR/cc-sound-notifications.sh"

if ! command -v jq >/dev/null 2>&1; then
  echo "❌ 需要 jq。macOS: brew install jq  |  Debian/Ubuntu: sudo apt install jq" >&2
  exit 1
fi

mkdir -p "$HOOKS_DIR"
install -m 0755 "$REPO_DIR/play-sound.sh" "$SCRIPT_DEST"

# settings.json 不存在则创建空对象
[ -f "$SETTINGS" ] || echo '{}' > "$SETTINGS"

# 备份现有配置
backup="$SETTINGS.bak.$(date +%Y%m%d%H%M%S)"
cp "$SETTINGS" "$backup"

notify_cmd="\"$SCRIPT_DEST\" notify"
done_cmd="\"$SCRIPT_DEST\" done"

tmp="$(mktemp)"
jq --arg n "$notify_cmd" --arg d "$done_cmd" '
  .hooks = (.hooks // {})
  | .hooks.Notification = [ { "hooks": [ { "type": "command", "command": $n, "async": true } ] } ]
  | .hooks.Stop         = [ { "hooks": [ { "type": "command", "command": $d, "async": true } ] } ]
' "$SETTINGS" > "$tmp"

mv "$tmp" "$SETTINGS"

echo "✅ 安装完成"
echo "   • 播放脚本：$SCRIPT_DEST"
echo "   • 已写入：  $SETTINGS"
echo "   • 备份：    $backup"
echo
echo "👉 重启 Claude Code，或在会话里打开一次 /hooks 让配置重新加载。"
