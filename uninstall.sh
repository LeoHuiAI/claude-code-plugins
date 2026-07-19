#!/usr/bin/env bash
#
# 卸载：从 settings.json 移除本工具写入的 Notification / Stop 声音提醒。
# 只删除指向本工具播放脚本的 hook，不动你其它的 hook 配置。
#
set -euo pipefail

CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
SETTINGS="$CLAUDE_DIR/settings.json"
HOOKS_DIR="$CLAUDE_DIR/hooks"
SCRIPT_DEST="$HOOKS_DIR/cc-sound-notifications.sh"

command -v jq >/dev/null 2>&1 || { echo "❌ 需要 jq" >&2; exit 1; }
[ -f "$SETTINGS" ] || { echo "没有找到 $SETTINGS，无需卸载"; exit 0; }

backup="$SETTINGS.bak.$(date +%Y%m%d%H%M%S)"
cp "$SETTINGS" "$backup"

tmp="$(mktemp)"
# 只移除 command 里引用了本工具脚本的那一条 hook；若移除后事件为空则删掉该事件键
jq --arg s "$SCRIPT_DEST" '
  def strip($event):
    if (.hooks[$event]? != null) then
      .hooks[$event] |= (map(.hooks |= map(select((.command // "") | contains($s) | not)))
                         | map(select((.hooks | length) > 0)))
      | (if (.hooks[$event] | length) == 0 then del(.hooks[$event]) else . end)
    else . end;
  strip("Notification") | strip("Stop")
  | (if (.hooks? // {}) == {} then del(.hooks) else . end)
' "$SETTINGS" > "$tmp"

mv "$tmp" "$SETTINGS"
rm -f "$SCRIPT_DEST"

echo "✅ 已卸载。备份：$backup"
echo "👉 重启 Claude Code 或打开一次 /hooks 生效。"
